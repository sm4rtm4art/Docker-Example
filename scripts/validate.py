#!/usr/bin/env python3
"""Run local and CI checks from any directory. Each lab uses an isolated project."""
import argparse
import ast
import json
import os
import re
import socket
import subprocess
import sys
import time
import tomllib
import uuid
import xml.etree.ElementTree as ET
from pathlib import Path
from http.client import HTTPException
from urllib.error import URLError
from urllib.parse import unquote, urlencode, urlsplit
from urllib.request import urlopen

from api_contract import Contract, run as contract

ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT / "reports"
QUICKSTART = ROOT / "docker-mastery-multitrack/02-language-quickstart"
DB = "docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml"


def command(args, *, capture=False, env=None, check=True):
    return subprocess.run(args, cwd=ROOT, env=env, text=True, check=check,
                          stdout=subprocess.PIPE if capture else None,
                          stderr=subprocess.STDOUT if capture else None).stdout


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def wait_json(url, predicate=lambda value: True, timeout=90):
    deadline = time.monotonic() + timeout
    last = "no response"
    while time.monotonic() < deadline:
        try:
            with urlopen(url, timeout=3) as response:
                value = json.load(response)
            if predicate(value):
                return value
            last = str(value)
        except (OSError, HTTPException, json.JSONDecodeError) as error:
            last = str(error)
        time.sleep(1)
    raise RuntimeError(f"Timed out waiting for {url}: {last}")


def static():
    import yaml  # Only this check needs PyYAML; container checks use the stdlib.
    files = [ROOT / name for name in command(["git", "ls-files", "--cached", "--others", "--exclude-standard"], capture=True).splitlines()]
    files = [p for p in files if p.is_file()]
    errors = []
    for path in files:
        try:
            suffix = path.suffix
            if suffix in (".yaml", ".yml"):
                list(yaml.safe_load_all(path.read_text()))
            elif suffix == ".json":
                json.loads(path.read_text())
            elif suffix == ".py":
                ast.parse(path.read_text(), filename=str(path))
            elif suffix == ".toml" or path.name in ("uv.lock", "Cargo.lock"):
                tomllib.loads(path.read_text())
            elif suffix == ".xml":
                ET.parse(path)
            elif suffix == ".sh":
                command(["bash", "-n", str(path)], capture=True)
            elif suffix == ".md":
                text = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
                for target in re.findall(r"\[[^\]]+\]\(([^)\s]+)\)", text):
                    parsed = urlsplit(target)
                    if parsed.scheme or parsed.netloc:
                        continue
                    local = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
                    require(local.exists(), f"Broken link: {target}")
                    if parsed.fragment and local.suffix == ".md":
                        headings = re.findall(r"^#{1,6}\s+(.+)$", re.sub(r"```.*?```", "", local.read_text(), flags=re.S), re.M)
                        anchors = [re.sub(r"[^\w\- ]", "", h.lower()).replace(" ", "-") for h in headings]
                        require(unquote(parsed.fragment) in anchors, f"Broken anchor: {target}")
        except Exception as error:
            errors.append(f"{path.relative_to(ROOT)}: {error}")
    # Explicitly cover all module overviews rather than matching nonexistent README files.
    curriculum = ROOT / "curriculum.json"
    for module in json.loads(curriculum.read_text())["modules"]:
        text = (ROOT / module["path"]).read_text()
        for heading in ("## Learning objectives", "## Prerequisites", "## Exercise", "## Check your understanding"):
            if heading not in text:
                errors.append(f"{module['path']}: missing {heading}")
    require(not errors, "\n".join(errors))
    print(f"PASS: syntax, local Markdown links and learning structure ({len(files)} files)")


def compose_lab(mode, track):
    project = "dockerlearn-check-" + uuid.uuid4().hex[:10]
    env = {**os.environ, "TASK_TRACK": track, "TASK_API_PORT": str(free_port()),
           "PROMETHEUS_PORT": str(free_port()), "GRAFANA_PORT": str(free_port()),
           "GRAFANA_ADMIN_PASSWORD": uuid.uuid4().hex}
    files = [DB] if mode == "database" else ["compose.lab.yml"]
    if mode == "monitoring":
        files.append("compose.monitoring.yml")
    base = ["docker", "compose", "-p", project]
    for file in files:
        base.extend(["-f", file])
    def dc(*args, capture=False, check=True):
        return command(base + list(args), capture=capture, env=env, check=check)
    REPORTS.mkdir(exist_ok=True)
    try:
        dc("config", "--quiet")
        dc("up", "--build", "--detach", "--wait", "--wait-timeout", "180")
        if mode == "database":
            def sql(query):
                return dc("run", "--rm", "-T", "client", "-Atc", query, capture=True).strip()
            sql("CREATE TABLE progress (id integer PRIMARY KEY, lesson text NOT NULL); INSERT INTO progress VALUES (1, 'volumes');")
            require(sql("SELECT lesson FROM progress WHERE id=1;").endswith("volumes"), "SQL/DNS check failed")
            dc("down")  # No -v: named volume must survive container replacement.
            dc("up", "--detach", "--wait", "--wait-timeout", "120")
            require(sql("SELECT lesson FROM progress WHERE id=1;").endswith("volumes"), "Database did not persist")
        else:
            url = "http://127.0.0.1:" + env["TASK_API_PORT"]
            wait_json(url + "/health")
            require(contract(url, REPORTS / f"{mode}-{track}-api.json"), "API contract failed")
            container = dc("ps", "-q", "task-api", capture=True).strip()
            inspect = json.loads(command(["docker", "inspect", container], capture=True))[0]
            require(inspect["Config"]["User"] == "10001:10001", "Unexpected image user")
            require(inspect["HostConfig"]["ReadonlyRootfs"], "Root filesystem is writable")
            require("ALL" in inspect["HostConfig"]["CapDrop"], "Capabilities not dropped")
            require(any("no-new-privileges" in item for item in inspect["HostConfig"]["SecurityOpt"]), "Missing no-new-privileges")
            require(dc("exec", "-T", "task-api", "id", "-u", capture=True).strip() == "10001", "Process runs as wrong user")
            write = subprocess.run(base + ["exec", "-T", "task-api", "touch", "/app/should-fail"], cwd=ROOT, env=env, capture_output=True)
            require(write.returncode != 0, "Write into /app unexpectedly succeeded")
            dc("exec", "-T", "task-api", "touch", "/tmp/allowed")
            if mode == "monitoring":
                query = urlencode({"query": 'up{job="task-api"}'})
                wait_json("http://127.0.0.1:" + env["PROMETHEUS_PORT"] + "/api/v1/query?" + query,
                          lambda data: data.get("status") == "success" and any(item["value"][1] == "1" for item in data["data"]["result"]))
                wait_json("http://127.0.0.1:" + env["GRAFANA_PORT"] + "/api/health", lambda data: data.get("database") == "ok")
            # Seed a task after the contract suite's cleanup, so memory-loss verification is meaningful.
            status, task, _ = Contract().request("POST", "/api/tasks", {"title": "restart-probe"})
            require(status == 201, "Could not seed restart probe")
            require(wait_json(url + "/api/tasks")["total"] >= 1, "Restart probe was not stored")
            dc("stop", "task-api")
            stopped = json.loads(command(["docker", "inspect", container], capture=True))[0]
            require(not stopped["State"]["OOMKilled"], "Process was OOM-killed")
            require(stopped["State"]["ExitCode"] in (0, 143), f"Unexpected exit code: {stopped['State']['ExitCode']}")
            dc("up", "--detach", "--wait", "--wait-timeout", "120", "task-api")
            require(wait_json(url + "/api/tasks")["total"] == 0, "Unexpected initial state after restart")
        print(f"PASS: {mode} ({track})")
    finally:
        logs = dc("logs", "--no-color", capture=True, check=False)
        (REPORTS / f"{mode}-{track}.log").write_text(logs or "")
        dc("down", "--volumes", "--remove-orphans", check=False)  # Only this newly created test project.


def configs():
    env = {**os.environ, "GRAFANA_ADMIN_PASSWORD": "validation-only"}
    for track in ("python", "rust", "java"):
        command(["docker", "compose", "-f", str(QUICKSTART / track / "docker-compose.yml"), "config", "--quiet"], env=env)
        dev = QUICKSTART / track / "compose.dev.yml"
        if dev.exists():
            command(["docker", "compose", "-f", str(dev), "config", "--quiet"], env=env)
        command(["docker", "compose", "-f", "compose.lab.yml", "-f", "compose.monitoring.yml", "config", "--quiet"], env={**env, "TASK_TRACK": track})
    command(["docker", "compose", "-f", DB, "--profile", "tools", "config", "--quiet"], env=env)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("check", choices=("static", "configs", "track", "database", "monitoring"))
    parser.add_argument("--track", choices=("python", "rust", "java"), default="python")
    args = parser.parse_args()
    try:
        if args.check == "static":
            static()
        elif args.check == "configs":
            configs()
        else:
            compose_lab(args.check, args.track)
    except (RuntimeError, subprocess.CalledProcessError, FileNotFoundError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

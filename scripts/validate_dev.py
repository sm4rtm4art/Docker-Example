#!/usr/bin/env python3
"""Build and start the actual standalone development Compose configuration."""
import argparse
import os
import uuid
from api_contract import run as contract
from validate import command, free_port, wait_json, require, ROOT, REPORTS, QUICKSTART

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--track", choices=("python", "rust"), required=True)
args = parser.parse_args()
project = "dockerlearn-devcheck-" + uuid.uuid4().hex[:10]
env = {**os.environ, "TASK_API_PORT": str(free_port())}
base = ["docker", "compose", "-p", project, "-f", str(QUICKSTART / args.track / "compose.dev.yml")]
REPORTS.mkdir(exist_ok=True)
try:
    command(base + ["up", "--build", "--detach"], env=env)
    url = "http://127.0.0.1:" + env["TASK_API_PORT"]
    wait_json(url + "/health", timeout=600)
    require(contract(url, REPORTS / f"dev-{args.track}-api.json"), "Development API contract failed")
finally:
    logs = command(base + ["logs", "--no-color"], env=env, capture=True, check=False)
    (REPORTS / f"dev-{args.track}.log").write_text(logs or "")
    command(base + ["down", "--volumes", "--remove-orphans"], env=env, check=False)

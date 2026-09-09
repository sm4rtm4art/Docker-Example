#!/usr/bin/env python3
"""Remove only the named course project. Volumes are retained unless requested."""
import argparse
import os
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("lab", choices=("api", "database", "monitoring"))
parser.add_argument("--delete-data", action="store_true", help="Also delete this lab's named volumes")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
projects = {"api": ("docker-learning", ["compose.lab.yml"]),
            "database": ("docker-learning-db", ["docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml"]),
            "monitoring": ("docker-learning-monitoring", ["compose.lab.yml", "compose.monitoring.yml"])}
project, files = projects[args.lab]
command = ["docker", "compose", "-p", project]
for file in files:
    command += ["-f", file]
command += ["down", "--remove-orphans"]
if args.delete_data:
    command += ["--volumes"]
# Used only for parsing the monitoring file during teardown, never for starting services.
env = {**os.environ, "GRAFANA_ADMIN_PASSWORD": os.environ.get("GRAFANA_ADMIN_PASSWORD") or "cleanup-unused"}
raise SystemExit(subprocess.run(command, cwd=root, env=env).returncode)

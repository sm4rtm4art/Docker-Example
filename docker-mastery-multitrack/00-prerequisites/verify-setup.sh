#!/usr/bin/env bash
# Read-only setup check. No package installation or permission changes.
set -euo pipefail
for tool in docker git python3 curl; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing required tool: $tool" >&2
    exit 1
  fi
done
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else "Python 3.12+ required")'
docker version
docker compose version
docker compose up --help | python3 -c 'import sys; sys.exit(0 if "--wait" in sys.stdin.read() else "Compose up --wait required")'
container_os=$(docker info --format '{{.OSType}}')
if [[ "$container_os" != linux ]]; then
  echo 'Linux containers are required.' >&2
  exit 1
fi
echo 'PASS: required tools, Compose wait support and Linux daemon available.'

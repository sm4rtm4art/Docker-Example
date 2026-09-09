# Health checks and graceful shutdown

## Learning objectives

Distinguish a running process, a healthy service and a clean shutdown.

## Prerequisites

Start the root API lab. Run from the repository root.

## Exercise

```bash
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect --format '{{json .State.Health}}' "$CONTAINER_ID"
curl --fail http://127.0.0.1:8080/health
docker compose -p docker-learning -f compose.lab.yml stop task-api
docker inspect --format '{{json .State}}' "$CONTAINER_ID"
```

The Dockerfile health check calls `/health`. Inspect the recorded exit codes and output, not just the status label. The endpoint checks this in-memory application; it does not establish readiness of an external database.

Stopping normally sends the configured stop signal (SIGTERM by default) to the main process, waits for the grace period, then uses SIGKILL if necessary. Exec-form startup avoids an extra shell that could interfere with signal handling. The supplied frameworks handle termination and Compose allows 30 seconds to stop.

A clean stop and `OOMKilled: false` are useful evidence, but an exit code alone does not prove that all in-flight requests completed. Investigate termination under realistic traffic before relying on it operationally. Docker health status by itself does not cause a restart; restart policies respond to process exit under their configured conditions.

Restart and check that tasks are empty:

```bash
docker compose -p docker-learning -f compose.lab.yml up --wait
curl --fail http://127.0.0.1:8080/api/tasks
python3 scripts/cleanup.py api
```

Reading: [Docker stop](https://docs.docker.com/reference/cli/docker/container/stop/), [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck).

## Check your understanding

Explain why unhealthy, exited and OOM-killed require different investigations. Describe the effect of exhausting the shutdown grace period.

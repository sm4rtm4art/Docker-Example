# Diagnose a failing container

## Learning objectives

Use configuration, process state, logs and health output to narrow down a failure.

## Prerequisites

A running root API lab. Commands use the repository root.

## Exercise

```bash
docker compose -p docker-learning -f compose.lab.yml ps -a
docker compose -p docker-learning -f compose.lab.yml logs --tail=100 task-api
docker compose -p docker-learning -f compose.lab.yml config
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect --format '{{json .State}}' "$CONTAINER_ID"
```

Distinguish build failures from startup failures and HTTP failures. A process can be running while a route fails. An unhealthy container has failed its configured health check; Docker does not automatically restart it just because health becomes unhealthy.

In a second terminal, request an unpublished host port such as `curl --max-time 3 http://127.0.0.1:65534/health` after checking that port is unused. Compare the connection error with an HTTP 404 from `http://127.0.0.1:8080/missing`. The first concerns connectivity; the second proves an HTTP server responded.

For filesystem issues, inspect the process identity and mounts:

```bash
docker compose -p docker-learning -f compose.lab.yml exec task-api id
docker inspect --format '{{json .Mounts}}' "$CONTAINER_ID"
```

Avoid installing tools into the running runtime container as a permanent fix. Make a reproducible Dockerfile or configuration change, then rebuild and verify it. Clean up with `python3 scripts/cleanup.py api`.

## Check your understanding

Explain what each observation rules out. Diagnose an intentionally wrong port without changing application code or broadening filesystem permissions.

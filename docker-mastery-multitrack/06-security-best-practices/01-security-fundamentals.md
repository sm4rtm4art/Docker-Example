# Verify image and runtime protections

## Learning objectives

Apply least privilege and distinguish configuration from observed behaviour.

## Prerequisites

Start a root API lab as in module 02. Run commands from the repository root.

## Exercise

| Protection | Where configured | What it limits |
| --- | --- | --- |
| `USER 10001:10001` | Dockerfile | Default process identity |
| Minimal runtime stage | Dockerfile | Shipped tools and dependencies |
| `read_only: true` | Compose | Writes to the root filesystem |
| `/tmp` tmpfs | Compose | A bounded, temporary writable area |
| `cap_drop: [ALL]` | Compose | Linux capabilities granted to the container |
| `no-new-privileges` | Compose | Gaining privileges through execution |
| Loopback port binding | Compose | Host-side network exposure |

```bash
docker compose -p docker-learning -f compose.lab.yml exec task-api id
docker compose -p docker-learning -f compose.lab.yml exec task-api touch /app/should-fail
docker compose -p docker-learning -f compose.lab.yml exec task-api touch /tmp/allowed
```

Expect UID 10001, a failed write to `/app` and a successful write to `/tmp`. Inspect the configuration actually applied:

```bash
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect --format '{{json .HostConfig}}' "$CONTAINER_ID"
```

Find the read-only flag, dropped capabilities and security options. Running the same image with plain `docker run` does not inherit these Compose settings. Non-root execution inside a container is also distinct from running a rootless Docker daemon.

Keep credentials out of Dockerfiles, build arguments and committed environment files. Use BuildKit secret mounts for build credentials. Runtime secret delivery is a separate concern; ordinary Compose file-backed secrets are mounted files, not an encrypted secret-management service. Never mount the Docker socket into this API.

Rebuild on supported base images and review dependency updates. A vulnerability report requires interpretation; a green job that only uploads findings does not mean zero vulnerabilities. Before releasing a real application, scan its built image and address authentication, TLS, persistent data and operational requirements.

Run `python3 scripts/validate.py track --track python` (or your track) for an isolated runtime check. Clean up the interactive lab with `python3 scripts/cleanup.py api`.

Reading: [Docker security](https://docs.docker.com/engine/security/), [rootless mode](https://docs.docker.com/engine/security/rootless/), [Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/).

## Check your understanding

Explain which protections travel with the image and which need runtime configuration. Give a concrete reason why non-root, a small image and a successful scan are each insufficient on their own.

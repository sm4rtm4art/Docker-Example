# Storage and permissions reference

A mount changes which filesystem appears at a container path. A bind mount exposes a host path; a named volume is managed by Docker; tmpfs provides temporary memory-backed storage. Mounting over a directory can hide files already present in the image.

Linux permissions use numeric user and group IDs. Matching a username string does not guarantee matching IDs. User namespaces and rootless engines can also remap those IDs. Inspect the actual process, path and mount before changing ownership.

For a running root API lab, from the repository root:

```bash
docker compose -p docker-learning -f compose.lab.yml exec task-api id
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect --format '{{json .Mounts}}' "$CONTAINER_ID"
docker compose -p docker-learning -f compose.lab.yml exec task-api ls -ld /app /tmp
```

`/app` belongs to a read-only root filesystem in the runtime lab. `/tmp` is writable tmpfs. A denied write to `/app` is expected; broadening permissions is not the solution. For an application that truly needs a persistent writable directory, design a specific mount and appropriate ownership for that path.

A volume persists files the application writes there; it does not persist process memory. A volume also does not replace backup and restore procedures. Follow the [volume exercise](../04-docker-compose/03-compose-volumes.md) to verify persistence by replacing the database container.

Reading: [Docker storage](https://docs.docker.com/engine/storage/), [bind mounts](https://docs.docker.com/engine/storage/bind-mounts/), [user namespace remapping](https://docs.docker.com/engine/security/userns-remap/).

# Troubleshooting Docker labs

Start with the layer that failed. Run commands from the repository root unless you started a track-local project.

| Symptom | First observation | Likely next step |
| --- | --- | --- |
| Cannot connect to Docker | `docker version`; `docker context show` | Check daemon availability and selected context |
| Build cannot find a file | Build context and `.dockerignore` | Correct the context or required input path |
| Port already allocated | `docker ps` and your host's listening ports | Stop the competing lab or choose another host port |
| Container exits immediately | `docker compose -p docker-learning -f compose.lab.yml logs task-api` | Investigate startup command, configuration and dependencies |
| Container is unhealthy | Inspect `.State.Health` | Read health-check output and test the configured endpoint |
| API returns 404 | Requested method and path | Use `/api/tasks` and a real task ID |
| Database client cannot connect | Service name, network and PostgreSQL health | Use `postgres`, not `localhost`, inside the client |
| File write fails | Process UID, mount mode and ownership | Check whether the path should be writable |
| Task data disappears | Was the API process restarted? | The sample API stores tasks in memory |
| Grafana login fails after changing an env var | Existing Grafana volume | The initial-password variable does not reset an existing account |

## Collect evidence

```bash
docker compose -p docker-learning -f compose.lab.yml ps -a
docker compose -p docker-learning -f compose.lab.yml logs --tail=100 task-api
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect --format '{{json .State}}' "$CONTAINER_ID"
```

If the container has already exited, obtain its ID with `ps -a -q task-api`. Record the command, relevant output, expected result and smallest reproduction. Remove credentials before sharing logs or resolved configuration.

Avoid global cleanup as a troubleshooting step. Use `python3 scripts/cleanup.py api`, `database` or `monitoring` for the named course projects. Volumes are retained unless you explicitly add `--delete-data`.

For permission issues, read [storage and permissions](VOLUMES_AND_PERMISSIONS_GUIDE.md). Do not solve Docker access problems by making the socket world-writable or running an application privileged.

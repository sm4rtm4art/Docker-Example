# 02 — Run a Task API

## Learning objectives

Build one language track and verify its HTTP behaviour. Allow 60–90 minutes.

## Prerequisites

Modules 00–01; host port 8080 is available.

## Exercise

Choose the language closest to your daily work. Each track exposes the same [Task API](task-api.md). Run one track at a time.

From the repository root:

```bash
export TASK_TRACK=python
docker compose -p docker-learning -f compose.lab.yml up --build --wait
curl --fail http://127.0.0.1:8080/health
python3 scripts/api_contract.py --base-url http://127.0.0.1:8080 --report reports/api.json
```

Set `TASK_TRACK` to `rust` or `java` for those tracks. The first build downloads dependencies and can take several minutes. Expect `/health` to report `status: healthy` and `storage: memory`.

Create a task before restarting the API:

```bash
curl --fail -H 'Content-Type: application/json' -d '{"title":"Learn Docker"}' http://127.0.0.1:8080/api/tasks
docker compose -p docker-learning -f compose.lab.yml restart task-api
```

After the service is healthy again, `GET /api/tasks` returns an empty collection: tasks belonged to the previous process. A volume does not automatically make application memory persistent.

Clean up with `python3 scripts/cleanup.py api`.

## Choose one track

- [Python track](python/python-quickstart.md)
- [Rust track](rust/rust-quickstart.md)
- [Java track](java/java-quickstart.md)
- [Task API reference](task-api.md)

```{toctree}
:hidden:
:maxdepth: 1

python/python-quickstart
rust/rust-quickstart
java/java-quickstart
task-api
```

## Check your understanding

Build your chosen track, pass the HTTP checks and explain where tasks are stored. Read the track page before moving to Dockerfiles. You can skip the other two track pages on your first pass.

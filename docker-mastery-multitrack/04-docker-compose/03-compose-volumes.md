# Verify persistence with volumes

## Learning objectives

Distinguish process memory, container layers, bind mounts, volumes and tmpfs.

## Prerequisites

The networking lesson. Run from the repository root.

## Exercise

| Storage | Stop/start same container | Remove and replace container |
| --- | --- | --- |
| Task API process memory | Lost | Lost |
| Writable container layer | Retained | Lost |
| Named volume | Retained | Retained until the volume is deleted |
| Bind mount | Files remain on the host | Files remain on the host |
| tmpfs | Lost when stopped | Lost |

```bash
export DB_COMPOSE=docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c "CREATE TABLE IF NOT EXISTS progress (id integer PRIMARY KEY, lesson text NOT NULL); INSERT INTO progress VALUES (1, 'volumes') ON CONFLICT (id) DO UPDATE SET lesson=EXCLUDED.lesson;"
docker compose -p docker-learning-db -f "$DB_COMPOSE" down
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c 'SELECT * FROM progress;'
```

Expect `1 | volumes` after replacement. PostgreSQL writes its data into the mounted volume. Adding a volume to the Task API would not persist its in-memory map.

A volume is not a backup: accidental SQL deletion or loss of the storage host can still destroy data. As an optional backup exercise, create a logical dump while PostgreSQL is running:

```bash
mkdir -p reports
docker compose -p docker-learning-db -f "$DB_COMPOSE" exec -T postgres pg_dump -U learner -d learning > reports/learning.sql
```

A usable backup also needs a successful restore test in a separate database. Do not assume copying a live database directory produces a consistent backup. Before a PostgreSQL major upgrade, check its migration procedure and image data paths.

Stop the lab while retaining data with `python3 scripts/cleanup.py database`. To deliberately discard this exercise's data, use `python3 scripts/cleanup.py database --delete-data`.

Reading: [Docker volumes](https://docs.docker.com/engine/storage/volumes/), [pg_dump](https://www.postgresql.org/docs/17/app-pgdump.html).

## Check your understanding

Run `python3 scripts/validate.py database`. Explain why replacing a container proves more about volume persistence than restarting it. Identify what your dump does and what remains to be verified.

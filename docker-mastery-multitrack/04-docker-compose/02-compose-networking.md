# Service DNS and network boundaries

## Learning objectives

Connect containers by service name and distinguish container-local from host-local addresses.

## Prerequisites

The Compose basics lesson. Run from the repository root.

## Exercise

Start the standalone database lab:

```bash
export DB_COMPOSE=docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c 'SELECT current_database(), current_user;'
```

Expect database `learning` and user `learner`. Read the Compose file: `client` connects to hostname `postgres`, the service name on their shared network. The database has no published host port. Explicitly targeting `client` runs it even though it belongs to the `tools` profile.

`localhost` inside the client container means that container itself, not the database or your host. Try the wrong address:

```bash
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm --entrypoint psql client -h 127.0.0.1 -U learner -d learning -c 'SELECT 1;'
```

Expect a connection failure. The client entrypoint normally includes `-h postgres`; setting `PGHOST` alone would not override that explicit option. Restore the default command and show that it succeeds. The network is marked `internal`; do not treat network separation as authentication or a complete security policy.

The credentials in this file are **DEV ONLY**, for a disposable local exercise. The health check uses `pg_isready`; it establishes server readiness to accept connections, not schema correctness. The SQL query verifies usable credentials and a real operation.

Keep the database running for the storage lesson, or stop it with `python3 scripts/cleanup.py database`.

Reading: [Compose networking](https://docs.docker.com/compose/how-tos/networking/).

## Check your understanding

Explain why `postgres` works and `127.0.0.1` fails inside the client. Show that a service can be reachable by another container without publishing a host port.

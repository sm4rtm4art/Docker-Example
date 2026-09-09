# Find the right Compose lab

Run course commands from the repository root. Use one API project at a time on a given host port.

| Configuration | Purpose | Lesson |
| --- | --- | --- |
| Root `compose.lab.yml` | Selected API track with runtime restrictions | [Run a Task API](../../02-language-quickstart/index.md) |
| Track `docker-compose.yml` | Track-local runtime project | [Language quickstarts](../../02-language-quickstart/index.md) |
| Python/Rust `compose.dev.yml` | Source-editing workflow | [Development](../../05-development-workflow/index.md) |
| `docker-compose.database.yml` in this directory | Standalone PostgreSQL and SQL client | [Networking](../../04-docker-compose/02-compose-networking.md) |
| Root `compose.monitoring.yml` merged with `compose.lab.yml` | API, Prometheus and Grafana | [Monitoring](../../08-monitoring-stack/02-complete-stack.md) |

Resolve configurations with `docker compose ... config` before starting a changed stack. `compose.dev.yml` is standalone; the monitoring file is an overlay and needs both `-f` arguments in the lesson's order.

The database's credentials are **DEV ONLY**. It is an independent persistence lab; the Task API does not connect to it. Monitoring requires a local Grafana password and retains data in its own volumes.

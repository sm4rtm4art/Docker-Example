# Run API, Prometheus and Grafana

## Learning objectives

Trace service DNS, metric scraping, provisioning and retained history.

## Prerequisites

The metrics lesson. Stop other labs on 8080, 9090 and 3000. Commands run from the repository root.

## Exercise

```bash
python3 scripts/cleanup.py api
export TASK_TRACK=python
export GRAFANA_ADMIN_PASSWORD='local-monitoring-exercise-only'
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml config --quiet
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml up --build --wait
```

Choose `rust` or `java` if preferred. The example password is **DEV ONLY**; do not reuse a personal password. Grafana creates its initial account when its database is first initialised. Changing the environment variable later does not reset an existing account password.

| Local URL | Observation |
| --- | --- |
| `http://127.0.0.1:8080/health` | API reports healthy and memory storage |
| `http://127.0.0.1:9090/targets` | `task-api` target is UP |
| `http://127.0.0.1:3000` | Sign in as `learner` using the lab password |

Open the **Docker Task API** dashboard in Grafana. Create tasks and wait for the five-second scrape interval plus the dashboard refresh. Panels show task counts. `up --wait` checks the API's health check; verify the Prometheus target and Grafana separately.

Prometheus connects to `task-api:8080`; Grafana connects to `prometheus:9090`. Those are container-network addresses. Your browser uses published host ports. Read `prometheus.yml` and the Grafana provisioning files in this module: configuration is mounted read-only, while each monitoring service stores its data in a named volume.

Stop and start only the API:

```bash
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml stop task-api
```

Query `up` in Prometheus after the next scrape. Expect 0. Historical task values can remain visible in graphs.

```bash
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml start task-api
```

The task store starts empty; Prometheus retains its own history. Validate a separate isolated stack with `python3 scripts/validate.py monitoring --track python`.

Clean up with `python3 scripts/cleanup.py monitoring`. Add `--delete-data` only when you intend to remove the lab's measurement history and Grafana data.

Reading: [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/), [Grafana provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/).

## Check your understanding

Show the target, datasource and panel involved in one measurement. Explain why the history survives API restart but the tasks do not. Identify the independent checks used for each service.

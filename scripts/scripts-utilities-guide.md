# Validation and cleanup commands

Run from the repository root with Python 3.12+. See [module 09](../docker-mastery-multitrack/09-cicd-automation/index.md) for check coverage and learning evidence.

| Command | Purpose |
| --- | --- |
| `python3 scripts/validate.py static` | Syntax, local Markdown links and module structure; requires PyYAML |
| `python3 scripts/validate.py configs` | Resolve all Compose configurations |
| `python3 scripts/validate.py track --track python` | Isolated runtime lab; also Rust and Java |
| `python3 scripts/validate_dev.py --track python` | Development lab; also Rust |
| `python3 scripts/validate.py database` | Database connection and persistence |
| `python3 scripts/validate.py monitoring` | API, Prometheus and Grafana |
| `python3 scripts/validate_kind.py --track python` | Optional isolated kind lab |
| `python3 scripts/api_contract.py` | HTTP checks against the running local API |

## Cleanup

`python3 scripts/cleanup.py api`, `database` and `monitoring` remove the fixed course projects `docker-learning`, `docker-learning-db` and `docker-learning-monitoring`, respectively. Named volumes remain unless you explicitly add `--delete-data`.

Track-local projects use different names. Stop them with `docker compose down` (or `docker compose -f compose.dev.yml down`) from the relevant track directory. Automated validation uses random project names and removes its own test volumes.

The shell and PowerShell cleanup entry points delegate to `cleanup.py`; use `python3 scripts/cleanup.py --help` for supported arguments.

## Results

A failed check exits with a nonzero status. Runtime logs and HTTP reports are written under `reports/`. A missing Docker daemon means the runtime check could not run; it is not a passing result.

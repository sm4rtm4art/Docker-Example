# 09 — Validate your work in CI

## Learning objectives

Interpret automated checks and record learning evidence. Allow 45–60 minutes.

## Prerequisites

Modules 00–08. Run commands from the repository root.

## Exercise

Start with the checks for the lesson you changed:

| Command | Evidence |
| --- | --- |
| `python3 scripts/validate.py static` | Parsed configuration, local Markdown links and module structure |
| `python3 scripts/validate.py configs` | Resolved Compose models |
| `python3 scripts/validate.py track --track python` | Image build, HTTP contract, runtime protections and restart behaviour |
| `python3 scripts/validate_dev.py --track python` | Development image and HTTP contract; also available for Rust |
| `python3 scripts/validate.py database` | Service connection and data surviving container replacement |
| `python3 scripts/validate.py monitoring` | API contract, Prometheus scrape and Grafana health |

The static check needs PyYAML from `requirements-ci.txt`; the runtime checks need Docker. Choose `rust` or `java` for their runtime checks. Each container check creates a separate project and local ports, writes evidence to `reports/`, then removes its own test containers and volumes.

## Run a learning check

1. Run your track's runtime check and open its JSON report in `reports/`.
2. In your own notes, connect each tested behaviour to a lesson.
3. Make a small intentional error, such as changing the health route in your source.
4. Rerun the check, read the failure and explain why it failed.
5. Restore your edit and confirm success.

## Read a CI result

The **Validate curriculum** GitHub Actions workflow runs for pull requests and main-branch changes. It builds all three runtime tracks, checks Python/Rust development images, exercises the database and monitoring labs, and builds the course website. Reports are uploaded as workflow artifacts. The regular runner is Linux; success there does not establish every host OS or CPU architecture.

The security job uploads an advisory dependency/secret scan. Its green status means the scan job completed; findings can still be present. Read the artifact and investigate relevant findings.

CI verifies selected behaviour, not a person's understanding. Use this self-assessment alongside it:

| Level | Evidence you can provide |
| --- | --- |
| Reproduce | Run the lab and identify the expected result |
| Explain | Connect the result to a Docker mechanism |
| Diagnose | Find and fix a deliberate failure |
| Transfer | Apply the same mechanism to a different track or small variation |

The optional kind check is separate from the Docker checks. The website build validates navigation and references; it does not execute every code block.

## Check your understanding

Pass the relevant automated check and explain a failure you caused and fixed. State one important property that the check does not establish. Keep your observations in personal notes rather than editing expected results to force a pass.

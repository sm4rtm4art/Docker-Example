# Choose your route

Follow the modules in order with one language track. Python uses an interpreted runtime, Rust produces a native binary, and Java runs a JAR on the JVM. The HTTP behaviour is shared, so you can focus on Docker before comparing languages.

| Module | Time | Completion evidence |
| --- | --- | --- |
| [00 — Prepare your environment](00-prerequisites/index.md) | 30–60 min | Verify your tools and identify the Docker daemon. |
| [01 — Containers and images](01-docker-fundamentals/index.md) | 60–90 min | Explain container lifecycle, isolation and published ports. |
| [02 — Run a Task API](02-language-quickstart/index.md) | 60–90 min | Build one language track and verify its HTTP behaviour. |
| [03 — Dockerfiles and builds](03-dockerfile-essentials/index.md) | 90–120 min | Use build contexts, caching and multi-stage builds. |
| [04 — Compose, networks and storage](04-docker-compose/index.md) | 90–120 min | Connect services and demonstrate data persistence. |
| [05 — Develop inside containers](05-development-workflow/index.md) | 45–60 min | Choose between reload, restart and rebuild. |
| [06 — Container security](06-security-best-practices/index.md) | 60–90 min | Apply and verify image and runtime protections. |
| [07 — Operate containers reliably](07-production-ready/index.md) | 60–90 min | Test health checks, shutdown and resource limits. |
| [08 — Observe a Compose application](08-monitoring-stack/index.md) | 60–90 min | Trace metrics from the API through Prometheus to Grafana. |
| [09 — Validate your work in CI](09-cicd-automation/index.md) | 45–60 min | Interpret automated checks and record learning evidence. |
| [10 — Docker capstone: operate a stack](10-orchestration-intro/index.md) | 45–60 min | Combine builds, networking, security and recovery in one exercise. |
| [11 — Beyond Docker (optional)](11-beyond-docker/index.md) | 45–60 min | Compare container tools and try a small local Kubernetes lab. |

## How to work through a module

1. Read the learning objectives and check the prerequisites.
2. Predict the outcome of the exercise.
3. Run it, inspect the actual state and explain any difference.
4. Complete the self-check and any relevant automated check.
5. Clean up the lab before starting another stack on the same ports.

Use a Bash shell from the repository root unless a lesson specifies another directory. Reserve the project names `docker-learning`, `docker-learning-db` and `docker-learning-monitoring` for these labs. Cleanup commands target those projects.

## What you will operate

The Task API has one process and in-memory storage: stopping or replacing that process removes its tasks. The standalone PostgreSQL exercise demonstrates durable files and service DNS. The monitoring exercise combines the Task API, Prometheus and Grafana.

Complete the Docker capstone before continuing to Beyond Docker. The optional kind lab transfers a few familiar concepts to a disposable cluster; it needs additional tools and resources.

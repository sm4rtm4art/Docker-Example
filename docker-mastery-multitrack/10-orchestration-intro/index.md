# 10 — Docker capstone: operate a stack

## Learning objectives

Combine builds, networking, security and recovery in one exercise. Allow 45–60 minutes.

## Prerequisites

Complete modules 00–09. Use your chosen track and the existing monitoring lab.

## Exercise

Use the [monitoring stack](../08-monitoring-stack/02-complete-stack.md) as a short operational exercise. Work from the repository root and keep the usual local-only ports and lab credentials.

1. Resolve the merged Compose configuration. Identify each service, network connection, published port and writable path before starting it.
2. Build and start the stack. Verify the API contract, Prometheus target and Grafana datasource.
3. Create a task. Stop the API and use logs and metrics to identify the failure while the monitoring services remain running.
4. Start the API again. Verify recovery and explain the empty task store alongside the retained metric history.
5. Inspect the running API's user, capabilities, root filesystem and resource limits. Confirm they match your design.
6. Clean up the stack, choosing explicitly whether to retain monitoring data.

## Reason about the boundary

Compose defines a multi-container application on a Docker host. It provides service networking and lifecycle commands, but a single host remains a shared failure point. A restart policy is not a multi-host scheduler or a substitute for durable application state.

Do not scale this in-memory API and assume a shared task list: separate instances have separate maps, and the lab's fixed published port also needs a different exposure design for multiple replicas. Explain those application and networking requirements before considering an orchestrator.

If you want one extension, add durable task storage as your own project using the PostgreSQL lab as preparation. You would need real database access in the API, migrations, error handling and a test showing tasks survive API replacement. Keep that extension separate from completing the Docker exercises.

## Check your understanding

Give a five-minute walkthrough covering build, startup, network path, failure diagnosis, recovery and cleanup. Support each point with a command or observed result. Continue to [Beyond Docker](../11-beyond-docker/index.md) only if you want a brief view of the next layer.

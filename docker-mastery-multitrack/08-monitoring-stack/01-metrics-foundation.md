# Understand the metrics you collect

## Learning objectives

Distinguish gauges, counters and scrape health.

## Prerequisites

A running Task API from module 02.

## Exercise

```bash
curl --fail http://127.0.0.1:8080/metrics
curl --fail -H 'Content-Type: application/json' -d '{"title":"Observe a metric"}' http://127.0.0.1:8080/api/tasks
curl --fail http://127.0.0.1:8080/metrics
```

The application exports three gauges: `task_count`, `task_completed_count` and `task_pending_count`. Total equals completed plus pending. Create, complete and delete a task using the [API reference](../02-language-quickstart/task-api.md), checking metrics after each change.

A gauge represents a value that can rise or fall. A counter accumulates events and normally only increases until reset. Do not apply a counter rate to the current task count and call it request throughput. This API does not instrument HTTP latency or request totals.

Prometheus periodically scrapes the text endpoint and adds its own `up` metric: 1 for a successful scrape, 0 for a failed one. `up` says whether the scrape worked, not whether every business operation succeeds. Avoid labels containing task IDs or free-form titles because they create unbounded time-series cardinality.

Stop the API with `python3 scripts/cleanup.py api` before starting the full monitoring project.

Reading: [Metric types](https://prometheus.io/docs/concepts/metric_types/), [instrumentation practices](https://prometheus.io/docs/practices/instrumentation/).

## Check your understanding

Predict all three gauge changes when completing and deleting a task. Explain what additional instrumentation would be needed to measure request latency.

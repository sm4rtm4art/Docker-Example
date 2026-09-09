# 08 — Observe a Compose application

## Learning objectives

Trace metrics from the API through Prometheus to Grafana. Allow 60–90 minutes.

## Prerequisites

Modules 04–07. Local ports 8080, 9090 and 3000 are available.

## Exercise

First inspect the API's metrics, then run the three-service stack.

- [Understand the metrics you collect](01-metrics-foundation.md)
- [Run API, Prometheus and Grafana](02-complete-stack.md)

```{toctree}
:hidden:
:maxdepth: 1

01-metrics-foundation
02-complete-stack
```

Your goal is to explain each step between a state change in the API and a panel in Grafana.

## Check your understanding

Create and complete tasks, observe their gauges and identify a failed scrape. Explain why an available dashboard does not prove the API is working.

# 07 — Operate containers reliably

## Learning objectives

Test health checks, shutdown and resource limits. Allow 60–90 minutes.

## Prerequisites

Module 06 and a working API image.

## Exercise

Follow these lessons to make the process behaviour observable and predictable:

- [Health checks and graceful shutdown](01-health-checks-graceful-shutdown.md)
- [CPU, memory and process limits](02-resource-management.md)
- [Choose an appropriate runtime image](03-minimal-secure-images.md)

```{toctree}
:hidden:
:maxdepth: 1

01-health-checks-graceful-shutdown
02-resource-management
03-minimal-secure-images
```

The sample API uses process memory. Use it to explore lifecycle behaviour; a service holding valuable data also needs durable storage, recovery procedures and application-level safeguards.

## Check your understanding

Collect evidence for health, termination and limits. Explain how those observations would inform the configuration of a real service.

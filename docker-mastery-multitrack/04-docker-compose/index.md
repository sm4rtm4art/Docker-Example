# 04 — Compose, networks and storage

## Learning objectives

Connect services and demonstrate data persistence. Allow 90–120 minutes.

## Prerequisites

Modules 00–03.

## Exercise

Work through these three lessons in order. Begin with the API service, then use a standalone PostgreSQL lab to study DNS and persistence.

- [Describe an application with Compose](01-compose-basics.md)
- [Service DNS and network boundaries](02-compose-networking.md)
- [Verify persistence with volumes](03-compose-volumes.md)

```{toctree}
:hidden:
:maxdepth: 1

01-compose-basics
02-compose-networking
03-compose-volumes
```

Keep application memory and filesystem storage separate in your explanations: PostgreSQL writes database files to a volume; the Task API holds tasks only in its process.

## Check your understanding

Resolve a Compose configuration, connect to PostgreSQL by service name, and demonstrate a stored row surviving container replacement.

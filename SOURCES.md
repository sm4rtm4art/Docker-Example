# Fachliche Referenzen

Abgleich der Überarbeitung: 9. September 2026. Produktdokumentationen sind veränderlich;
für ausführbare Beispiele gelten zusätzlich die Versionen und CI-Ergebnisse des jeweiligen Commits.
Die Links erläutern Verhalten, nicht eine pauschale Freigabe des Kursprojekts.

| Thema | Primärquelle | Im Kurs zu prüfen |
| --- | --- | --- |
| Dockerfile | [Referenz](https://docs.docker.com/reference/dockerfile/) | USER, EXPOSE, CMD, ENTRYPOINT, HEALTHCHECK |
| Build-Kontext | [Docker](https://docs.docker.com/build/building/context/) | COPY und `.dockerignore` |
| Buildcache | [Docker](https://docs.docker.com/build/cache/) | Cache-Invalidierung und Cache-Mounts |
| Multi-Stage | [Docker](https://docs.docker.com/build/building/multi-stage/) | Übergabe von Artefakten |
| Imagepflege | [Docker](https://docs.docker.com/build/building/best-practices/) | Versions-Tags, Digests und Updates |
| Compose | [Services](https://docs.docker.com/reference/compose-file/services/) | Health, Laufzeitlimits, Startabhängigkeiten |
| Reihenfolge | [Docker](https://docs.docker.com/compose/how-tos/startup-order/) | `service_healthy` ist keine dauerhafte Fehlerbehandlung |
| Netzwerke | [Docker](https://docs.docker.com/compose/how-tos/networking/) | Servicenamen und interne Ports |
| Persistenz | [Volumes](https://docs.docker.com/engine/storage/volumes/) | Lebenszyklus von Volume und Container |
| Dateizugriff | [Bind Mounts](https://docs.docker.com/engine/storage/bind-mounts/) | Hostrechte und verdeckte Imagepfade |
| Sicherheit | [Docker Engine](https://docs.docker.com/engine/security/) | Kernel- und Daemon-Schutzgrenzen |
| Secrets | [Build](https://docs.docker.com/build/building/secrets/), [Compose](https://docs.docker.com/compose/how-tos/use-secrets/) | Temporäre Zugriffe und Hostdateien |
| Limits | [Docker](https://docs.docker.com/engine/containers/resource_constraints/) | OOM, CPU und Speicher |
| Python | [uv mit Docker](https://docs.astral.sh/uv/guides/integration/docker/) | Locked sync und kompatible Runtime |
| Rust | [Cargo build](https://doc.rust-lang.org/cargo/commands/cargo-build.html) | `--locked` |
| Java | [Spring Boot](https://docs.spring.io/spring-boot/) | Systemanforderungen und Shutdown |
| PostgreSQL | [pg_dump](https://www.postgresql.org/docs/17/app-pgdump.html) | Logischer Dump und Wiederherstellung |
| Prometheus | [Typen](https://prometheus.io/docs/concepts/metric_types/), [Exposition](https://prometheus.io/docs/instrumenting/exposition_formats/) | Gauges und echter Text |
| Grafana | [Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/) | Datenquelle und Dashboard |
| CI | [GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions) | Minimale Rechte und Action-Pinning |
| Updates | [Dependabot](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories) | Unterstützte Manifeste und Lockfiles |
| kind | [Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/), [Release v0.33.0](https://github.com/kubernetes-sigs/kind/releases/tag/v0.33.0) | Node-Image, Image-Laden und Clusterabbau |
| Kubernetes | [Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | Startup, Readiness, Liveness |
| Alternativen | [Podman](https://docs.podman.io/), [CRI-Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/) | Rolle und Kompatibilitätsgrenzen |

Versionsabgleich für aktualisierte Werkzeuge erfolgte zusätzlich anhand der Releaseinformationen
von [uv](https://github.com/astral-sh/uv/releases/tag/0.12.11),
[FastAPI](https://github.com/fastapi/fastapi/releases/tag/0.141.1),
[Rust](https://github.com/rust-lang/rust/releases/tag/1.98.1),
[Spring Boot](https://github.com/spring-projects/spring-boot/releases/tag/v4.1.1),
[Prometheus](https://github.com/prometheus/prometheus/releases/tag/v3.14.0) und
[Grafana](https://github.com/grafana/grafana/releases/tag/v13.2.1).
Die Auflösung der Python-Abhängigkeiten ist im echten `uv.lock` festgehalten.

# Where Docker fits

| Tool or standard | Role |
| --- | --- |
| OCI | Specifications for container images, distribution and runtime behaviour |
| Docker Engine | Daemon and API for building and managing containers |
| Docker Compose | Declarative multi-container applications |
| Podman | Container management, including rootless operation |
| containerd | Container lifecycle runtime service |
| Kubernetes | Controllers and APIs for orchestrating workloads across nodes |

Kubernetes can use OCI-compatible images built with Docker. It connects to node runtimes through CRI; Docker Engine is not required on every Kubernetes node. Building an image and scheduling a workload are different responsibilities.

Podman offers familiar commands, but similar CLI syntax is not proof that networking, Compose integration or UID mapping will behave identically. A rootless engine and a non-root process inside a container solve different parts of the privilege problem. Linux containers on macOS or Windows still need a Linux environment.

## A short comparison exercise

Classify the course's Dockerfile, image, Compose file and HTTP test as build input, artifact, runtime configuration or behavioural check. Which could you reuse with Podman? Which would require validation in the target environment?

Use the same questions for Kubernetes before continuing to the [kind lab](kind-quickstart.md). You can reuse the application image and HTTP test, while its runtime configuration uses Kubernetes objects.

Reading: [OCI](https://opencontainers.org/), [Podman documentation](https://docs.podman.io/), [Kubernetes runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).

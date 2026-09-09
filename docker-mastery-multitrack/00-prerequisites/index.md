# 00 — Prepare your environment

## Learning objectives

Verify your tools and identify the Docker daemon. Allow 30–60 minutes.

## Prerequisites

Basic terminal navigation and permission to run containers on your machine.

## Exercise

Install Git, curl, Python 3.12+ and a supported Docker installation with Linux containers and the Compose plugin. Docker Engine is suitable on Linux; Docker Desktop is one option on macOS and Windows. Follow the vendor's installation requirements. On Windows, use WSL2 for the Bash exercises and enable Docker integration for that distribution.

You do not need uv, Cargo or Maven on the host for the container exercises. Allow about 4 GB of available memory and 10 GB of disk space for individual labs; Rust builds, monitoring and kind may need more.

From the repository root:

```bash
docker version
docker context show
docker info --format '{{.OSType}}'
docker compose version
docker compose up --help
python3 --version
git --version
bash docker-mastery-multitrack/00-prerequisites/verify-setup.sh
```

Expect both a Docker client and a reachable server, OS type `linux`, and support for `up --wait`. The setup script checks tools; it does not install software or change permissions.

The Docker client sends requests to the daemon selected by your context. A remote context operates on another machine, including its storage and published ports. Use a local context for this course.

If the daemon is unreachable, inspect the context and service status before changing permissions. Do not make the Docker socket world-writable. Access to a privileged Docker daemon provides extensive control over its host.

For a native PowerShell setup check, use `./docker-mastery-multitrack/00-prerequisites/verify-setup.ps1`; Python may be named `python` there. Use WSL for subsequent Bash commands.

Reading: [Install Docker Engine](https://docs.docker.com/engine/install/), [Docker contexts](https://docs.docker.com/engine/manage-resources/contexts/).

## Check your understanding

Explain where your daemon runs, why the course needs Linux containers, and why a host Java compiler is unnecessary. The setup check should exit successfully. Use the [troubleshooting guide](../common-resources/DOCKER_EMERGENCY_GUIDE.md) if it does not.

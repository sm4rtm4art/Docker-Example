# Python track

## Learning objectives

Locate the application, its dependencies and its runtime entry point. Build the FastAPI and Uvicorn example.

## Prerequisites

Module 02 introduction. Stop the root lab with `python3 scripts/cleanup.py api` before using the track-local Compose project.

## Exercise

From the repository root:

```bash
cd docker-mastery-multitrack/02-language-quickstart/python
docker compose up --build --wait
curl --fail http://127.0.0.1:8080/health
python3 ../../../scripts/api_contract.py
docker compose logs task-api
```

The build stage uses uv and the committed `uv.lock` to create a virtual environment. The runtime stage contains Python and that environment. Read `Dockerfile`, `.dockerignore` and `docker-compose.yml` in this directory. Identify the dependency manifest, source copy, user and startup command.

The runtime image uses UID/GID `10001:10001`. Compose supplies a read-only root filesystem, writable `/tmp`, dropped capabilities and resource limits. Those Compose settings are not embedded in the image.

The development image uses Uvicorn reload. See [development workflow](../../05-development-workflow/01-hot-reload-development.md).

Stop this track-local project from the same directory with `docker compose down`. Return to the repository root with `cd ../../..` before continuing.

## Check your understanding

The API checks pass. Explain which files are needed only to build the image, which are needed at runtime, and which protections come from Compose.

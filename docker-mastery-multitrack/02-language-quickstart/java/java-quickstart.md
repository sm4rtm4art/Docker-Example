# Java track

## Learning objectives

Locate the application, its dependencies and its runtime entry point. Build the Spring Boot example.

## Prerequisites

Module 02 introduction. Stop the root lab with `python3 scripts/cleanup.py api` before using the track-local Compose project.

## Exercise

From the repository root:

```bash
cd docker-mastery-multitrack/02-language-quickstart/java
docker compose up --build --wait
curl --fail http://127.0.0.1:8080/health
python3 ../../../scripts/api_contract.py
docker compose logs task-api
```

The Maven build stage runs verification and packages a JAR. The runtime stage contains a Java 21 JRE and the application JAR. Read `Dockerfile`, `.dockerignore` and `docker-compose.yml` in this directory. Identify the dependency manifest, source copy, user and startup command.

The runtime image uses UID/GID `10001:10001`. Compose supplies a read-only root filesystem, writable `/tmp`, dropped capabilities and resource limits. Those Compose settings are not embedded in the image.

After source edits, rebuild and recreate the container with `docker compose up --build --wait`.

Stop this track-local project from the same directory with `docker compose down`. Return to the repository root with `cd ../../..` before continuing.

## Check your understanding

The API checks pass. Explain which files are needed only to build the image, which are needed at runtime, and which protections come from Compose.

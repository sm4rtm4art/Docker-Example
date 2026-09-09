# Reload, restart or rebuild?

## Learning objectives

Select a feedback loop that matches what changed.

## Prerequisites

Stop the root lab from the repository root with `python3 scripts/cleanup.py api`. Then enter your track directory.

## Exercise

## Python

Working directory: `docker-mastery-multitrack/02-language-quickstart/python`.

```bash
docker compose -f compose.dev.yml up --build
```

Edit the root response in `src/main.py`. In a second terminal, request `curl --fail http://127.0.0.1:8080/`. Uvicorn reloads the application after the source edit. The container's source mount is read-only; your editor changes the host file. Reloading clears in-memory tasks. Dependency edits require an updated lockfile and a rebuilt development image.

## Rust

Working directory: `docker-mastery-multitrack/02-language-quickstart/rust`.

```bash
docker compose -f compose.dev.yml up --build -d
docker compose -f compose.dev.yml logs -f task-api
```

The first compilation can take several minutes. Edit the root response in `src/main.rs`, leave the log view with Ctrl+C and restart:

```bash
docker compose -f compose.dev.yml restart task-api
```

`cargo run --locked` compiles when the container starts; it does not watch files. Its target cache survives a restart of this container but is lost when the container is removed. Manifest and lockfile edits require an image rebuild.

## Java

Working directory: `docker-mastery-multitrack/02-language-quickstart/java`.

```bash
docker compose up --build --wait
```

Edit `HomeController.java` and repeat the command. This track uses an image rebuild rather than an automatic source watcher.

## Cleanup

Restore your own source edits. From the track directory, use `docker compose -f compose.dev.yml down` for Python/Rust, or `docker compose down` for Java. Return to the repository root before the next lesson.

Reading: [Bind mounts](https://docs.docker.com/engine/storage/bind-mounts/).

## Check your understanding

For each of source, dependency manifest and Dockerfile edits, name the required action. Explain why restarting a runtime container does not bring new host source into its image.

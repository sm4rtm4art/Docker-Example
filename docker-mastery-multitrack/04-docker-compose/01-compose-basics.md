# Describe an application with Compose

## Learning objectives

Resolve configuration and manage services through an explicit project.

## Prerequisites

Module 03. Run from the repository root.

## Exercise

```bash
export TASK_TRACK=python
docker compose -p docker-learning -f compose.lab.yml config
docker compose -p docker-learning -f compose.lab.yml up --build --wait
docker compose -p docker-learning -f compose.lab.yml ps
docker compose -p docker-learning -f compose.lab.yml logs task-api
```

Read `compose.lab.yml`. A service describes how to build and run a container. The project name groups its containers, networks and volumes. `config` resolves interpolation and validates the model; it does not build or start the application. Be careful where you share its output because resolved values can include credentials.

`up --build` builds and creates or updates services. `restart` restarts existing containers; it does not apply an edited image or Compose configuration. `up --wait` waits for services to be running or healthy according to their configuration. It cannot infer application checks you have not defined.

Change the host port in this shell and apply the configuration:

```bash
export TASK_API_PORT=8081
docker compose -p docker-learning -f compose.lab.yml up --wait
curl --fail http://127.0.0.1:8081/health
python3 scripts/cleanup.py api
unset TASK_API_PORT
```

The application still listens on container port 8080. Compose recreates the affected container, so its in-memory tasks disappear.

Reading: [Compose services](https://docs.docker.com/reference/compose-file/services/), [Compose up](https://docs.docker.com/reference/cli/docker/compose/up/).

## Check your understanding

Explain what changes when you edit a published port, and why `restart` is insufficient. Locate the project name and effective port using `config` and `ps`.

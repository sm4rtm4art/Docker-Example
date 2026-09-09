# Python: dependencies and runtime compatibility

## Learning objectives

Explain the dependency and artifact boundaries in your chosen image.

## Prerequisites

The two shared Dockerfile lessons.

## Exercise

Read the Python `Dockerfile` and `pyproject.toml`. The committed `uv.lock` controls dependency resolution. The build uses `uv sync --locked --no-dev`; a stale lockfile should fail rather than silently resolve a different environment.

The virtual environment is built for the container OS and Python version, then copied to a compatible runtime stage. A host virtual environment may contain incompatible paths or compiled extensions.

Make a source-only edit and rebuild twice. Compare the dependency layer with the source layer. Dependency changes require a lockfile update and rebuild; installing packages into a running container does not update the Dockerfile.

Reading: [uv in Docker](https://docs.astral.sh/uv/guides/integration/docker/).

## Check your understanding

Show the source change in the running API, identify the final artifact and explain which inputs trigger a rebuild. Restore your exercise edit and clean up your lab.

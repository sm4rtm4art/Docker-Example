# 05 — Develop inside containers

## Learning objectives

Choose between reload, restart and rebuild. Allow 45–60 minutes.

## Prerequisites

Module 04 and one working language track.

## Exercise

Work through the source-change experiment, then practise inspecting a failure. Choose the reload instructions for your language.

- [Reload, restart or rebuild?](01-hot-reload-development.md)
- [Diagnose a failing container](02-debugging-containers.md)
- [Use an editor without changing the runtime contract](03-ide-integration.md)

```{toctree}
:hidden:
:maxdepth: 1

01-hot-reload-development
02-debugging-containers
03-ide-integration
```

Development images can include compilers and source mounts for a short feedback loop. The runtime image should remain an independently buildable artifact.

## Check your understanding

Show a source edit reaching the API and explain whether it required a reload, restart or rebuild. Diagnose a failure using logs before entering a container shell.

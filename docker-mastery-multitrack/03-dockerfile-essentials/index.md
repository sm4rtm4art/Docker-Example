# 03 — Dockerfiles and builds

## Learning objectives

Use build contexts, caching and multi-stage builds. Allow 90–120 minutes.

## Prerequisites

One working language track from module 02.

## Exercise

Read the shared lessons, then the build pattern for your language. Use the actual Dockerfile in your track as the object of each experiment.

- [Build context, layers and cache](shared-concepts/01-dockerfile-fundamentals.md)
- [Multi-stage builds](shared-concepts/02-multistage-builds.md)
- [Python: dependencies and runtime compatibility](language-specific/python/python-dockerfile-patterns.md)
- [Rust: native artifacts and build caches](language-specific/rust/rust-dockerfile-patterns.md)
- [Java: build with a JDK, run with a JRE](language-specific/java/java-dockerfile-patterns.md)

```{toctree}
:hidden:
:maxdepth: 1

shared-concepts/01-dockerfile-fundamentals
shared-concepts/02-multistage-builds
language-specific/python/python-dockerfile-patterns
language-specific/rust/rust-dockerfile-patterns
language-specific/java/java-dockerfile-patterns
```

Build twice, change only an application response, then rebuild. Compare the cached and executed steps. Record which dependency step can be reused and why.

## Check your understanding

Explain the build context, the role of `.dockerignore`, cache invalidation and the contents of the final stage. Verify your changed image using the API contract, then restore only your own exercise edit.

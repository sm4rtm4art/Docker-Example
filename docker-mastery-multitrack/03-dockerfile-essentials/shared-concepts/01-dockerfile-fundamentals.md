# Build context, layers and cache

## Learning objectives

Explain how Docker finds input files and decides whether a build step can be reused.

## Prerequisites

Module 02. Commands run from the repository root.

## Exercise

```bash
export TASK_TRACK=python
docker build --progress=plain -t task-api:lesson "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker build --progress=plain -t task-api:lesson "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker history task-api:lesson
docker image inspect task-api:lesson
```

The final argument is the **build context**. `COPY` sources are relative to that context, not to your current directory or an arbitrary host path. `.dockerignore` excludes files from the context before they reach the builder. Keep credentials, host virtual environments and build outputs out; retain manifests, lockfiles and source files needed by `COPY`.

`FROM` selects a base; `RUN` executes a build command; `COPY` adds files; `WORKDIR` sets the working directory; `USER` selects a runtime identity. Exec-form `CMD` provides a default command without an extra shell. `ENV` persists in image configuration. Neither `ENV` nor `ARG` is a suitable channel for build secrets; use BuildKit secret mounts when credentials are needed.

Change one response in your track's source, rebuild, and observe where the cache stops being reused. Copying dependency manifests before frequently changing source can preserve expensive dependency steps. Cache reuse is an optimisation, not proof that an image is current or secure.

Inspect the image history and final metadata. History is useful for understanding layers but is not a complete security scan. Remove the exercise tag with `docker image rm task-api:lesson` when finished.

Reading: [Build context](https://docs.docker.com/build/concepts/context/), [cache invalidation](https://docs.docker.com/build/cache/invalidation/), [build secrets](https://docs.docker.com/build/building/secrets/).

## Check your understanding

Explain why `COPY ../secret.txt .` cannot import an arbitrary file outside the context. Identify one source edit that reuses dependency installation and one dependency edit that invalidates it.

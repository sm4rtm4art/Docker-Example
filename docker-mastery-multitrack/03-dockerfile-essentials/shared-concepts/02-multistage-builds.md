# Multi-stage builds

## Learning objectives

Separate build tools from runtime dependencies without losing required artifacts.

## Prerequisites

Read the build-context lesson.

## Exercise

Open the Dockerfile for your track and find each `FROM`, stage name and `COPY --from`. Draw the path from source files to the final artifact.

| Track | Build artifact | Runtime requirement |
| --- | --- | --- |
| Python | Virtual environment | Compatible Python interpreter and runtime libraries |
| Rust | Native executable | Compatible ABI and dynamically linked libraries |
| Java | Application JAR | Compatible JRE |

A final stage starts from its own base image. Files from a builder do not appear there unless copied. A small final image can reduce shipped tools and dependencies, but size alone does not establish security.

Build your track and inspect the resulting image. Locate its application artifact and verify the API. Then read the relevant language pattern below the shared lessons.

BuildKit cache mounts keep reusable build data outside normal image layers. Files required by a later stage must be copied into a normal filesystem path before that build step finishes. In the Rust Dockerfile, find the copy out of the target cache and explain why it exists.

Reading: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/), [cache mounts](https://docs.docker.com/build/cache/optimize/).

## Check your understanding

List the compiler/package manager files excluded from the final stage and the runtime dependencies that remain. Explain why copying a native binary between unrelated base distributions may fail.

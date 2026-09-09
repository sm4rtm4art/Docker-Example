# Choose an appropriate runtime image

## Learning objectives

Evaluate runtime compatibility, maintenance and size together.

## Prerequisites

The multi-stage and security lessons.

## Exercise

Inspect the final stage of each track's Dockerfile. Compare the application artifact, interpreter or runtime, system libraries and health-check tool.

A smaller image can reduce downloads and shipped packages. It can also remove tools you currently use for health checks or debugging. Alpine uses musl libc; Debian-family images generally use glibc. Native Python extensions and Rust binaries must be built for a compatible runtime environment.

Choose one possible reduction for your track and write down its compatibility implications before changing the Dockerfile. If you implement it, rebuild, run the API contract, verify health checks and repeat the runtime security check. Measure the resulting image size with `docker image inspect`; do not infer it from the base image name.

Tags can be updated by their publisher. Digests select a specific image, but require a deliberate update process to receive fixes. Keep base OS and runtime support periods in your maintenance decisions.

Reading: [Docker build best practices](https://docs.docker.com/build/building/best-practices/).

## Check your understanding

Defend a base-image choice using runtime compatibility, update strategy and diagnosability. Explain what a smaller size proves and what it does not.

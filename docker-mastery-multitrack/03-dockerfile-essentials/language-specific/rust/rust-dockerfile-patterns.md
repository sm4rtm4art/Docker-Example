# Rust: native artifacts and build caches

## Learning objectives

Explain the dependency and artifact boundaries in your chosen image.

## Prerequisites

The two shared Dockerfile lessons.

## Exercise

Read the Rust `Dockerfile` and `Cargo.lock`. `--locked` requires Cargo to use the committed dependency resolution. The build caches the registry and target directory, compiles the real source and copies the resulting executable out of the cache before the step ends.

Make a source-only edit, rebuild and verify the changed response. A successful cached build is useful only if it contains the current program. Inspect the final stage: a native binary can still depend on libc or other shared libraries. Debian-based build and runtime stages keep this example on a compatible runtime family.

Reading: [Cargo build](https://doc.rust-lang.org/cargo/commands/cargo-build.html).

## Check your understanding

Show the source change in the running API, identify the final artifact and explain which inputs trigger a rebuild. Restore your exercise edit and clean up your lab.

# CPU, memory and process limits

## Learning objectives

Inspect applied limits and interpret resource measurements.

## Prerequisites

Start the root API lab. Run from the repository root.

## Exercise

```bash
CONTAINER_ID=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker stats --no-stream "$CONTAINER_ID"
docker inspect --format '{{json .HostConfig}}' "$CONTAINER_ID"
```

Read the `mem_limit`, `cpus` and `pids_limit` values in `compose.lab.yml`. The lab sets 512 MB memory, one CPU's quota and 256 processes/threads as a starting point. Inspect the effective values in Docker; those limits are not measurements of actual consumption.

A CPU quota limits available CPU time; it does not reserve a dedicated core. A memory limit covers more than an application's heap. Native allocations, thread stacks and tmpfs can contribute to memory pressure. Exceeding memory can trigger an OOM kill; investigate `OOMKilled`, logs and workload rather than treating every exit code 137 as proof of OOM.

Compare idle usage for your chosen language with usage during repeated API calls. Do not generalise a short local sample into a performance ranking. If you adjust limits, apply the configuration with `up` and rerun the contract checks.

Restore your changes and use `python3 scripts/cleanup.py api`.

Reading: [Runtime resource constraints](https://docs.docker.com/engine/containers/resource_constraints/).

## Check your understanding

Distinguish configured quota, current usage and reserved capacity. Explain why a Java heap setting equal to the container memory limit leaves no room for other memory use.

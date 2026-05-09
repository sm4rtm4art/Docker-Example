# Agent Guidance

## Repository Purpose

This repository is a Docker-first learning curriculum for junior developers. It teaches Docker concepts through Java, Python, and Rust examples without turning the lessons into framework tutorials.

## Working Principles

- Preserve the `docker-mastery-multitrack` module path from `00` through `11`.
- Treat `README.md` as the landing page and `docker-mastery-multitrack/docker-curriculum-guide.md` as the canonical module overview.
- Keep the shared Task API contract consistent across code, docs, and `TASK_API_SPECIFICATION.md`. The canonical task endpoint is `/api/tasks`.
- Prefer modern `docker compose` in new or updated material. Mention `docker-compose` only as legacy compatibility guidance.
- Keep examples honest: label conceptual snippets, dev-only credentials, classroom shortcuts, and runtime-only hardening requirements.
- Do not add internal AI artifacts, hype-heavy maintainer notes, or untested copy-paste snippets to student-facing docs.
- When changing ports, endpoint paths, Dockerfiles, Compose files, or prerequisites, update nearby docs and the relevant language tracks in the same change.

## Validation

- For docs-only changes, run targeted searches for stale endpoints, placeholders, license drift, and internal artifacts.
- For Compose changes, run `docker compose config` when Docker is available.
- For Dockerfile changes, run `docker build` when time and daemon access allow.
- If validation cannot run, state the blocker clearly instead of implying the example was tested.

## Review Format

When `/review` is invoked:

1. Lead with findings, sorted High -> Medium -> Low.
2. Number each finding.
3. Include impact, location, why it matters, and suggested fix.
4. Use code references for concrete issues.
5. Use tables only when they improve scanability.
6. End with a brief conclusion and next step.
7. If there are no findings, say so and name residual risks or test gaps.

Preferred shape:

```text
## Findings

### 1. High: <Headline>
<Issue, impact, location, and suggested fix.>

### 2. Medium: <Headline>
...

## Conclusion
<Confidence summary, required fixes, and next step.>
```

# 06 — Container security

## Learning objectives

Apply and verify image and runtime protections. Allow 60–90 minutes.

## Prerequisites

Modules 00–05.

## Exercise

Review the boundaries around the Task API: untrusted HTTP input, its process identity, writable paths, network exposure and the Docker daemon.

- [Verify image and runtime protections](01-security-fundamentals.md)

```{toctree}
:hidden:
:maxdepth: 1

01-security-fundamentals
```

Choose one protection, predict the operation it should deny, and test that prediction. Explain the protection's limits as well as its effect.

## Check your understanding

Demonstrate non-root execution, a denied write to `/app` and an allowed write to `/tmp`. Identify two threats these controls do not solve, such as application bugs and unauthenticated API access.

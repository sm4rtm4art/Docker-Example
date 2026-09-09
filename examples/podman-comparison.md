# Optional Podman comparison

Prerequisites: complete the Docker path and install Podman using its [official instructions](https://podman.io/docs/installation). This is an exploratory exercise; validate behaviour in your own environment.

From the repository root, with host port 8080 free:

```bash
podman build -t localhost/task-api:learning docker-mastery-multitrack/02-language-quickstart/python
podman run --name task-api-podman -d -p 127.0.0.1:8080:8080 --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m --cap-drop ALL --security-opt no-new-privileges localhost/task-api:learning
```

Wait for `curl --fail http://127.0.0.1:8080/health` to succeed, then run `python3 scripts/api_contract.py`. Inspect the process identity, mounts and port binding. Compare these with the Docker lab; do not infer complete Compose compatibility from this single-container test.

Clean up with `podman rm -f task-api-podman` and `podman image rm localhost/task-api:learning`. For the conceptual overview, see [Beyond Docker](../docker-mastery-multitrack/11-beyond-docker/index.md).

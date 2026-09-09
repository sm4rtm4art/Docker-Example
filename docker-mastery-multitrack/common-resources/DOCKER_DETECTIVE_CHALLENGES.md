# Troubleshooting practice

Try these after the corresponding module. Make changes only in your own exercise configuration and restore them afterwards. For each challenge, record a prediction, observation, cause and fix.

| Challenge | Experiment | Completion evidence |
| --- | --- | --- |
| Wrong host port | Request an unused port instead of the API's published port | Distinguish connection failure from an HTTP error |
| Wrong service address | Override the SQL client entrypoint and connect to `127.0.0.1`, as in module 04 | Explain container-local loopback and recover with service DNS |
| Read-only path | Attempt `touch /app/should-fail` in the runtime API | Show the denied write and the runtime read-only setting |
| Lost task | Create a task, restart the API and query it | Explain why a process restart clears memory |
| Stale application | Edit source, restart a runtime container, then rebuild it | Explain which operation delivers new code |
| Missing metric target | Stop the API in the monitoring stack | Observe `up` become 0 while Prometheus stays available |

Start with [the troubleshooting guide](DOCKER_EMERGENCY_GUIDE.md) if you need a diagnostic sequence. A successful fix should preserve the intended restrictions, such as local ports and a read-only root filesystem.

## Transfer challenge

Repeat one experiment with another language track. Which Docker observations remain the same? Which build or reload steps differ? Support your explanation with the actual configuration rather than assumptions about the programming language.

# Part A: Health Checks & Graceful Shutdown

> **Duration**: 1 hour  
> **Focus**: Making containers production-ready with proper health monitoring

## 🎯 Learning Objectives

By the end of this section, you will:

- Implement health checks that actually detect problems
- Handle signals properly for zero-downtime deployments
- Debug common health check failures
- Understand Kubernetes readiness vs liveness probes

## 💔 The Problem: "But It's Running!"

Just because a container is running doesn't mean it's healthy:

```bash
# This container is "running" but broken
$ docker ps
CONTAINER ID   IMAGE     STATUS         PORTS
abc123         myapp     Up 10 hours    8080/tcp

$ curl http://localhost:8080/health
curl: (7) Failed to connect to localhost port 8080
```

## 🏥 Health Check Patterns

### 1. Basic HTTP Health Check

```dockerfile
# Good: Simple health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### 2. Application-Specific Health Check

```python
# Python/FastAPI example
@app.get("/health")
async def health_check():
    # Check critical dependencies
    try:
        # Database check
        await db.execute("SELECT 1")
        # Cache check
        await redis.ping()

        return {
            "status": "healthy",
            "checks": {
                "database": "ok",
                "cache": "ok"
            }
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={"status": "unhealthy", "error": str(e)}
        )
```

### 3. TCP Health Check (When HTTP Isn't Available)

```dockerfile
# For databases, message queues, etc.
HEALTHCHECK --interval=30s --timeout=3s \
  CMD nc -z localhost 5432 || exit 1
```

## 🛑 Graceful Shutdown Patterns

### The Wrong Way (Data Loss!)

```python
# BAD: Immediate shutdown
import signal
import sys

def handle_sigterm(signum, frame):
    print("Goodbye cruel world!")
    sys.exit(0)  # Drops all in-flight requests!

signal.signal(signal.SIGTERM, handle_sigterm)
```

### The Right Way (Zero Downtime)

```python
# GOOD: Graceful shutdown
import signal
import asyncio
from contextlib import asynccontextmanager

shutdown_event = asyncio.Event()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    yield
    # Shutdown - wait for in-flight requests
    await shutdown_event.wait()
    print("Finishing in-flight requests...")
    await asyncio.sleep(5)  # Grace period
    print("Shutdown complete")

def handle_sigterm(signum, frame):
    shutdown_event.set()

signal.signal(signal.SIGTERM, handle_sigterm)

app = FastAPI(lifespan=lifespan)
```

## 🎯 Exercise: Break & Fix Health Checks

### Step 1: Create a Broken Health Check

```dockerfile
# broken-health/Dockerfile
FROM python:3.12-slim

COPY app.py .

# This health check will always pass!
HEALTHCHECK CMD exit 0

CMD ["python", "app.py"]
```

```python
# broken-health/app.py
import time
import random

print("Starting app...")
time.sleep(10)  # Simulate slow startup

if random.random() > 0.5:
    print("ERROR: Failed to connect to database!")
    # App is broken but container shows "healthy"
    while True:
        time.sleep(1)
else:
    print("App started successfully")
    # ... rest of app
```

### Step 2: Fix It Properly

```dockerfile
# Add proper health check
HEALTHCHECK --start-period=15s --interval=5s \
  CMD python -c "import requests; requests.get('http://localhost:8080/health').raise_for_status()"
```

## 🔍 Debugging Health Check Failures

```bash
# See health check history
$ docker inspect --format='{{json .State.Health}}' container_name | jq

# Watch health check execution
$ docker events --filter event=health_status

# Debug failing health check
$ docker exec container_name /bin/sh -c "curl -f http://localhost:8080/health"
```

## ⚡ Quick Reference

### Health Check Options

| Option           | Default | Description                 |
| ---------------- | ------- | --------------------------- |
| `--interval`     | 30s     | How often to check          |
| `--timeout`      | 30s     | Maximum time for check      |
| `--start-period` | 0s      | Grace period during startup |
| `--retries`      | 3       | Failures before unhealthy   |

### Exit Codes

- `0` = Healthy
- `1` = Unhealthy
- `2` = Reserved (don't use)

## 🎓 Key Takeaways

1. **Running ≠ Healthy** - Always implement health checks
2. **Check Dependencies** - Database, cache, external services
3. **Graceful Shutdown** - Handle SIGTERM properly
4. **Start Period** - Give apps time to initialize
5. **Be Specific** - Check actual functionality, not just "is it running"

## 🚀 Next: Resource Management

Now that our containers report their health correctly, let's make sure they don't consume all available resources...

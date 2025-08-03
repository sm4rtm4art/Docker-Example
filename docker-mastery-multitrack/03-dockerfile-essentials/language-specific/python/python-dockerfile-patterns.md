# Python Docker Implementation Guide 🐍

Apply Docker best practices to Python applications with modern tooling including UV, FastAPI, and traditional pip workflows.

## 🎯 Python-Specific Docker Considerations

### Virtual Environment vs Container

```dockerfile
# ❌ Don't create virtual environments in containers
RUN python -m venv venv
RUN source venv/bin/activate

# ✅ Container IS the virtual environment
RUN pip install -r requirements.txt
```

### UV (Modern Package Manager) Support

```dockerfile
# Install UV (cutting-edge tool - may change rapidly!)
RUN pip install uv
RUN uv pip install -r requirements.txt --target /packages
```

## 📁 Complete Python Dockerfile Templates

### Basic Single-Stage (Development)

```dockerfile
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser src/ ./src/

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["python", "src/app.py"]
```

### Production Multi-Stage (Traditional pip)

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM python:3.12 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Install dependencies to a target directory
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /packages

# ==========================================
# Stage 2: Runtime Environment
# ==========================================
FROM python:3.12-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy packages from builder
COPY --from=builder --chown=appuser:appuser /packages /usr/local/lib/python3.12/site-packages

# Copy application code
COPY --chown=appuser:appuser src/ ./src/

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["python", "src/app.py"]
```

### Modern UV Multi-Stage

⚠️ **UV Warning**: UV is cutting-edge (2024). Syntax may change. Provide pip fallback!

```dockerfile
# ==========================================
# Stage 1: Build Environment with UV
# ==========================================
FROM python:3.12 AS builder

# Install UV (modern Python package manager)
RUN pip install uv

WORKDIR /build

# Copy requirements first for caching
COPY requirements.txt .

# Install with UV (faster than pip)
RUN uv pip install -r requirements.txt --target /packages

# ==========================================
# Stage 2: Runtime Environment
# ==========================================
FROM python:3.12-slim AS runtime

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy UV-installed packages
COPY --from=builder --chown=appuser:appuser /packages /usr/local/lib/python3.12/site-packages

COPY --chown=appuser:appuser src/ ./src/

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["python", "src/app.py"]
```

### Alpine-based (Size Optimized)

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM python:3.12-alpine AS builder

# Install build dependencies (Alpine packages)
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /packages

# ==========================================
# Stage 2: Runtime Environment
# ==========================================
FROM python:3.12-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache curl

# Create non-root user (Alpine syntax)
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

COPY --from=builder --chown=appuser:appuser /packages /usr/local/lib/python3.12/site-packages
COPY --chown=appuser:appuser src/ ./src/

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["python", "src/app.py"]
```

## 🔧 Build & Run Commands

### Build Your Python Application

```bash
# Single-stage development
docker build -t task-api:dev .

# Multi-stage production
docker build -f Dockerfile.multi -t task-api:prod .

# UV-based build
docker build -f Dockerfile.uv -t task-api:uv .

# Alpine-based build
docker build -f Dockerfile.alpine -t task-api:alpine .
```

### Size Comparison

```bash
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep task-api

# Expected results:
# task-api:dev      ~180MB
# task-api:prod     ~120MB
# task-api:uv       ~115MB
# task-api:alpine   ~80MB
```

### Run and Test

```bash
# Run production image
docker run -d -p 8080:8080 --name python-api task-api:prod

# Test FastAPI endpoints
curl http://localhost:8080/docs          # Swagger UI
curl http://localhost:8080/api/tasks     # Task API
curl http://localhost:8080/health        # Health check

# Check Python environment
docker exec python-api python --version
docker exec python-api pip list

# Cleanup
docker rm -f python-api
```

## 🚀 Python-Specific Optimizations

### Requirements Caching Strategy

```dockerfile
# This order enables caching
COPY requirements.txt .        # Changes rarely
RUN pip install -r requirements.txt  # Cached if requirements unchanged
COPY src/ ./src/              # Changes frequently
```

### FastAPI Health Check Integration

```python
# src/app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "task-api"}

@app.get("/api/tasks")
async def get_tasks():
    return {"tasks": []}
```

### UV vs Pip Decision Matrix

| Use UV When             | Use Pip When             |
| ----------------------- | ------------------------ |
| ✅ Performance critical | ✅ Stability critical    |
| ✅ CI/CD pipelines      | ✅ Production systems    |
| ✅ Development builds   | ✅ Traditional workflows |
| ✅ Experimenting        | ✅ Conservative approach |

## 🐛 Python-Specific Troubleshooting

### Issue 1: Package Build Failures (Alpine)

```bash
Error: Microsoft Visual C++ 14.0 is required
```

**Solution**: Add build dependencies

```dockerfile
# Alpine
RUN apk add --no-cache gcc musl-dev libffi-dev

# Debian/Ubuntu
RUN apt-get install -y build-essential
```

### Issue 2: UV Installation Issues

```bash
ERROR: uv: command not found
```

**Solution**: Provide pip fallback

```dockerfile
RUN pip install uv || echo "UV unavailable, using pip"
RUN if command -v uv; then \
        uv pip install -r requirements.txt --target /packages; \
    else \
        pip install -r requirements.txt --target /packages; \
    fi
```

### Issue 3: Import Path Issues

```bash
ModuleNotFoundError: No module named 'src'
```

**Solution**: Set PYTHONPATH or use proper imports

```dockerfile
ENV PYTHONPATH=/app
# OR
ENTRYPOINT ["python", "-m", "src.app"]
```

### Issue 4: SSL Certificate Errors

```bash
SSL: CERTIFICATE_VERIFY_FAILED
```

**Solution**: Add certificates

```dockerfile
# Alpine
RUN apk add --no-cache ca-certificates

# Debian/Ubuntu
RUN apt-get install -y ca-certificates
```

## 📊 Performance Comparison

### Build Time Test

```bash
# Compare pip vs UV
time docker build -f Dockerfile.pip -t test:pip .
time docker build -f Dockerfile.uv -t test:uv .
```

### Runtime Performance

```bash
# Memory usage
docker stats task-api --no-stream

# Startup time
time docker run --rm task-api:prod curl -f http://localhost:8080/health

# Response time
docker run -d -p 8080:8080 task-api:prod
time curl http://localhost:8080/api/tasks
```

## ✅ Python Implementation Checklist

- [ ] Multi-stage build reduces image size by 40%+
- [ ] Dependencies cached for fast rebuilds
- [ ] Non-root user implemented
- [ ] FastAPI health check works
- [ ] UV/pip fallback strategy implemented
- [ ] Alpine vs Debian choice justified
- [ ] Application starts in <10 seconds

## 🔗 FastAPI + Docker Best Practices

### Recommended Project Structure

```
src/
├── app.py              # FastAPI app
├── models/
│   └── task.py         # Pydantic models
├── routers/
│   └── tasks.py        # API routes
└── requirements.txt    # Dependencies
```

### Sample FastAPI Task API

```python
# src/app.py
from fastapi import FastAPI
from typing import List
import uvicorn

app = FastAPI(title="Task Management API")

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/api/tasks")
async def get_tasks():
    return {"tasks": [], "total": 0}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

Ready for orchestration? Proceed to [Module 04: Docker Compose](../../04-docker-compose/) to connect your Python API with PostgreSQL and build towards the monitoring stack!

---

**Remember**: These patterns work for Django, Flask, FastAPI, or any Python web framework. The Docker concepts are universal!

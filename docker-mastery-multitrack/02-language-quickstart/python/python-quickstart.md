# Python Quickstart - FastAPI Task API 🐍

Build your first containerized Python application using FastAPI! Learn Docker fundamentals while creating a production-ready REST API.

## 🎯 Learning Outcomes

- ✅ Create a FastAPI application with proper project structure
- ✅ Implement the Task API specification from scratch
- ✅ Master Python-specific Docker patterns and optimizations
- ✅ Handle UV package manager with pip fallbacks
- ✅ Debug common Python containerization issues

## 🚀 Project Overview

We'll build a **Task Management REST API** that demonstrates essential Docker concepts:

- **Base images**: Python official vs Alpine variants
- **Package management**: UV (modern, Rust-based) vs pip (traditional)
- **Non-root security**: Python user patterns
- **Health checks**: FastAPI integration
- **Development workflow**: Hot reload in containers

### 🤔 Why These Technology Choices?

**FastAPI**: We chose FastAPI over Flask or Django because:

- Modern async support (perfect for containerized microservices)
- Automatic API documentation (great for learning)
- Type hints and validation (catches errors early)
- High performance (comparable to Node.js)

**UV Package Manager**: We prefer UV over pip/conda/poetry because:

- **10-100x faster** than pip for dependency resolution
- Written in Rust (performance and reliability)
- Drop-in pip replacement (easy migration)
- Excellent for Docker layer caching (faster builds)
- Represents the future of Python packaging

**Python 3.11+**: Modern Python features and performance improvements that work excellently in containers.

### API Endpoints (Task API Specification)

```
GET    /health          → Health check
GET    /api/tasks       → List all tasks
POST   /api/tasks       → Create new task
GET    /api/tasks/{id}  → Get specific task
PUT    /api/tasks/{id}  → Update task
DELETE /api/tasks/{id}  → Delete task
GET    /metrics         → Prometheus metrics (Module 08)
```

## 📦 Project Setup

### Project Structure

```
python/
├── src/
│   ├── main.py              # FastAPI application
│   ├── models.py            # Task data models
│   ├── database.py          # Database connection
│   └── health.py            # Health check logic
├── requirements.txt         # pip dependencies
├── pyproject.toml          # UV dependencies (optional)
├── Dockerfile              # Production image
├── Dockerfile.dev          # Development image
├── docker-compose.yml      # Local development
└── .dockerignore           # Build context optimization
```

### Dependencies

**requirements.txt** (Traditional pip):

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0
prometheus-client==0.19.0
```

**pyproject.toml** (Modern UV):

```toml
[project]
name = "task-api"
version = "1.0.0"
description = "Task Management API for Docker Learning"
dependencies = [
    "fastapi>=0.104.1",
    "uvicorn[standard]>=0.24.0",
    "pydantic>=2.5.0",
    "pydantic-settings>=2.1.0",
    "prometheus-client>=0.19.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## 🐍 Python Implementation

### Core Application (`src/main.py`)

```python
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from typing import List, Optional
import uuid
import time
from datetime import datetime
from prometheus_client import Counter, Gauge, Histogram, generate_latest, CONTENT_TYPE_LATEST

# Initialize FastAPI app
app = FastAPI(
    title="Task Management API",
    description="Docker Learning Project - Python Edition",
    version="1.0.0"
)

# Add CORS middleware for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

TASKS_TOTAL = Counter(
    'tasks_created_total',
    'Total tasks created',
    ['status']
)

TASKS_ACTIVE = Gauge(
    'tasks_active_count',
    'Number of active tasks'
)

# Data models
class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None

class Task(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    completed: bool = False
    created_at: datetime
    updated_at: datetime

# In-memory storage (Module 04 will add database)
tasks_db = {}

# Middleware for metrics
@app.middleware("http")
async def metrics_middleware(request, call_next):
    start_time = time.time()

    response = await call_next(request)

    # Record metrics
    duration = time.time() - start_time
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status_code=response.status_code
    ).inc()

    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)

    return response

# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    """
    Health check endpoint for Docker containers.
    Returns 200 OK if service is healthy.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "task-api",
        "version": "1.0.0",
        "uptime": time.time()
    }

# Metrics endpoint
@app.get("/metrics", response_class=PlainTextResponse, tags=["Monitoring"])
async def metrics():
    """Prometheus metrics endpoint"""
    # Update active tasks gauge
    active_count = len([t for t in tasks_db.values() if not t.completed])
    TASKS_ACTIVE.set(active_count)

    return generate_latest()

# Task API endpoints
@app.get("/api/tasks", response_model=List[Task], tags=["Tasks"])
async def list_tasks():
    """Get all tasks"""
    return list(tasks_db.values())

@app.post("/api/tasks", response_model=Task, status_code=status.HTTP_201_CREATED, tags=["Tasks"])
async def create_task(task_data: TaskCreate):
    """Create a new task"""
    task_id = str(uuid.uuid4())
    now = datetime.now()

    task = Task(
        id=task_id,
        title=task_data.title,
        description=task_data.description,
        completed=False,
        created_at=now,
        updated_at=now
    )

    tasks_db[task_id] = task

    # Update metrics
    TASKS_TOTAL.labels(status="pending").inc()

    return task

@app.get("/api/tasks/{task_id}", response_model=Task, tags=["Tasks"])
async def get_task(task_id: str):
    """Get a specific task by ID"""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")

    return tasks_db[task_id]

@app.put("/api/tasks/{task_id}", response_model=Task, tags=["Tasks"])
async def update_task(task_id: str, task_update: TaskUpdate):
    """Update a specific task"""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")

    task = tasks_db[task_id]

    if task_update.title is not None:
        task.title = task_update.title
    if task_update.description is not None:
        task.description = task_update.description
    if task_update.completed is not None:
        # Track completion metrics
        if task_update.completed and not task.completed:
            TASKS_TOTAL.labels(status="completed").inc()
        task.completed = task_update.completed

    task.updated_at = datetime.now()

    return task

@app.delete("/api/tasks/{task_id}", tags=["Tasks"])
async def delete_task(task_id: str):
    """Delete a specific task"""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")

    del tasks_db[task_id]

    return {"message": "Task deleted successfully"}

# Development convenience
@app.get("/", tags=["Root"])
async def root():
    """API root endpoint with navigation"""
    return {
        "message": "Task Management API - Python Edition",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "tasks": "/api/tasks",
            "metrics": "/metrics"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

## 🐳 Python Docker Patterns

### Production Dockerfile

```dockerfile
# Use official Python runtime as base image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r fastapi && useradd -r -g fastapi -u 1000 fastapi

# Create app directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .

# Try UV first (modern), fallback to pip
RUN pip install uv || echo "UV unavailable, using pip" && \
    if command -v uv >/dev/null 2>&1; then \
        uv pip install --system --no-cache -r requirements.txt; \
    else \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Copy application code
COPY --chown=fastapi:fastapi src/ ./src/

# Switch to non-root user
USER fastapi:fastapi

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Development Dockerfile

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Install system dependencies + dev tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r fastapi && useradd -r -g fastapi -u 1000 fastapi

WORKDIR /app

# Install dependencies with development packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Additional development dependencies
RUN pip install --no-cache-dir \
    pytest \
    pytest-asyncio \
    httpx \
    black \
    isort \
    flake8

# Switch to non-root user
USER fastapi:fastapi

EXPOSE 8080

# Development server with hot reload
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
```

### Docker Compose Development Setup

```yaml
version: "3.8"

services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      # Hot reload source code
      - ./src:/app/src:ro
    ports:
      - "8080:8080"
    environment:
      - ENV=development
    networks:
      - dev-network

  # Future: Add PostgreSQL for Module 04
  # postgres:
  #   image: postgres:16-alpine
  #   environment:
  #     POSTGRES_DB: tasks
  #     POSTGRES_USER: taskuser
  #     POSTGRES_PASSWORD: taskpass
  #   ports:
  #     - "5432:5432"
  #   networks:
  #     - dev-network

networks:
  dev-network:
```

## 🔧 Python-Specific Docker Optimizations

### Package Manager Strategy

```dockerfile
# Strategy: Try UV (modern), fallback to pip (stable)
RUN pip install uv 2>/dev/null || true

# Use UV if available, otherwise pip
RUN if command -v uv >/dev/null 2>&1; then \
        echo "📦 Using UV (modern package manager)"; \
        uv pip install --system --no-cache -r requirements.txt; \
    else \
        echo "📦 Using pip (traditional package manager)"; \
        pip install --no-cache-dir -r requirements.txt; \
    fi
```

### Multi-Stage Build for Production

```dockerfile
# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# Production stage
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r fastapi && useradd -r -g fastapi -u 1000 fastapi

WORKDIR /app

# Install from wheels (faster, no build tools needed)
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --find-links /wheels -r requirements.txt && \
    rm -rf /wheels

# Copy application
COPY --chown=fastapi:fastapi src/ ./src/

USER fastapi:fastapi

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

## 🧪 Testing Your Python Container

### Build and Test

```bash
# Build production image
docker build -t task-api-python .

# Run container
docker run -d --name python-api -p 8080:8080 task-api-python

# Test health endpoint
curl http://localhost:8080/health

# Test API functionality
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Docker is awesome!","description":"Learning containerization"}'

# List tasks
curl http://localhost:8080/api/tasks

# Check metrics
curl http://localhost:8080/metrics

# Verify non-root user
docker exec python-api id
# Should show: uid=1000(fastapi) gid=1000(fastapi)
```

### Performance Testing

```bash
# Install Apache Bench for load testing
# macOS: brew install httpd

# Generate load
ab -n 1000 -c 10 http://localhost:8080/health

# Monitor metrics during load
watch -n 1 'curl -s http://localhost:8080/metrics | grep http_requests_total'
```

## 🐛 Python Container Troubleshooting

### Common Issues & Solutions

#### Issue 1: "ModuleNotFoundError"

```bash
# Problem: Python can't find modules
docker logs python-api
# ModuleNotFoundError: No module named 'src'

# Solution: Set PYTHONPATH correctly
ENV PYTHONPATH=/app
```

#### Issue 2: "Permission denied"

```bash
# Problem: Non-root user can't write
docker exec python-api touch /app/test.log
# Permission denied

# Solution: Fix ownership during build
COPY --chown=fastapi:fastapi src/ ./src/
```

#### Issue 3: "UV not found"

```bash
# Problem: UV package manager not available
# Solution: Graceful fallback in Dockerfile
RUN pip install uv || echo "UV unavailable, using pip"
```

### Debugging Commands

```bash
# Check Python environment
docker exec python-api python --version
docker exec python-api pip list

# Check file permissions
docker exec python-api ls -la /app

# Monitor process
docker exec python-api ps aux

# Check network connectivity
docker exec python-api curl http://localhost:8080/health
```

## ✅ Python Quickstart Checklist

Congratulations! You've mastered Python containerization:

- [ ] FastAPI Task API running in container
- [ ] Non-root user security implemented
- [ ] Health checks and metrics working
- [ ] UV/pip package manager strategy
- [ ] Development workflow with hot reload
- [ ] Production-ready multi-stage build
- [ ] Can debug common Python container issues

## 🚀 Next Steps

Ready for multi-container applications? Continue to [Module 04: Docker Compose](../04-docker-compose/) where you'll add PostgreSQL and build a complete stack!

**Remember**: These Python Docker patterns work for ANY Python application - Django, Flask, Tornado. Master the concepts here and apply them everywhere!

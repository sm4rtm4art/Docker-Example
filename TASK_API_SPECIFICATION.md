# Task Management API Specification

## Overview

A minimal REST API for task management that serves as the foundation for our Docker learning path. This API is intentionally simple to implement but comprehensive enough to demonstrate Docker networking, volumes, security, and monitoring concepts.

## Core Requirements

### Endpoints

#### 1. Health Check

```http
GET /health
```

**Response:**

```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-10T10:30:00Z",
  "database": "connected"
}
```

**Purpose**: Docker health checks, load balancer integration, monitoring

#### 2. List Tasks

```http
GET /tasks
```

**Response:**

```json
{
  "tasks": [
    {
      "id": "uuid-here",
      "title": "Learn Docker",
      "description": "Complete Docker fundamentals module",
      "completed": false,
      "created_at": "2024-01-10T10:00:00Z",
      "updated_at": "2024-01-10T10:00:00Z"
    }
  ],
  "total": 1
}
```

#### 3. Get Single Task

```http
GET /tasks/{id}
```

**Response:**

```json
{
  "id": "uuid-here",
  "title": "Learn Docker",
  "description": "Complete Docker fundamentals module",
  "completed": false,
  "created_at": "2024-01-10T10:00:00Z",
  "updated_at": "2024-01-10T10:00:00Z"
}
```

#### 4. Create Task

```http
POST /tasks
```

**Request:**

```json
{
  "title": "Build monitoring stack",
  "description": "Implement Prometheus and Grafana"
}
```

**Response:** 201 Created

```json
{
  "id": "new-uuid",
  "title": "Build monitoring stack",
  "description": "Implement Prometheus and Grafana",
  "completed": false,
  "created_at": "2024-01-10T11:00:00Z",
  "updated_at": "2024-01-10T11:00:00Z"
}
```

#### 5. Update Task

```http
PUT /tasks/{id}
```

**Request:**

```json
{
  "title": "Build monitoring stack",
  "description": "Implement Prometheus and Grafana",
  "completed": true
}
```

**Response:** 200 OK (returns updated task)

#### 6. Delete Task

```http
DELETE /tasks/{id}
```

**Response:** 204 No Content

#### 7. Metrics (Prometheus Format)

```http
GET /metrics
```

**Response:** (text/plain)

```prometheus
# HELP tasks_total Total number of tasks
# TYPE tasks_total counter
tasks_total 42

# HELP tasks_completed_total Total number of completed tasks
# TYPE tasks_completed_total counter
tasks_completed_total 35

# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",endpoint="/tasks",status="200"} 150
http_requests_total{method="POST",endpoint="/tasks",status="201"} 42

# HELP http_request_duration_seconds HTTP request latency
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.1"} 120
http_request_duration_seconds_bucket{le="0.5"} 139
http_request_duration_seconds_bucket{le="1.0"} 141
http_request_duration_seconds_count 142
```

## Database Schema

```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add updated_at trigger (PostgreSQL)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE
ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Configuration via Environment Variables

```bash
# Database
DATABASE_URL=postgres://taskuser:taskpass@postgres:5432/taskdb

# Server
PORT=8080
HOST=0.0.0.0

# Monitoring
METRICS_ENABLED=true
METRICS_PORT=9090

# Feature flags (for exercises)
ENABLE_FILE_UPLOAD=false
ENABLE_TASK_EXPORT=false
```

## Docker Integration Points

### 1. Health Check Pattern

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### 2. Non-Root User

```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

### 3. Volume Mounts (for exercises)

```yaml
volumes:
  - ./exports:/app/exports # Task export feature
  - ./uploads:/app/uploads # File attachment feature
```

### 4. Network Security

```yaml
networks:
  frontend: # Public-facing
  backend: # Database access only
```

## Implementation Notes by Language

### Java (Spring Boot)

- Use Spring Data JPA
- Spring Actuator for metrics
- Built-in health endpoint

### Python (FastAPI + UV)

- SQLAlchemy for ORM
- prometheus-client for metrics
- Built-in OpenAPI docs

### Rust (Actix-web)

- sqlx for database
- actix-web-prom for metrics
- Serde for JSON

## Progressive Enhancement Path

### Module 2: Basic API

- In-memory storage
- Health endpoint only
- Single container

### Module 4: Add Database

- PostgreSQL integration
- Docker Compose networking
- Volume persistence

### Module 6: Add Security

- Authentication headers (optional)
- Rate limiting
- Input validation

### Module 8: Add Monitoring

- Prometheus metrics
- Grafana dashboards
- Full stack deployment

## Example Docker Compose Evolution

### Stage 1: API Only

```yaml
version: "3.8"
services:
  api:
    build: .
    ports:
      - "8080:8080"
```

### Stage 2: API + Database

```yaml
version: "3.8"
services:
  api:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      DATABASE_URL: postgres://taskuser:taskpass@postgres:5432/taskdb
    networks:
      - backend

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend

volumes:
  postgres_data:

networks:
  backend:
```

### Stage 3: Full Monitoring Stack

```yaml
version: "3.8"
services:
  api:
    build: .
    ports:
      - "8080:8080"
    # ... (as above)

  postgres:
    image: postgres:16-alpine
    # ... (as above)

  prometheus:
    image: prom/prometheus:latest
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - backend
      - monitoring

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    networks:
      - monitoring

volumes:
  postgres_data:
  prometheus_data:
  grafana_data:

networks:
  backend:
  monitoring:
```

## Testing the API

### Basic Functionality Test

```bash
# Create a task
curl -X POST http://localhost:8080/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Docker","description":"Test the API"}'

# List tasks
curl http://localhost:8080/tasks

# Check health
curl http://localhost:8080/health

# View metrics
curl http://localhost:8080/metrics
```

### Docker-Specific Tests

```bash
# Test from another container
docker run --rm --network docker-mastery_backend \
  curlimages/curl:latest \
  curl http://api:8080/health

# Test volume persistence
docker-compose down
docker-compose up -d
curl http://localhost:8080/tasks  # Should still have data
```

## Success Criteria

1. **Language Agnostic**: Same API behavior across Java, Python, Rust
2. **Docker Native**: Health checks, metrics, graceful shutdown
3. **Production Ready**: Non-root, resource limits, security headers
4. **Educational**: Simple enough to understand, complex enough to be real

---

This Task API provides the perfect foundation for teaching Docker concepts while building something useful!

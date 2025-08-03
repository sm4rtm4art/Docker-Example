# Part A: Metrics Foundation - Instrumenting Your Task API 📈

Add Prometheus metrics to your Task API and build the foundation for complete observability!

## 🎯 Learning Outcomes

- ✅ Instrument your Task API with Prometheus metrics
- ✅ Configure Prometheus to scrape application metrics
- ✅ Understand the four types of Prometheus metrics
- ✅ Build queries with PromQL (Prometheus Query Language)
- ✅ Set up the foundation for Grafana dashboards

## 📊 Understanding Prometheus Metrics

### The Four Types of Metrics

#### 1. **Counter** - Always Increasing

```python
# HTTP requests total
http_requests_total{method="GET", status="200"} 1523

# Tasks created total
tasks_created_total{status="completed"} 847
```

#### 2. **Gauge** - Can Go Up/Down

```python
# Current active database connections
database_connections_active 12

# Current tasks in queue
tasks_pending_count 5
```

#### 3. **Histogram** - Distribution of Values

```python
# HTTP request duration buckets
http_request_duration_seconds_bucket{le="0.1"} 100
http_request_duration_seconds_bucket{le="0.5"} 145
http_request_duration_seconds_bucket{le="1.0"} 152
```

#### 4. **Summary** - Like Histogram + Percentiles

```python
# Request size summary with quantiles
http_request_size_bytes{quantile="0.5"} 512
http_request_size_bytes{quantile="0.95"} 1024
```

## 🛠️ Instrumenting Your Task API

### Java (Spring Boot + Micrometer)

Add metrics dependencies to `pom.xml`:

```xml
<dependencies>
    <!-- Existing dependencies -->

    <!-- Metrics -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
</dependencies>
```

Configure metrics in `application.properties`:

```properties
# Expose metrics endpoint
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true

# Custom metrics labels
management.metrics.tags.application=task-api
management.metrics.tags.environment=development
```

Add custom business metrics:

```java
@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final MeterRegistry meterRegistry;
    private final Counter tasksCreatedCounter;
    private final Gauge tasksActiveGauge;
    private final Timer requestTimer;

    public TaskController(TaskService taskService, MeterRegistry meterRegistry) {
        this.taskService = taskService;
        this.meterRegistry = meterRegistry;

        // Initialize custom metrics
        this.tasksCreatedCounter = Counter.builder("tasks_created_total")
                .description("Total number of tasks created")
                .tag("status", "all")
                .register(meterRegistry);

        this.tasksActiveGauge = Gauge.builder("tasks_active_count")
                .description("Number of active tasks")
                .register(meterRegistry, this, TaskController::getActiveTaskCount);

        this.requestTimer = Timer.builder("api_request_duration_seconds")
                .description("API request duration")
                .register(meterRegistry);
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody CreateTaskRequest request) {
        return Timer.Sample.start(meterRegistry)
                .stop(requestTimer.tag("endpoint", "create_task"))
                .recordCallable(() -> {
                    Task task = taskService.createTask(request);
                    tasksCreatedCounter.increment(
                        Tags.of("status", task.getStatus().toString())
                    );
                    return ResponseEntity.ok(task);
                });
    }

    private double getActiveTaskCount() {
        return taskService.getActiveTaskCount();
    }
}
```

### Python (FastAPI + prometheus-client)

Add metrics dependencies:

```python
# requirements.txt
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
prometheus-client==0.19.0
```

Implement metrics in your FastAPI app:

```python
from prometheus_client import Counter, Gauge, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi import FastAPI, Request, Response
import time

app = FastAPI(title="Task API", version="1.0.0")

# Define metrics
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

TASKS_CREATED = Counter(
    'tasks_created_total',
    'Total tasks created',
    ['status']
)

TASKS_ACTIVE = Gauge(
    'tasks_active_count',
    'Number of active tasks'
)

DATABASE_CONNECTIONS = Gauge(
    'database_connections_active',
    'Active database connections'
)

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
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

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/api/tasks")
async def create_task(task: CreateTaskRequest):
    # Create task logic
    new_task = await task_service.create_task(task)

    # Update metrics
    TASKS_CREATED.labels(status=new_task.status).inc()
    TASKS_ACTIVE.set(await task_service.get_active_count())

    return new_task

@app.get("/health")
async def health():
    # Update database connection gauge
    DATABASE_CONNECTIONS.set(await get_db_connection_count())
    return {"status": "healthy", "timestamp": time.time()}
```

### Rust (Actix-web + prometheus)

Add metrics dependencies to `Cargo.toml`:

```toml
[dependencies]
actix-web = "4"
prometheus = "0.13"
tokio = { version = "1", features = ["full"] }
sqlx = { version = "0.7", features = ["postgres", "runtime-tokio-rustls"] }
serde = { version = "1.0", features = ["derive"] }
```

Implement metrics:

```rust
use actix_web::{web, App, HttpServer, HttpResponse, Result, middleware};
use prometheus::{Counter, Gauge, Histogram, Encoder, TextEncoder, register_counter, register_gauge, register_histogram};
use std::time::Instant;

// Define metrics
lazy_static! {
    static ref HTTP_REQUESTS: Counter = register_counter!(
        "http_requests_total",
        "Total HTTP requests"
    ).unwrap();

    static ref HTTP_DURATION: Histogram = register_histogram!(
        "http_request_duration_seconds",
        "HTTP request duration"
    ).unwrap();

    static ref TASKS_CREATED: Counter = register_counter!(
        "tasks_created_total",
        "Total tasks created"
    ).unwrap();

    static ref TASKS_ACTIVE: Gauge = register_gauge!(
        "tasks_active_count",
        "Active tasks count"
    ).unwrap();
}

// Metrics middleware
pub struct MetricsMiddleware;

impl<S, B> Transform<S, ServiceRequest> for MetricsMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    fn new_transform(&self, service: S) -> Self::Future {
        let start = Instant::now();

        let fut = service.call(req);
        Box::pin(async move {
            let res = fut.await?;

            // Record metrics
            HTTP_REQUESTS.inc();
            HTTP_DURATION.observe(start.elapsed().as_secs_f64());

            Ok(res)
        })
    }
}

async fn metrics() -> Result<HttpResponse> {
    let encoder = TextEncoder::new();
    let metric_families = prometheus::gather();
    let mut buffer = Vec::new();
    encoder.encode(&metric_families, &mut buffer).unwrap();

    Ok(HttpResponse::Ok()
        .content_type("text/plain; version=0.0.4")
        .body(buffer))
}

async fn create_task(task: web::Json<CreateTaskRequest>) -> Result<HttpResponse> {
    // Create task logic
    let new_task = task_service::create_task(task.into_inner()).await?;

    // Update metrics
    TASKS_CREATED.inc();
    TASKS_ACTIVE.set(task_service::get_active_count().await? as f64);

    Ok(HttpResponse::Ok().json(new_task))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .wrap(MetricsMiddleware)
            .route("/metrics", web::get().to(metrics))
            .route("/api/tasks", web::post().to(create_task))
            .route("/health", web::get().to(health))
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
```

## 🔧 Prometheus Configuration

### Docker Compose Integration

Update your `docker-compose.yml`:

```yaml
version: "3.8"

services:
  # Your existing Task API
  task-api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - frontend
      - backend
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=8080"
      - "prometheus.path=/metrics"

  # Prometheus metrics collection
  prometheus:
    image: prom/prometheus:v2.45.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.console.libraries=/etc/prometheus/console_libraries"
      - "--web.console.templates=/etc/prometheus/consoles"
      - "--storage.tsdb.retention.time=15d"
      - "--web.enable-lifecycle"
    networks:
      - monitoring
      - backend
    depends_on:
      - task-api

  # Your existing PostgreSQL
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
  prometheus_data:
  postgres_data:

networks:
  frontend:
  backend:
  monitoring:
```

### Prometheus Configuration File

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  # Prometheus itself
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  # Task API metrics
  - job_name: "task-api"
    static_configs:
      - targets: ["task-api:8080"]
    metrics_path: "/metrics"
    scrape_interval: 10s
    scrape_timeout: 5s

  # PostgreSQL metrics (future: add postgres_exporter)
  # - job_name: 'postgres'
  #   static_configs:
  #     - targets: ['postgres-exporter:9187']

  # Container metrics (future: add cAdvisor)
  # - job_name: 'cadvisor'
  #   static_configs:
  #     - targets: ['cadvisor:8080']
```

## 🚀 Testing Your Metrics

### Start the Stack

```bash
# Build and start services
docker-compose up -d

# Check services are running
docker-compose ps

# Expected output:
# task-api     Up      0.0.0.0:8080->8080/tcp
# prometheus   Up      0.0.0.0:9090->9090/tcp
# postgres     Up      5432/tcp
```

### Generate Sample Data

```bash
# Create some tasks to generate metrics
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test metrics","description":"Generate some data"}'

curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Another task","description":"More metrics!"}'

# Get tasks (generate GET metrics)
curl http://localhost:8080/api/tasks

# Check health (updates connection metrics)
curl http://localhost:8080/health
```

### Verify Metrics Collection

```bash
# 1. Check Task API metrics endpoint
curl http://localhost:8080/metrics

# Should see metrics like:
# http_requests_total{method="GET",endpoint="/api/tasks",status_code="200"} 1
# tasks_created_total{status="pending"} 2
# tasks_active_count 2

# 2. Check Prometheus targets
open http://localhost:9090/targets

# Should show task-api target as "UP"

# 3. Query metrics in Prometheus
open http://localhost:9090/graph

# Try these queries:
# rate(http_requests_total[5m])
# tasks_active_count
# http_request_duration_seconds_bucket
```

## 📊 Essential PromQL Queries

### Request Rate and Latency

```promql
# Requests per second
rate(http_requests_total[5m])

# Requests per second by endpoint
sum(rate(http_requests_total[5m])) by (endpoint)

# 95th percentile response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate (4xx, 5xx responses)
rate(http_requests_total{status_code=~"4..|5.."}[5m])
```

### Business Metrics

```promql
# Task creation rate
rate(tasks_created_total[5m])

# Active tasks
tasks_active_count

# Task completion rate
rate(tasks_created_total{status="completed"}[5m])

# Task backlog growth
increase(tasks_created_total[1h]) - increase(tasks_created_total{status="completed"}[1h])
```

### Infrastructure Metrics

```promql
# Database connections
database_connections_active

# Memory usage (when cAdvisor is added)
container_memory_usage_bytes{name="task-api"}

# CPU usage rate
rate(container_cpu_usage_seconds_total{name="task-api"}[5m])
```

## 🔍 Troubleshooting Metrics

### Common Issues

#### 1. "No metrics appearing in Prometheus"

```bash
# Check if metrics endpoint works
curl http://localhost:8080/metrics

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Prometheus logs
docker-compose logs prometheus
```

#### 2. "Task API not reachable from Prometheus"

```bash
# Test network connectivity
docker-compose exec prometheus wget -qO- http://task-api:8080/metrics

# Check docker networks
docker network ls
docker network inspect task-management_backend
```

#### 3. "Metrics not updating"

```bash
# Check scrape interval in prometheus.yml
# Generate traffic to update metrics
for i in {1..10}; do curl http://localhost:8080/health; done

# Check metric timestamps
curl http://localhost:8080/metrics | grep -A 1 "http_requests_total"
```

## ✅ Metrics Foundation Checklist

Before proceeding to Grafana:

- [ ] Task API exposes `/metrics` endpoint with Prometheus format
- [ ] Prometheus successfully scrapes Task API metrics
- [ ] Can query basic metrics in Prometheus UI
- [ ] HTTP request metrics show rate and duration data
- [ ] Business metrics (tasks created/active) update correctly
- [ ] Understand PromQL basics for querying metrics

## 🚀 Next Steps

Metrics foundation complete! Time to build beautiful dashboards with [Part B: Complete Stack](./02-complete-stack.md) where we'll add Grafana, cAdvisor, and create production-ready monitoring!

---

**Remember**: These metrics patterns work for ANY application - web APIs, batch jobs, microservices. Master the concepts here and apply them everywhere!

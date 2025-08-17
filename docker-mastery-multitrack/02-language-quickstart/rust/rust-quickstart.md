# Rust Quickstart - Actix-web Task API 🦀

Build your first containerized Rust application using Actix-web! Learn Docker fundamentals while creating a blazingly fast, memory-safe REST API.

## 🎯 Learning Outcomes

- ✅ Create an Actix-web application with proper project structure
- ✅ Implement the Task API specification with Rust performance
- ✅ Master Rust-specific Docker patterns and optimizations
- ✅ Build static binaries for minimal container images
- ✅ Debug common Rust containerization challenges

## 🚀 Project Overview

We'll build a **Task Management REST API** that showcases Rust's strengths in containerized environments:

- **Static binaries**: No runtime dependencies
- **Memory safety**: No segfaults or memory leaks
- **Performance**: Sub-millisecond response times
- **Security**: Compile-time safety checks
- **Minimal images**: scratch or distroless base images

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
rust/
├── src/
│   ├── main.rs              # Application entry point
│   ├── handlers.rs          # HTTP request handlers
│   ├── models.rs            # Task data models
│   ├── metrics.rs           # Prometheus metrics
│   └── health.rs            # Health check logic
├── Cargo.toml               # Dependencies and metadata
├── Cargo.lock               # Dependency lock file
├── Dockerfile               # Production image
├── Dockerfile.dev           # Development image
├── docker-compose.yml       # Local development
└── .dockerignore            # Build context optimization
```

### Dependencies (`Cargo.toml`)

```toml
[package]
name = "task-api"
version = "1.0.0"
edition = "2021"
description = "Task Management API for Docker Learning"

[dependencies]
actix-web = "4.4"
actix-cors = "0.6"
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
uuid = { version = "1.0", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
prometheus = "0.13"
env_logger = "0.10"
log = "0.4"

[profile.release]
lto = true              # Link-time optimization
codegen-units = 1       # Better optimization
panic = "abort"         # Smaller binary size
strip = true            # Remove debug symbols
```

## 🦀 Rust Implementation

### Main Application (`src/main.rs`)

```rust
use actix_cors::Cors;
use actix_web::{web, App, HttpServer, Result, middleware::Logger};
use env_logger::Env;
use std::sync::Mutex;
use std::collections::HashMap;

mod handlers;
mod models;
mod metrics;
mod health;

use models::Task;
use handlers::*;
use health::health_check;
use metrics::metrics_handler;

// Application state
pub struct AppState {
    pub tasks: Mutex<HashMap<String, Task>>,
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize logging
    env_logger::init_from_env(Env::default().default_filter_or("info"));

    // Initialize metrics
    metrics::init_metrics();

    // Create application state
    let app_state = web::Data::new(AppState {
        tasks: Mutex::new(HashMap::new()),
    });

    log::info!("Starting Task API server on 0.0.0.0:8080");

    // Start HTTP server
    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .wrap(Logger::default())
            .wrap(
                Cors::default()
                    .allow_any_origin()
                    .allow_any_method()
                    .allow_any_header()
            )
            .wrap(metrics::PrometheusMetrics::new())
            // Health and metrics
            .route("/health", web::get().to(health_check))
            .route("/metrics", web::get().to(metrics_handler))
            // Root endpoint
            .route("/", web::get().to(root_handler))
            // Task API endpoints
            .service(
                web::scope("/api")
                    .route("/tasks", web::get().to(list_tasks))
                    .route("/tasks", web::post().to(create_task))
                    .route("/tasks/{id}", web::get().to(get_task))
                    .route("/tasks/{id}", web::put().to(update_task))
                    .route("/tasks/{id}", web::delete().to(delete_task))
            )
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}

async fn root_handler() -> Result<web::Json<serde_json::Value>> {
    Ok(web::Json(serde_json::json!({
        "message": "Task Management API - Rust Edition",
        "endpoints": {
            "health": "/health",
            "tasks": "/api/tasks",
            "metrics": "/metrics"
        }
    })))
}
```

### Data Models (`src/models.rs`)

```rust
use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Task {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub completed: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateTaskRequest {
    pub title: String,
    pub description: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateTaskRequest {
    pub title: Option<String>,
    pub description: Option<String>,
    pub completed: Option<bool>,
}

impl Task {
    pub fn new(title: String, description: Option<String>) -> Self {
        let now = Utc::now();
        Task {
            id: Uuid::new_v4().to_string(),
            title,
            description,
            completed: false,
            created_at: now,
            updated_at: now,
        }
    }

    pub fn update(&mut self, request: UpdateTaskRequest) {
        if let Some(title) = request.title {
            self.title = title;
        }
        if let Some(description) = request.description {
            self.description = Some(description);
        }
        if let Some(completed) = request.completed {
            self.completed = completed;
        }
        self.updated_at = Utc::now();
    }
}
```

### Request Handlers (`src/handlers.rs`)

```rust
use actix_web::{web, HttpResponse, Result};
use crate::{AppState, models::*};
use crate::metrics::{TASKS_CREATED, TASKS_ACTIVE};

pub async fn list_tasks(data: web::Data<AppState>) -> Result<HttpResponse> {
    let tasks = data.tasks.lock().unwrap();
    let task_list: Vec<Task> = tasks.values().cloned().collect();
    Ok(HttpResponse::Ok().json(task_list))
}

pub async fn create_task(
    data: web::Data<AppState>,
    request: web::Json<CreateTaskRequest>,
) -> Result<HttpResponse> {
    let task = Task::new(request.title.clone(), request.description.clone());
    let task_id = task.id.clone();

    // Update metrics
    TASKS_CREATED.with_label_values(&["pending"]).inc();

    // Store task
    {
        let mut tasks = data.tasks.lock().unwrap();
        tasks.insert(task_id, task.clone());

        // Update active tasks gauge
        let active_count = tasks.values().filter(|t| !t.completed).count();
        TASKS_ACTIVE.set(active_count as f64);
    }

    Ok(HttpResponse::Created().json(task))
}

pub async fn get_task(
    data: web::Data<AppState>,
    path: web::Path<String>,
) -> Result<HttpResponse> {
    let task_id = path.into_inner();
    let tasks = data.tasks.lock().unwrap();

    match tasks.get(&task_id) {
        Some(task) => Ok(HttpResponse::Ok().json(task)),
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Task not found"
        }))),
    }
}

pub async fn update_task(
    data: web::Data<AppState>,
    path: web::Path<String>,
    request: web::Json<UpdateTaskRequest>,
) -> Result<HttpResponse> {
    let task_id = path.into_inner();
    let mut tasks = data.tasks.lock().unwrap();

    match tasks.get_mut(&task_id) {
        Some(task) => {
            // Track completion metrics
            if let Some(completed) = request.completed {
                if completed && !task.completed {
                    TASKS_CREATED.with_label_values(&["completed"]).inc();
                }
            }

            task.update(request.into_inner());

            // Update active tasks gauge
            let active_count = tasks.values().filter(|t| !t.completed).count();
            TASKS_ACTIVE.set(active_count as f64);

            Ok(HttpResponse::Ok().json(task))
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Task not found"
        }))),
    }
}

pub async fn delete_task(
    data: web::Data<AppState>,
    path: web::Path<String>,
) -> Result<HttpResponse> {
    let task_id = path.into_inner();
    let mut tasks = data.tasks.lock().unwrap();

    match tasks.remove(&task_id) {
        Some(_) => {
            // Update active tasks gauge
            let active_count = tasks.values().filter(|t| !t.completed).count();
            TASKS_ACTIVE.set(active_count as f64);

            Ok(HttpResponse::Ok().json(serde_json::json!({
                "message": "Task deleted successfully"
            })))
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Task not found"
        }))),
    }
}
```

### Prometheus Metrics (`src/metrics.rs`)

```rust
use actix_web::{dev::ServiceRequest, dev::ServiceResponse, Error, HttpResponse, Result};
use actix_web::dev::{forward_ready, Service, ServiceFactory, Transform};
use prometheus::{Counter, Gauge, Histogram, Encoder, TextEncoder, register_counter, register_gauge, register_histogram_vec};
use std::future::{Ready, ready};
use std::pin::Pin;
use std::task::{Context, Poll};
use futures_util::future::LocalBoxFuture;
use std::time::Instant;

// Global metrics
lazy_static::lazy_static! {
    pub static ref HTTP_REQUESTS: Counter = register_counter!(
        "http_requests_total",
        "Total HTTP requests"
    ).unwrap();

    pub static ref HTTP_DURATION: prometheus::HistogramVec = register_histogram_vec!(
        "http_request_duration_seconds",
        "HTTP request duration",
        &["method", "endpoint"]
    ).unwrap();

    pub static ref TASKS_CREATED: prometheus::CounterVec = prometheus::register_counter_vec!(
        "tasks_created_total",
        "Total tasks created",
        &["status"]
    ).unwrap();

    pub static ref TASKS_ACTIVE: Gauge = register_gauge!(
        "tasks_active_count",
        "Active tasks count"
    ).unwrap();
}

pub fn init_metrics() {
    // Initialize metrics
    lazy_static::initialize(&HTTP_REQUESTS);
    lazy_static::initialize(&HTTP_DURATION);
    lazy_static::initialize(&TASKS_CREATED);
    lazy_static::initialize(&TASKS_ACTIVE);
}

pub async fn metrics_handler() -> Result<HttpResponse> {
    let encoder = TextEncoder::new();
    let metric_families = prometheus::gather();
    let mut buffer = Vec::new();
    encoder.encode(&metric_families, &mut buffer).unwrap();

    Ok(HttpResponse::Ok()
        .content_type("text/plain; version=0.0.4")
        .body(buffer))
}

// Prometheus metrics middleware
pub struct PrometheusMetrics;

impl<S, B> Transform<S, ServiceRequest> for PrometheusMetrics
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = PrometheusMetricsMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(PrometheusMetricsMiddleware { service }))
    }
}

pub struct PrometheusMetricsMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for PrometheusMetricsMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let start = Instant::now();
        let method = req.method().to_string();
        let path = req.path().to_string();

        let fut = self.service.call(req);

        Box::pin(async move {
            let res = fut.await?;

            // Record metrics
            HTTP_REQUESTS.inc();
            HTTP_DURATION
                .with_label_values(&[&method, &path])
                .observe(start.elapsed().as_secs_f64());

            Ok(res)
        })
    }
}
```

### Health Check (`src/health.rs`)

```rust
use actix_web::{HttpResponse, Result};
use serde_json::json;
use std::time::{SystemTime, UNIX_EPOCH};

pub async fn health_check() -> Result<HttpResponse> {
    let uptime = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    Ok(HttpResponse::Ok().json(json!({
        "status": "healthy",
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "service": "task-api",
        "version": "1.0.0",
        "uptime": uptime
    })))
}
```

## ⚠️ Important: Permission Issues Warning

**Before building**: Our Dockerfile creates a user with UID 1000, but your host user might be different!

```bash
# Check your UID (might not be 1000!)
id -u
# Mac users: often 501
# Enterprise Linux: often 10000+
```

**If you plan to use bind mounts**, build with your actual UID:

```bash
# Build with your host UID/GID to avoid permission issues
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t task-api-rust .
```

📖 **See**: [Complete Volumes & Permissions Guide](../../common-resources/VOLUMES_AND_PERMISSIONS_GUIDE.md) for details.

## 🐳 Rust Docker Patterns

### Production Dockerfile (Multi-stage)

```dockerfile
# Build stage
FROM rust:1.75 as builder

WORKDIR /usr/src/app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Create dummy source to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies (cached layer)
RUN cargo build --release
RUN rm src/main.rs

# Copy source code
COPY src ./src

# Build application
RUN cargo build --release

# Runtime stage - minimal Debian
FROM debian:bookworm-slim

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r rust && useradd -r -g rust -u 1000 rust

# Create app directory
WORKDIR /app
RUN chown rust:rust /app

# Copy binary from builder stage
COPY --from=builder --chown=rust:rust /usr/src/app/target/release/task-api .

# Switch to non-root user
USER rust:rust

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["./task-api"]
```

### Minimal Dockerfile (Distroless)

```dockerfile
# Build stage
FROM rust:1.75 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build static binary
ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN cargo build --release --target x86_64-unknown-linux-gnu

# Runtime stage - Google's distroless
FROM gcr.io/distroless/static-debian12

# Copy binary
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-gnu/release/task-api /

# Distroless runs as non-root by default
EXPOSE 8080

# Note: No health check in distroless (no shell)
ENTRYPOINT ["/task-api"]
```

### Scratch-based Dockerfile (Ultra-minimal)

```dockerfile
# Build stage
FROM rust:1.75 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build fully static binary
ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN cargo build --release --target x86_64-unknown-linux-musl

# Runtime stage - scratch (empty)
FROM scratch

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/task-api /task-api

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["/task-api"]
```

### Docker Compose Development

```yaml
version: "3.8"

services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      # Hot reload source code
      - ./src:/usr/src/app/src:ro
      - ./Cargo.toml:/usr/src/app/Cargo.toml:ro
    ports:
      - "8080:8080"
    environment:
      - RUST_LOG=debug
      - ENV=development
    networks:
      - dev-network

networks:
  dev-network:
```

## 🔧 Rust-Specific Optimizations

### Build Performance

```dockerfile
# Dockerfile.dev - Development with faster builds
FROM rust:1.75

WORKDIR /usr/src/app

# Install cargo-watch for hot reload
RUN cargo install cargo-watch

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Pre-build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build
RUN rm src/main.rs

EXPOSE 8080

# Hot reload command
CMD ["cargo", "watch", "-x", "run"]
```

### Binary Size Optimization

```toml
# Cargo.toml - Optimize for size
[profile.release]
opt-level = "z"     # Optimize for size
lto = true          # Link-time optimization
codegen-units = 1   # Better optimization
panic = "abort"     # Smaller binary
strip = true        # Remove debug symbols

# Optional: Use system allocator instead of jemalloc
[dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]
```

### Cross-compilation Setup

```dockerfile
# Multi-arch build support
FROM --platform=$BUILDPLATFORM rust:1.75 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Install cross-compilation tools
RUN case "${TARGETPLATFORM}" in \
    "linux/amd64") echo "x86_64-unknown-linux-gnu" > /target.txt ;; \
    "linux/arm64") echo "aarch64-unknown-linux-gnu" > /target.txt ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac

RUN rustup target add $(cat /target.txt)

WORKDIR /usr/src/app
COPY . .

RUN cargo build --release --target $(cat /target.txt)
RUN cp target/$(cat /target.txt)/release/task-api /task-api

FROM debian:bookworm-slim
COPY --from=builder /task-api /task-api
ENTRYPOINT ["/task-api"]
```

## 🧪 Testing Your Rust Container

### Build and Test Commands

```bash
# Build production image
docker build -t task-api-rust .

# Run container
docker run -d --name rust-api -p 8080:8080 task-api-rust

# Test API endpoints
curl http://localhost:8080/health
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Rust is blazingly fast!","description":"Zero-cost abstractions"}'

# Check metrics
curl http://localhost:8080/metrics

# Verify minimal image size
docker images | grep task-api-rust
# Should be very small (especially with distroless/scratch)

# Performance test
ab -n 10000 -c 100 http://localhost:8080/health
```

### Image Size Comparison

```bash
# Compare different base images
docker build -f Dockerfile -t rust-debian .
docker build -f Dockerfile.distroless -t rust-distroless .
docker build -f Dockerfile.scratch -t rust-scratch .

docker images | grep rust-
# rust-debian     ~100MB
# rust-distroless ~20MB
# rust-scratch    ~10MB
```

## 🐛 Rust Container Troubleshooting

### Common Issues & Solutions

#### Issue 1: "Binary not found"

```bash
# Problem: Wrong architecture
docker run rust-api
# exec: "/task-api": exec format error

# Solution: Build for correct platform
docker build --platform linux/amd64 -t rust-api .
```

#### Issue 2: "Dynamic linking errors"

```bash
# Problem: Missing shared libraries
docker logs rust-api
# error while loading shared libraries

# Solution: Use static linking
ENV RUSTFLAGS="-C target-feature=+crt-static"
```

#### Issue 3: "Permission denied"

```bash
# Problem: Binary not executable
# Solution: Ensure correct permissions
COPY --from=builder --chmod=755 /usr/src/app/target/release/task-api .
```

### Debugging Commands

```bash
# Check binary info
docker run --rm rust-api file /task-api

# Check dependencies
docker run --rm rust-api ldd /task-api

# Debug with shell (Debian-based images)
docker run -it --rm rust-api /bin/bash

# Check process info
docker exec rust-api ps aux
```

## ✅ Rust Quickstart Checklist

Congratulations! You've mastered Rust containerization:

- [ ] Actix-web Task API running in container
- [ ] Multi-stage builds for optimized images
- [ ] Static binary compilation working
- [ ] Minimal container images (distroless/scratch)
- [ ] Non-root user security implemented
- [ ] Prometheus metrics integrated
- [ ] Can debug Rust-specific container issues

## 🚀 Next Steps

Ready for multi-container applications? Continue to [Module 04: Docker Compose](../04-docker-compose/) where you'll add PostgreSQL and build a complete stack!

**Remember**: Rust's compile-time guarantees and zero-cost abstractions make it perfect for containerized microservices. These patterns scale to any Rust application - web servers, CLI tools, system services!

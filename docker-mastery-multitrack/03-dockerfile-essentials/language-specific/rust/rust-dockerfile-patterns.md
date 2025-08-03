# Rust Docker Implementation Guide 🦀

Apply Docker best practices to Rust applications with Actix-web, focusing on static binary compilation and ultra-minimal runtime images.

## 🎯 Rust-Specific Docker Advantages

### Static Binary Benefits

```dockerfile
# Rust compiles to static binaries - minimal runtime needed!
FROM scratch              # Literally empty image
COPY target/release/app .
ENTRYPOINT ["./app"]
```

### Cross-Compilation Support

```dockerfile
# Build for different architectures
RUN cargo build --release --target x86_64-unknown-linux-musl
```

## 📁 Complete Rust Dockerfile Templates

### Basic Single-Stage (Development)

```dockerfile
FROM rust:1.75

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy source code
COPY --chown=appuser:appuser . .

# Build application
RUN cargo build --release

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["./target/release/task-api"]
```

### Production Multi-Stage (Static Binary)

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM rust:1.75 AS builder

# Install musl for static linking
RUN apt-get update && apt-get install -y \
    musl-tools \
    && rm -rf /var/lib/apt/lists/*

# Add musl target for static linking
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /build

# Copy manifests first for dependency caching
COPY Cargo.toml Cargo.lock ./

# Create dummy source to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release --target x86_64-unknown-linux-musl
RUN rm -rf src

# Copy real source code
COPY src ./src

# Build static binary
RUN cargo build --release --target x86_64-unknown-linux-musl

# ==========================================
# Stage 2: Minimal Runtime
# ==========================================
FROM debian:bookworm-slim AS runtime

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy static binary from builder
COPY --from=builder --chown=appuser:appuser /build/target/x86_64-unknown-linux-musl/release/task-api .

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["./task-api"]
```

### Ultra-Minimal (Scratch Base)

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM rust:1.75 AS builder

RUN apt-get update && apt-get install -y musl-tools
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /build

# Dependency caching
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release --target x86_64-unknown-linux-musl
RUN rm -rf src

# Build real application
COPY src ./src
RUN cargo build --release --target x86_64-unknown-linux-musl

# ==========================================
# Stage 2: Scratch Runtime (Ultra-minimal)
# ==========================================
FROM scratch AS runtime

# Copy static binary (no libc dependencies!)
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/task-api /task-api

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080

# No health check possible - no curl in scratch
ENTRYPOINT ["/task-api"]
```

### Alpine-based (Balance of Size and Features)

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM rust:1.75-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    openssl-dev \
    openssl-libs-static

WORKDIR /build

# Dependency caching
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Build real application
COPY src ./src
RUN cargo build --release

# ==========================================
# Stage 2: Alpine Runtime
# ==========================================
FROM alpine:3.19 AS runtime

# Install runtime dependencies
RUN apk add --no-cache curl ca-certificates

# Create non-root user (Alpine syntax)
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy binary from builder
COPY --from=builder --chown=appuser:appuser /build/target/release/task-api .

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["./task-api"]
```

## 🔧 Build & Run Commands

### Build Your Rust Application

```bash
# Single-stage development
docker build -t task-api:dev .

# Multi-stage production
docker build -f Dockerfile.multi -t task-api:prod .

# Scratch-based (ultra-minimal)
docker build -f Dockerfile.scratch -t task-api:scratch .

# Alpine-based
docker build -f Dockerfile.alpine -t task-api:alpine .
```

### Size Comparison

```bash
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep task-api

# Expected results:
# task-api:dev      ~1.8GB  (includes Rust toolchain)
# task-api:prod     ~80MB   (Debian slim + binary)
# task-api:scratch  ~15MB   (just binary + certs)
# task-api:alpine   ~25MB   (Alpine + binary)
```

### Run and Test

```bash
# Run production image
docker run -d -p 8080:8080 --name rust-api task-api:prod

# Test Actix-web endpoints
curl http://localhost:8080/api/tasks
curl http://localhost:8080/health

# Check binary info
docker exec rust-api file ./task-api
docker exec rust-api ldd ./task-api || echo "Static binary - no dependencies!"

# Cleanup
docker rm -f rust-api
```

## 🚀 Rust-Specific Optimizations

### Cargo Dependency Caching

```dockerfile
# This pattern caches dependencies separately from source
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release        # Cache dependencies
RUN rm -rf src                   # Remove dummy source
COPY src ./src                   # Copy real source
RUN cargo build --release        # Only rebuilds if source changed
```

### Cargo Build Optimizations

```dockerfile
# Enable all optimizations
ENV CARGO_BUILD_JOBS=4
RUN cargo build --release \
    --target x86_64-unknown-linux-musl \
    --config 'profile.release.opt-level=3' \
    --config 'profile.release.lto=true' \
    --config 'profile.release.codegen-units=1'
```

### Cross-Platform Builds

```dockerfile
# Support multiple architectures
FROM --platform=$BUILDPLATFORM rust:1.75 AS builder
ARG TARGETPLATFORM

RUN case $TARGETPLATFORM in \
    "linux/amd64") echo "x86_64-unknown-linux-musl" > /target.txt ;; \
    "linux/arm64") echo "aarch64-unknown-linux-musl" > /target.txt ;; \
    esac

RUN rustup target add $(cat /target.txt)
RUN cargo build --release --target $(cat /target.txt)
```

## 🐛 Rust-Specific Troubleshooting

### Issue 1: OpenSSL Linking Errors

```bash
error: failed to run custom build command for `openssl-sys`
```

**Solution**: Use rustls or static OpenSSL

```toml
# Cargo.toml - use rustls instead of OpenSSL
[dependencies]
actix-web = { version = "4", default-features = false, features = ["rustls"] }

# OR for static OpenSSL
openssl = { version = "0.10", features = ["vendored"] }
```

### Issue 2: Large Binary Size

```bash
# Binary is 50MB+ even with --release
```

**Solution**: Enable link-time optimization

```toml
# Cargo.toml
[profile.release]
opt-level = 3
lto = true
codegen-units = 1
panic = "abort"
strip = true
```

### Issue 3: Runtime Errors with Scratch

```bash
Error: No such file or directory
```

**Solution**: Ensure static linking

```bash
# Check if binary is static
docker run --rm -v $(pwd)/target:/target alpine:3.19 ldd /target/x86_64-unknown-linux-musl/release/task-api
# Should output: "not a dynamic executable"
```

### Issue 4: Missing CA Certificates

```bash
Error: certificate verify failed
```

**Solution**: Copy certificates to scratch image

```dockerfile
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
```

## 📊 Performance Comparison

### Build Time Optimization

```bash
# With dependency caching
time docker build -f Dockerfile.cached -t test:cached .

# Without caching
time docker build -f Dockerfile.nocache -t test:nocache .

# Expect 70-80% build time reduction with caching
```

### Runtime Performance

```bash
# Memory usage (Rust is very efficient)
docker stats task-api --no-stream

# Binary size analysis
docker run --rm task-api:scratch du -h /task-api

# Startup time (should be <1 second)
time docker run --rm task-api:prod curl -f http://localhost:8080/health
```

## ✅ Rust Implementation Checklist

- [ ] Multi-stage build reduces image size by 95%+
- [ ] Static binary compilation successful
- [ ] Cargo dependency caching implemented
- [ ] Non-root user configured (when not using scratch)
- [ ] Actix-web health endpoint working
- [ ] Binary starts in <1 second
- [ ] SSL/TLS certificates available for HTTPS

## 🔗 Actix-web + Docker Best Practices

### Recommended Project Structure

```
src/
├── main.rs             # Application entry point
├── lib.rs              # Library root
├── handlers/
│   └── tasks.rs        # Route handlers
├── models/
│   └── task.rs         # Data models
└── Cargo.toml          # Dependencies
```

### Sample Actix-web Task API

```rust
// src/main.rs
use actix_web::{web, App, HttpResponse, HttpServer, Result};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    service: String,
}

#[derive(Serialize, Deserialize)]
struct TasksResponse {
    tasks: Vec<String>,
    total: usize,
}

async fn health() -> Result<HttpResponse> {
    Ok(HttpResponse::Ok().json(HealthResponse {
        status: "healthy".to_string(),
        service: "task-api".to_string(),
    }))
}

async fn get_tasks() -> Result<HttpResponse> {
    Ok(HttpResponse::Ok().json(TasksResponse {
        tasks: vec![],
        total: 0,
    }))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/health", web::get().to(health))
            .route("/api/tasks", web::get().to(get_tasks))
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
```

### Cargo.toml Configuration

```toml
[package]
name = "task-api"
version = "0.1.0"
edition = "2021"

[dependencies]
actix-web = "4"
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
panic = "abort"
strip = true
```

Ready for multi-service orchestration? Proceed to [Module 04: Docker Compose](../../04-docker-compose/) to connect your Rust API with PostgreSQL and build the complete monitoring stack!

---

**Remember**: Rust's static compilation makes it uniquely suited for minimal Docker images. These patterns work for any Rust web framework - Actix, Axum, Warp, or Rocket!

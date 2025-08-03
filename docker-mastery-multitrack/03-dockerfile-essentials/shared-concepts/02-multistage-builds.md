# Part B: Multi-stage Builds - Production Optimization ⚡

Master the production-grade technique that reduces image sizes by 50-70% while improving security. Multi-stage builds separate build tools from runtime environments.

## 🎯 Learning Outcomes

- ✅ Understand the problem with single-stage builds
- ✅ Create multi-stage Dockerfiles for any language
- ✅ Implement dependency caching for faster rebuilds
- ✅ Use distroless images for maximum security
- ✅ Measure and optimize image sizes

## 🚨 The Problem: Bloated Images

### Single-Stage Build (DON'T DO THIS)

```dockerfile
# BAD: Everything in one stage
FROM python:3.12
RUN apt-get update && apt-get install -y build-essential git
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN python setup.py build
CMD ["python", "app.py"]
```

**Problems:**

- ❌ **Huge size**: 800MB+ (includes build tools, git, etc.)
- ❌ **Security risk**: Build tools in production
- ❌ **Slow**: Downloads everything every time
- ❌ **Bloated**: Source code and build artifacts

### Multi-Stage Solution

```dockerfile
# GOOD: Separate build and runtime
# Stage 1: Build Environment
FROM python:3.12 AS builder
RUN apt-get update && apt-get install -y build-essential
WORKDIR /build
COPY requirements.txt .
RUN pip install -r requirements.txt --target /packages
COPY src/ ./src/

# Stage 2: Runtime Environment
FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=builder /packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /build/src ./src
CMD ["python", "src/app.py"]
```

**Benefits:**

- ✅ **60% smaller**: ~300MB vs 800MB
- ✅ **More secure**: No build tools in final image
- ✅ **Faster deploys**: Smaller images transfer faster
- ✅ **Cleaner**: Only runtime dependencies

## 🏗️ Multi-Stage Patterns by Language

### Python: Dependencies + Application

```dockerfile
# ========================================
# Stage 1: Build Dependencies
# ========================================
FROM python:3.12 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Install Python packages to a target directory
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /packages

# Build application if needed
COPY setup.py pyproject.toml ./
COPY src/ ./src/
RUN python setup.py build || true  # if you have a build step

# ========================================
# Stage 2: Runtime Environment
# ========================================
FROM python:3.12-slim AS runtime

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy packages from builder
COPY --from=builder --chown=appuser:appuser /packages /usr/local/lib/python3.12/site-packages

# Copy application code
COPY --from=builder --chown=appuser:appuser /build/src ./src

USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["python", "src/app.py"]
```

### Java: Compilation + Runtime

```dockerfile
# ========================================
# Stage 1: Build Environment
# ========================================
FROM maven:3.8.6-openjdk-17-slim AS builder

WORKDIR /build

# Copy POM first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# ========================================
# Stage 2: Runtime Environment
# ========================================
FROM openjdk:17-jre-slim AS runtime

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy only the JAR file (not source, not Maven)
COPY --from=builder --chown=spring:spring /build/target/*.jar app.jar

USER spring:spring
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Rust: Compilation + Minimal Runtime

```dockerfile
# ========================================
# Stage 1: Build Environment
# ========================================
FROM rust:1.75 AS builder

WORKDIR /build

# Copy manifests first for dependency caching
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build release binary
RUN cargo build --release

# ========================================
# Stage 2: Minimal Runtime
# ========================================
FROM debian:bookworm-slim AS runtime

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy only the binary
COPY --from=builder --chown=appuser:appuser /build/target/release/task-api .

USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["./task-api"]
```

## 🚀 Advanced: Distroless Images

For **maximum security**, use Google's distroless images:

```dockerfile
# ========================================
# Stage 1: Build (same as before)
# ========================================
FROM maven:3.8.6-openjdk-17-slim AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# ========================================
# Stage 2: Distroless Runtime (Ultra-secure)
# ========================================
FROM gcr.io/distroless/java17-debian11 AS runtime

# Copy JAR (distroless runs as non-root by default)
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080
# Note: No health check possible - no curl in distroless
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Distroless Benefits:**

- 🔒 **Ultra-secure**: No shell, no package manager
- 📦 **Tiny**: ~180MB vs 300MB
- 🛡️ **Minimal attack surface**: Only your app + runtime

**Distroless Limitations:**

- 🚫 No debugging tools
- 🚫 No health checks (must be external)
- 🚫 No shell for troubleshooting

## ⚡ Dependency Caching Strategy

### The Secret: Layer Order Matters

```dockerfile
# ❌ BAD: Code changes invalidate dependency cache
COPY . .
RUN pip install -r requirements.txt

# ✅ GOOD: Dependencies cached separately
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/ ./src/
```

### Caching Demo

```bash
# First build - downloads everything
time docker build -t app:v1 .
# Real time: 2m 30s

# Change only application code
echo "# Modified" >> src/app.py

# Second build - uses cached dependencies
time docker build -t app:v2 .
# Real time: 15s (90% faster!)
```

### Language-Specific Caching

#### Python: requirements.txt First

```dockerfile
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/ ./src/
```

#### Java: pom.xml First

```dockerfile
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
```

#### Rust: Cargo.toml First

```dockerfile
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release --dependencies-only
COPY src ./src
```

#### Node.js: package.json First

```dockerfile
COPY package*.json ./
RUN npm ci --only=production
COPY src/ ./src/
```

## 📊 Size Comparison Exercise

Build and compare different approaches:

```bash
# Build single-stage (bloated)
docker build -f Dockerfile.single -t app:single .

# Build multi-stage (optimized)
docker build -f Dockerfile.multi -t app:multi .

# Build distroless (ultra-minimal)
docker build -f Dockerfile.distroless -t app:distroless .

# Compare sizes
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep app:
```

**Typical Results:**

```
REPOSITORY:TAG        SIZE
app:single           847MB    # ❌ Everything included
app:multi            312MB    # ✅ 63% smaller
app:distroless       189MB    # 🚀 78% smaller
```

## 🔍 Build Process Visualization

```
┌─────────────────────┐       ┌─────────────────────┐
│   Stage 1: BUILD   │  ───▶ │  Stage 2: RUNTIME   │
├─────────────────────┤       ├─────────────────────┤
│ • Full SDK/JDK      │       │ • JRE only          │
│ • Build tools       │       │ • Your app          │
│ • Dependencies      │       │ • Non-root user     │
│ • Source code       │       │ • Health checks     │
│ • Compilation       │       │ • Minimal OS        │
│ • ~600-800MB        │       │ • ~200-300MB        │
└─────────────────────┘       └─────────────────────┘
         │                             ↑
         └─── COPY --from=builder ──────┘
              (artifacts only)
```

## 🏋️ Hands-On Exercise: Optimize Your Task API

### Step 1: Measure Current Size

```bash
# Build your current single-stage image
docker build -t task-api:single .
docker images | grep task-api
```

### Step 2: Create Multi-Stage Version

Create `Dockerfile.multi`:

```dockerfile
# Choose your language pattern from above
# Implement the two-stage approach
# Measure the difference
```

### Step 3: Test Both Versions

```bash
# Test functionality (both should work)
docker run -d -p 8080:8080 --name test-single task-api:single
docker run -d -p 8081:8080 --name test-multi task-api:multi

curl http://localhost:8080/health
curl http://localhost:8081/health

docker rm -f test-single test-multi
```

### Step 4: Security Test

```bash
# Single-stage (likely has build tools)
docker run --rm task-api:single which gcc || echo "gcc not found"

# Multi-stage (should not have build tools)
docker run --rm task-api:multi which gcc || echo "gcc not found"
```

## 🐛 Common Multi-Stage Issues

### Issue 1: Missing Files

```bash
Error: No such file or directory: '/app/myfile'
```

**Solution**: Ensure you copy from the correct stage

```dockerfile
COPY --from=builder /build/myfile ./
```

### Issue 2: Wrong Architecture

```bash
exec format error
```

**Solution**: Match architectures between stages

```dockerfile
FROM --platform=$BUILDPLATFORM builder AS build
FROM --platform=$TARGETPLATFORM runtime
```

### Issue 3: Large Multi-Stage Images

```bash
# Still 600MB despite multi-stage?
```

**Solution**: Check if you're copying unnecessary files

```dockerfile
# BAD: Copies everything
COPY --from=builder /build .

# GOOD: Copies only needed artifacts
COPY --from=builder /build/target/app.jar .
```

## ✅ Multi-Stage Mastery Checklist

Before proceeding to language-specific implementations:

- [ ] Can you explain why multi-stage builds are more secure?
- [ ] Do you understand dependency caching strategy?
- [ ] Have you achieved 50%+ size reduction with your Task API?
- [ ] Can you build a distroless image?
- [ ] Do you know when to use single vs multi-stage?

## 🎯 When to Use Each Approach

### Single-Stage: Learning & Development

- Quick prototypes
- Learning new languages
- Development environments
- Simple scripts

### Multi-Stage: Production Applications

- Production deployments
- CI/CD pipelines
- Container registries
- Size-sensitive environments

### Distroless: Maximum Security

- Internet-facing applications
- Security-critical workloads
- Compliance requirements
- Kubernetes deployments

## 🚀 Next Steps

Mastered multi-stage builds? Time to apply these patterns to your specific language!

Choose your path:

- [Java Implementation](../language-specific/java/)
- [Python Implementation](../language-specific/python/)
- [Rust Implementation](../language-specific/rust/)

Each language guide shows how to adapt these Docker patterns to your specific technology stack while maintaining the same security and optimization principles.

---

**Remember**: Multi-stage builds are a Docker concept, not a language concept. These patterns work everywhere - Java, Python, Rust, Go, Node.js, and beyond!

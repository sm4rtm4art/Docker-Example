# Part A: Hot Reload & Live Development 🔥

Eliminate painful rebuild cycles! Transform your development workflow from "code → build → wait → test" (3 minutes) to "code → instant reload → test" (3 seconds).

## 🎯 Learning Outcomes

- ✅ Set up automatic code reload for Java, Python, and Rust
- ✅ Configure bind mounts for instant file synchronization
- ✅ Create development-specific Docker configurations
- ✅ Troubleshoot file permission and sync issues
- ✅ Achieve sub-3-second code-to-test cycles

## 🚨 The Development Pain: Slow Feedback Loops

### Traditional Docker Development (DON'T DO THIS)

```bash
# The painful cycle that drives developers away from Docker
vim src/main.py           # Edit code
docker build -t myapp .   # Rebuild entire image (60s)
docker run myapp          # Start container (15s)
curl localhost:8080       # Test change (3s)
# Total: 78 seconds per change! 😭
```

**Problems:**

- ❌ **Slow**: 1-3 minutes per change
- ❌ **Frustrating**: Breaks flow state
- ❌ **Inefficient**: Rebuilds unchanged dependencies
- ❌ **Productivity killer**: Developers avoid Docker

## 🔥 The Solution: Hot Reload Development

### Hot Reload Workflow (THE RIGHT WAY)

```bash
# The productive cycle that makes Docker invisible
vim src/main.py           # Edit code
# File automatically syncs into container (0.1s)
# Application automatically reloads (2s)
curl localhost:8080       # Test change immediately (3s)
# Total: 3 seconds per change! 🚀
```

**Benefits:**

- ✅ **Fast**: 2-3 seconds per change
- ✅ **Seamless**: Maintains flow state
- ✅ **Efficient**: No unnecessary rebuilds
- ✅ **Productive**: Docker becomes invisible

## 🏗️ Development Configuration Strategy

### Development vs Production Separation

Create two compose files for clean separation:

**docker-compose.yml** (Production):

```yaml
version: "3.8"
services:
  task-api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
```

**docker-compose.dev.yml** (Development):

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=development
    volumes:
      - ./src:/app/src:cached # Hot reload magic!
      - ./package.json:/app/package.json:ro
    command: ["npm", "run", "dev"] # Development command
```

**Usage:**

```bash
# Development mode
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production mode
docker-compose up
```

## 🐍 Python: FastAPI Hot Reload

### Step 1: Development Dockerfile

Create `Dockerfile.dev`:

```dockerfile
FROM python:3.12-slim

# Create non-root user for development
RUN useradd -m -u 1000 devuser

# Install development dependencies
RUN pip install --no-cache-dir fastapi uvicorn[standard] watchfiles

WORKDIR /app

# Switch to non-root user
USER devuser

# The source code will be mounted as a volume
# No COPY needed for development!

# Development command with hot reload
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload", "--reload-dir", "src"]
```

### Step 2: Development Compose Configuration

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      # Bind mount source code for hot reload
      - ./src:/app/src:cached
      - ./requirements.txt:/app/requirements.txt:ro
    environment:
      - PYTHONPATH=/app
      - PYTHONUNBUFFERED=1
    # Override for development
    command:
      [
        "uvicorn",
        "src.main:app",
        "--host",
        "0.0.0.0",
        "--port",
        "8080",
        "--reload",
      ]
```

### Step 3: Test Hot Reload

```bash
# Start development environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# In another terminal, test the API
curl http://localhost:8080/health

# Edit src/main.py, save the file
# Watch the logs - you'll see automatic reload!
```

## ☕ Java: Spring Boot DevTools

### Step 1: Add DevTools Dependency

**pom.xml**:

```xml
<dependencies>
    <!-- Your existing dependencies -->

    <!-- Development-only dependency -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <scope>runtime</scope>
        <optional>true</optional>
    </dependency>
</dependencies>
```

### Step 2: Development Dockerfile

Create `Dockerfile.dev`:

```dockerfile
FROM eclipse-temurin:21-jdk-alpine

# Create non-root user
RUN addgroup -g 1000 devuser && adduser -D -s /bin/sh -u 1000 -G devuser devuser

# Install Maven for development builds
RUN apk add --no-cache maven

WORKDIR /app

# Change ownership to devuser
RUN chown devuser:devuser /app
USER devuser

# Development command
CMD ["mvn", "spring-boot:run", "-Dspring-boot.run.jvmArguments='-Dspring.devtools.restart.enabled=true'"]
```

### Step 3: Development Compose Configuration

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      # Bind mount source for hot reload
      - ./src:/app/src:cached
      - ./pom.xml:/app/pom.xml:ro
      - ~/.m2:/home/devuser/.m2:cached # Maven cache
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - SPRING_DEVTOOLS_RESTART_ENABLED=true
```

## 🦀 Rust: Cargo Watch

### Step 1: Development Dockerfile

Create `Dockerfile.dev`:

```dockerfile
FROM rust:1.75-alpine

# Install development tools
RUN apk add --no-cache musl-dev
RUN cargo install cargo-watch

# Create non-root user
RUN addgroup -g 1000 devuser && adduser -D -s /bin/sh -u 1000 -G devuser devuser

WORKDIR /app
RUN chown devuser:devuser /app
USER devuser

# Development command with hot reload
CMD ["cargo", "watch", "-x", "run"]
```

### Step 2: Development Compose Configuration

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      # Bind mount source for hot reload
      - ./src:/app/src:cached
      - ./Cargo.toml:/app/Cargo.toml:ro
      - ./Cargo.lock:/app/Cargo.lock:ro
      - ~/.cargo/registry:/usr/local/cargo/registry:cached # Cargo cache
    environment:
      - RUST_LOG=debug
```

## 🔧 Troubleshooting Hot Reload Issues

### Issue 1: File Changes Not Detected

**Problem**: Code changes don't trigger reload

**Solutions**:

```bash
# Check if volumes are mounted correctly
docker-compose exec task-api ls -la /app/src

# Verify file ownership
docker-compose exec task-api ls -la /app/src/main.py

# Check container logs for file watcher errors
docker-compose logs -f task-api
```

### Issue 2: Permission Denied Errors

**Problem**: `permission denied` when writing files

**Solutions**:

```yaml
# Fix user ID matching
services:
  task-api:
    volumes:
      - ./src:/app/src:cached
    user: "${UID:-1000}:${GID:-1000}" # Match host user
```

Or set permissions explicitly:

```bash
# Before starting containers
sudo chown -R $USER:$USER ./src
chmod -R 755 ./src
```

### Issue 3: Slow File Sync on macOS/Windows

**Problem**: File changes take 5-10 seconds to sync

**Solutions**:

```yaml
# Use cached or delegated consistency for better performance
volumes:
  - ./src:/app/src:cached # Better for macOS
  - ./src:/app/src:delegated # Alternative option
```

## 🎯 Performance Optimization

### Volume Mount Strategies

```yaml
# Performance-optimized volume configuration
volumes:
  # Source code (frequent changes)
  - ./src:/app/src:cached

  # Dependencies (read-only, rare changes)
  - ./package.json:/app/package.json:ro
  - ./requirements.txt:/app/requirements.txt:ro

  # Cache directories (performance boost)
  - node_modules:/app/node_modules
  - ~/.pip:/root/.pip:cached
```

### Exclude Unnecessary Files

**.dockerignore** for development:

```
# Exclude files that shouldn't sync
node_modules
*.pyc
__pycache__
.git
.env
Dockerfile*
docker-compose*
```

## ✅ Hands-On Exercise: Speed Test Challenge

### Before: Measure Current Workflow

```bash
# Time a change cycle
time (
  echo "# Comment" >> src/main.py &&
  docker build -t task-api . &&
  docker run -d --name test-api -p 8080:8080 task-api &&
  sleep 2 &&
  curl -s http://localhost:8080/health &&
  docker rm -f test-api
)
```

### After: Set Up Hot Reload

1. Create `Dockerfile.dev` for your language
2. Create `docker-compose.dev.yml` with volumes
3. Start development environment
4. Make a change and measure response time

### Success Criteria

- [ ] Code changes appear in container within 1 second
- [ ] Application reloads automatically within 3 seconds
- [ ] Total feedback loop under 5 seconds
- [ ] No permission errors or sync issues

## 🎉 What You've Achieved

🚀 **Incredible productivity boost!** You've transformed Docker from a development roadblock into an invisible productivity enhancer. Your workflow now feels like native development with all the benefits of containerization!

**Next**: Master [Part B: Debugging in Containers](./02-debugging-containers.md) to troubleshoot issues effectively!

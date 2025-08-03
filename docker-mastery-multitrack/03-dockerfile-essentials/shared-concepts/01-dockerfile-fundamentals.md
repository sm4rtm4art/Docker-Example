# Part A: Dockerfile Fundamentals 🏗️

Master the essential Dockerfile instructions and security patterns that every developer needs to know, regardless of programming language.

## 🎯 Learning Outcomes

- ✅ Understand core Dockerfile instructions and their purpose
- ✅ Implement non-root user patterns for security
- ✅ Choose between Ubuntu and Alpine base images
- ✅ Optimize layer caching for faster builds
- ✅ Manage build context with .dockerignore

## 📚 Essential Dockerfile Instructions

### Core Instructions Reference

| Instruction  | Purpose               | Example                                         | When to Use                 |
| ------------ | --------------------- | ----------------------------------------------- | --------------------------- |
| `FROM`       | Base image            | `FROM python:3.12-slim`                         | Always first instruction    |
| `WORKDIR`    | Set working directory | `WORKDIR /app`                                  | Organize file structure     |
| `COPY`       | Copy files into image | `COPY src/ ./src/`                              | Add application code        |
| `RUN`        | Execute commands      | `RUN apt-get update && apt-get install -y curl` | Install dependencies        |
| `EXPOSE`     | Document port         | `EXPOSE 8080`                                   | Document network ports      |
| `USER`       | Set user              | `USER appuser`                                  | Security (non-root)         |
| `ENTRYPOINT` | Main command          | `ENTRYPOINT ["python", "app.py"]`               | Define how container starts |
| `CMD`        | Default arguments     | `CMD ["--port", "8080"]`                        | Provide default options     |

## 🛡️ Security-First: Non-Root Users

**Golden Rule**: Never run containers as root in production!

### Why Non-Root Matters

```bash
# BAD: Root user can escape container
docker run --rm -it ubuntu:latest /bin/bash
root@container:/# # Full root access = security risk!

# GOOD: Limited user permissions
docker run --rm -it --user 1000:1000 ubuntu:latest /bin/bash
I have no name!@container:/$ # Limited access = more secure
```

### Non-Root Patterns by OS

#### Ubuntu/Debian Pattern

```dockerfile
# Create group and user with specific IDs
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

# Switch to non-root user
USER appuser:appuser
```

#### Alpine Linux Pattern

```dockerfile
# Alpine uses different commands
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Switch to non-root user
USER appuser:appuser
```

#### Why Use Specific UIDs?

- **Consistency**: Same user ID across environments
- **Volume permissions**: Host volumes work correctly
- **Security**: Predictable user mapping

## 🖼️ Base Image Selection

### Ubuntu/Debian: Compatibility First

```dockerfile
FROM ubuntu:22.04
# OR
FROM python:3.12-slim  # Debian-based
```

**Pros:**

- 📦 Familiar package manager (apt-get)
- 🔧 More software available
- 🐚 bash shell included
- 🤝 Maximum compatibility

**Cons:**

- 📏 Larger size (~200-400MB)
- 🐌 More packages = more updates

**Use When:**

- Learning Docker
- Need specific packages
- Compatibility is critical
- Team familiarity

### Alpine Linux: Size Optimized

```dockerfile
FROM alpine:3.19
# OR
FROM python:3.12-alpine
```

**Pros:**

- 📦 Tiny size (~50-150MB)
- 🔒 Security-focused
- ⚡ Faster downloads
- 🛡️ Minimal attack surface

**Cons:**

- 🐚 ash shell (not bash)
- 📚 musl libc (not glibc)
- 🔧 Fewer packages available
- 🚫 Some compatibility issues

**Use When:**

- Production deployments
- Size matters
- Simple applications
- Performance critical

### Practical Example: Same App, Different Bases

```dockerfile
# Ubuntu Version (app-ubuntu)
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN groupadd -r appuser && useradd -r -g appuser appuser
COPY app.py /app/
USER appuser
ENTRYPOINT ["python", "/app/app.py"]

# Alpine Version (app-alpine)
FROM python:3.12-alpine
RUN apk add --no-cache curl
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser
COPY app.py /app/
USER appuser
ENTRYPOINT ["python", "/app/app.py"]
```

Compare sizes:

```bash
docker images | grep app-
# app-ubuntu    latest    245MB
# app-alpine    latest    156MB
```

## ⚡ Layer Caching Strategy

### Understanding Docker Layers

Each Dockerfile instruction creates a layer. Docker caches layers that haven't changed.

**Optimization Rule**: Put stable things first, changing things last.

### Optimal Dockerfile Order

```dockerfile
# 1. Base image (never changes)
FROM python:3.12-slim

# 2. System packages (rarely change)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 3. User creation (rarely changes)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 4. Working directory (rarely changes)
WORKDIR /app

# 5. Dependencies first (change less often than code)
COPY requirements.txt .
RUN pip install -r requirements.txt

# 6. Application code (changes frequently)
COPY src/ ./src/

# 7. Runtime configuration
USER appuser
EXPOSE 8080
ENTRYPOINT ["python", "src/app.py"]
```

### Cache Invalidation Demo

```bash
# First build - downloads everything
time docker build -t myapp:v1 .

# Change application code only
echo "# Modified" >> src/app.py

# Second build - much faster! (uses cached layers)
time docker build -t myapp:v2 .
```

## 📁 Build Context & .dockerignore

### What is Build Context?

The build context is all files/folders sent to Docker daemon:

```bash
docker build .
# Sends ENTIRE current directory to Docker!
```

### Managing Build Context

Create `.dockerignore` to exclude unnecessary files:

```dockerignore
# .dockerignore
.git
*.md
.env
node_modules/
__pycache__/
target/
.pytest_cache/
.coverage
*.log
```

### Why This Matters

**Without .dockerignore:**

```bash
Sending build context to Docker daemon  2.3GB
# Slow upload, large context
```

**With .dockerignore:**

```bash
Sending build context to Docker daemon  45MB
# Fast upload, focused context
```

## 🏗️ Hands-On Exercise: Secure Dockerfile

### Task: Containerize Your Task API

Create a secure Dockerfile for your Task API using these patterns:

#### Step 1: Choose Your Base

```dockerfile
# For compatibility (learning)
FROM python:3.12-slim

# OR for production (size)
FROM python:3.12-alpine
```

#### Step 2: Add System Dependencies

```dockerfile
# Ubuntu/Debian
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Alpine
RUN apk add --no-cache curl
```

#### Step 3: Create Non-Root User

```dockerfile
# Ubuntu/Debian
RUN groupadd -r taskuser && useradd -r -g taskuser -u 1000 taskuser

# Alpine
RUN addgroup -g 1000 taskuser && \
    adduser -D -u 1000 -G taskuser taskuser
```

#### Step 4: Application Setup

```dockerfile
WORKDIR /app

# Dependencies first (caching optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Code last (changes frequently)
COPY src/ ./src/

# Security and runtime
USER taskuser:taskuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["python", "src/app.py"]
```

### Step 5: Build and Test

```bash
# Build your secure image
docker build -t task-api:secure .

# Test security (should NOT be root)
docker run --rm task-api:secure whoami
# Output: taskuser (not root!)

# Test functionality
docker run -d -p 8080:8080 --name api-test task-api:secure
curl http://localhost:8080/health
docker rm -f api-test
```

## 🐛 Common Issues & Solutions

### Issue 1: Permission Denied

```bash
Error: [Errno 13] Permission denied: '/app'
```

**Solution**: Use `--chown` when copying files

```dockerfile
COPY --chown=taskuser:taskuser src/ ./src/
```

### Issue 2: Package Not Found (Alpine)

```bash
/bin/sh: curl: not found
```

**Solution**: Install missing packages

```dockerfile
RUN apk add --no-cache curl
```

### Issue 3: Large Build Context

```bash
Sending build context to Docker daemon  1.2GB
```

**Solution**: Add .dockerignore file

```dockerignore
.git
*.log
node_modules/
```

## ✅ Knowledge Check

Before proceeding to multi-stage builds:

1. **Security**: Can you create non-root users on Ubuntu and Alpine?
2. **Caching**: Do you understand why dependencies should be copied before code?
3. **Base Images**: Can you choose between Ubuntu and Alpine based on requirements?
4. **Build Context**: Have you created a .dockerignore file?

## 🚀 Next Steps

Ready for production optimization? Continue to [Part B: Multi-stage Builds](./02-multistage-builds.md) to learn how to create small, secure, production-ready images!

## ✅ Skills Check: Dockerfile Fundamentals

Test your Dockerfile mastery with these challenges:

### Core Instructions
- [ ] **Write a Dockerfile from scratch** without looking at examples
- [ ] **Use all basic instructions**: FROM, WORKDIR, COPY, RUN, CMD, EXPOSE
- [ ] **Explain the difference** between CMD and ENTRYPOINT
- [ ] **Create a non-root user** and switch to it

### Layer Optimization
- [ ] **Minimize layers** by combining RUN commands properly
- [ ] **Order instructions** for optimal caching (least → most changing)
- [ ] **Use .dockerignore** to exclude unnecessary files
- [ ] **Debug layer sizes** with `docker history`

### Best Practices
- [ ] **Pin base image versions** (not just `:latest`)
- [ ] **Clean up after installs** (remove package caches)
- [ ] **Use COPY instead of ADD** (unless you need ADD's features)
- [ ] **Set proper file ownership** with `--chown`

### Debugging Skills
- [ ] **Diagnose build failures** from error messages
- [ ] **Use build stages** for debugging (`docker build --target`)
- [ ] **Inspect image contents** without running
- [ ] **Understand build context** and its impact

### Real Scenarios
Can you create Dockerfiles for:
- [ ] **A Python web app** with requirements.txt
- [ ] **A Node.js app** with package.json
- [ ] **A static website** with nginx
- [ ] **A compiled language** (Go, Rust, Java)

**If you can do all these confidently, you're ready for multi-stage builds!** 🚀

---

**Remember**: These patterns work for ANY programming language. The Docker concepts are universal - only the specific commands inside change!

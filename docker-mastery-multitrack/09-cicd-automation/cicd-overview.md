# Module 09: CI/CD with Docker

> **Duration**: 2 hours  
> **Level**: Intermediate  
> **Prerequisites**: Modules 1-7 completed

## 🎯 Learning Outcomes

By the end of this module, you will:

1. **Automate Docker builds** in CI/CD pipelines
2. **Build multi-architecture images** for different platforms
3. **Scan for vulnerabilities** as part of CI
4. **Push to registries** securely
5. **Implement build caching** for faster pipelines

## 📚 Module Structure

### Part A: GitHub Actions & Docker (1 hour)

- Setting up Docker in GitHub Actions
- Building and testing containers
- Multi-stage builds in CI
- Caching strategies
- **Exercise**: Create your first Docker CI pipeline

### Part B: Multi-Architecture & Security (1 hour)

- Building for ARM and x86
- Using Docker Buildx
- Security scanning in CI
- Registry management
- **Exercise**: Build and push multi-arch images

## 🌟 Why This Module Matters

Manual builds don't scale. Whether you're deploying to cloud or on-premise, automated Docker builds are essential for:

- Consistent, reproducible builds
- Automatic security scanning
- Support for multiple platforms (ARM Macs, cloud ARM instances)
- Faster deployment cycles

## ⚡ Quick Preview

```yaml
# .github/workflows/docker.yml
name: Docker CI

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: myapp:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## 🌍 Multi-Architecture Deep Dive

### The Modern Reality: ARM vs x86

**The Problem**: M1/M2 Macs use ARM, most cloud uses x86

```bash
# This works on your M1 Mac:
docker build -t myapp .

# But fails in x86 cloud:
ERROR: exec /app: exec format error
```

### Understanding Platforms

```bash
# Check your current platform
docker version --format "{{.Server.Arch}}"

# See what platforms an image supports
docker manifest inspect nginx | grep architecture

# Available platforms
- linux/amd64    # Intel/AMD (most servers)
- linux/arm64    # M1/M2 Macs, ARM servers
- linux/arm/v7   # Raspberry Pi
- windows/amd64  # Windows containers
```

### Method 1: Docker Buildx (Multi-Platform)

```bash
# Create a builder
docker buildx create --name multiarch --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag your-registry/myapp:latest \
  --push .

# Local testing on different platform
docker buildx build \
  --platform linux/amd64 \
  --load \
  --tag myapp:amd64 .
```

### Method 2: Platform-Specific Builds

```yaml
# GitHub Actions: Build matrix
strategy:
  matrix:
    platform:
      - linux/amd64
      - linux/arm64

steps:
  - name: Build for ${{ matrix.platform }}
    run: |
      docker buildx build \
        --platform ${{ matrix.platform }} \
        --tag myapp:${{ matrix.platform }} \
        --push .
```

### Real CI/CD Example

```yaml
# .github/workflows/multi-arch.yml
name: Multi-Architecture Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Registry
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            myapp:latest
            myapp:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Platform-Specific Optimizations

```dockerfile
# Use different base images per platform
ARG TARGETPLATFORM
FROM --platform=$TARGETPLATFORM \
  $(test "$TARGETPLATFORM" = "linux/arm64" && echo "arm64v8/alpine:3.18" || echo "alpine:3.18")

# Platform-specific optimizations
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      echo "Optimizing for ARM64"; \
    else \
      echo "Optimizing for AMD64"; \
    fi
```

### Testing Multi-Arch Locally

```bash
# Test different architectures
docker run --platform linux/amd64 myapp
docker run --platform linux/arm64 myapp

# Emulation (slower but works)
docker buildx build --platform linux/arm64 --load -t myapp:arm64 .
docker run myapp:arm64  # Runs via emulation on x86
```

### Common Pitfalls & Solutions

```dockerfile
# PROBLEM: Hard-coded architecture
FROM amd64/alpine:3.18  # Breaks on ARM

# SOLUTION: Let Docker choose
FROM alpine:3.18

# PROBLEM: Architecture-specific binaries
ADD https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip

# SOLUTION: Use build args
ARG TARGETARCH
ADD https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_${TARGETARCH}.zip
```

## 📝 Note

This module provides essential multi-architecture patterns for modern deployments. The CI/CD automation content complements the existing monitoring and security modules.

## 🚀 Ready to Automate?

While the full content is being developed, you can explore:

- [Docker's official GitHub Actions](https://github.com/docker/build-push-action)
- [BuildKit features](https://docs.docker.com/build/buildkit/)
- [Multi-platform builds](https://docs.docker.com/build/building/multi-platform/)

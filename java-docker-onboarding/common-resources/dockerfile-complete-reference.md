# Complete Dockerfile Reference + Podman Guide 📚

This comprehensive guide covers every Dockerfile instruction, their options, best practices, and Podman alternatives.

## 🎯 Quick Navigation

- [Basic Instructions](#basic-instructions)
- [Advanced Instructions](#advanced-instructions)
- [Multi-stage Build Instructions](#multi-stage-build-instructions)
- [Security Best Practices](#security-best-practices)
- [Docker vs Podman Commands](#docker-vs-podman-commands)
- [Performance Optimization](#performance-optimization)

---

## 📋 Basic Instructions

### `FROM` - Base Image Selection

Specifies the base image for your Docker image.

**Syntax:**

```dockerfile
FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
```

**Examples:**

```dockerfile
# Basic usage
FROM openjdk:17-jdk-slim

# Specific platform (useful for M1 Macs)
FROM --platform=linux/amd64 openjdk:17-jdk-slim

# Multi-stage build naming
FROM openjdk:17-jdk-slim AS builder

# Using digest for immutability (production)
FROM openjdk@sha256:abc123...
```

**Java-specific Base Images:**
| Image | Size | Use Case | Pros | Cons |
|-------|------|----------|------|------|
| `openjdk:17-jdk` | ~680MB | Development | Full JDK, all tools | Large size |
| `openjdk:17-jdk-slim` | ~470MB | **Recommended** | Good balance | Missing some tools |
| `openjdk:17-jre-slim` | ~320MB | Runtime only | Smaller, secure | No development tools |
| `openjdk:17-alpine` | ~320MB | Minimal | Smallest | musl compatibility issues |
| `eclipse-temurin:17-jdk-alpine` | ~340MB | Alternative | OpenJDK build | Alpine limitations |

**Podman Equivalent:**

```bash
# Docker
docker build -t myapp .

# Podman (identical syntax)
podman build -t myapp .
```

---

### `WORKDIR` - Set Working Directory

Sets the working directory for subsequent instructions.

**Syntax:**

```dockerfile
WORKDIR /path/to/workdir
```

**Examples:**

```dockerfile
# Basic usage
WORKDIR /app

# Multiple levels (creates if doesn't exist)
WORKDIR /opt/mycompany/myapp

# Using environment variables
ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

# Relative paths (relative to previous WORKDIR)
WORKDIR /usr
WORKDIR src
WORKDIR app
# Result: /usr/src/app
```

**Best Practices:**

- ✅ Always use absolute paths
- ✅ Create meaningful directory structure
- ❌ Don't use `RUN cd /app` (doesn't persist)
- ✅ Use `/app` for simple applications
- ✅ Use `/opt/company/app` for enterprise patterns

---

### `COPY` vs `ADD` - File Operations

Copy files from build context to image.

#### `COPY` (Recommended)

**Syntax:**

```dockerfile
COPY [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
```

**Examples:**

```dockerfile
# Basic file copy
COPY app.jar /app/app.jar

# Copy with ownership (rootless security)
COPY --chown=spring:spring app.jar /app/

# Copy with permissions
COPY --chmod=755 startup.sh /app/

# Wildcard patterns
COPY target/*.jar /app/
COPY src/ /app/src/

# Multiple sources
COPY file1.txt file2.txt /app/

# Preserving directory structure
COPY src/main/resources/ /app/resources/
```

#### `ADD` (Use Sparingly)

**Syntax:**

```dockerfile
ADD [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
```

**Additional Features:**

```dockerfile
# Auto-extract tar archives
ADD myapp.tar.gz /app/

# Download from URL (not recommended)
ADD https://example.com/file.jar /app/

# ADD vs COPY decision matrix
# Use COPY: 99% of cases (simple, predictable)
# Use ADD: Only when you need auto-extraction
```

**Java-specific Examples:**

```dockerfile
# Spring Boot JAR
COPY target/myapp-*.jar app.jar

# Configuration files
COPY --chown=spring:spring application.yml /app/config/

# Multiple environments
COPY config/application-*.yml /app/config/
```

---

### `RUN` - Execute Commands

Execute commands during image build.

**Syntax:**

```dockerfile
# Shell form (uses /bin/sh -c)
RUN <command>

# Exec form (no shell processing)
RUN ["executable", "param1", "param2"]
```

**Layer Optimization Examples:**

```dockerfile
# ❌ Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# ✅ Good: Single layer
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ✅ Best: Multi-line for readability
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Package Manager Comparisons:**

**Ubuntu/Debian (apt):**

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Alpine (apk):**

```dockerfile
RUN apk add --no-cache \
        curl \
        ca-certificates
```

**User Management:**

```dockerfile
# Ubuntu/Debian
RUN groupadd -r spring && \
    useradd -r -g spring spring

# Alpine
RUN addgroup -g 1000 spring && \
    adduser -D -u 1000 -G spring spring
```

---

### `EXPOSE` - Document Ports

Documents which ports the container listens on.

**Syntax:**

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

**Examples:**

```dockerfile
# HTTP port
EXPOSE 8080

# Multiple ports
EXPOSE 8080 8443

# Specific protocol
EXPOSE 8080/tcp
EXPOSE 53/udp

# Debug port for Java
EXPOSE 5005

# Common Java application ports
EXPOSE 8080 8443 9090 5005
```

**Note:** `EXPOSE` is documentation only! Use `-p` flag when running:

```bash
# Docker
docker run -p 8080:8080 myapp

# Podman (identical)
podman run -p 8080:8080 myapp
```

---

### `ENV` - Environment Variables

Set environment variables.

**Syntax:**

```dockerfile
ENV <key>=<value> ...
ENV <key> <value>
```

**Examples:**

```dockerfile
# Single variable
ENV JAVA_HOME=/opt/java/openjdk

# Multiple variables (preferred)
ENV JAVA_HOME=/opt/java/openjdk \
    SPRING_PROFILES_ACTIVE=prod \
    SERVER_PORT=8080

# Java-specific variables
ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_CONFIG_LOCATION=/app/config/ \
    LOGGING_LEVEL_ROOT=INFO

# Using variables in subsequent instructions
ENV APP_HOME=/app
WORKDIR $APP_HOME
COPY app.jar $APP_HOME/
```

**Runtime Override:**

```bash
# Override at runtime
docker run -e SPRING_PROFILES_ACTIVE=dev myapp
podman run -e SPRING_PROFILES_ACTIVE=dev myapp
```

---

### `USER` - Security Context

Set user context for subsequent instructions.

**Syntax:**

```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```

**Security Examples:**

```dockerfile
# Create and use non-root user
RUN groupadd -r spring && useradd -r -g spring spring
USER spring

# Using UID/GID (more secure)
RUN groupadd -r spring && useradd -r -g spring spring
USER 1000:1000

# Switch back to root (if needed)
USER root
# Do privileged operations
USER spring

# Best practice for Java apps
RUN groupadd -r spring && \
    useradd -r -g spring spring && \
    mkdir -p /app && \
    chown spring:spring /app
USER spring:spring
WORKDIR /app
```

**Why Non-root Matters:**

- Container escape vulnerability mitigation
- Compliance requirements
- Principle of least privilege
- Kubernetes security policies

---

## 🎯 Entry Point Instructions

### `ENTRYPOINT` vs `CMD`

Understanding the difference is crucial!

#### `ENTRYPOINT` - Main Command

**Syntax:**

```dockerfile
# Exec form (recommended)
ENTRYPOINT ["executable", "param1", "param2"]

# Shell form
ENTRYPOINT command param1 param2
```

**Examples:**

```dockerfile
# Basic Java application
ENTRYPOINT ["java", "-jar", "app.jar"]

# With JVM options
ENTRYPOINT ["java", "-Xmx512m", "-jar", "app.jar"]

# Using shell script
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Spring Boot specific
ENTRYPOINT ["java", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", \
    "app.jar"]
```

#### `CMD` - Default Arguments

**Syntax:**

```dockerfile
# Exec form (recommended)
CMD ["executable","param1","param2"]

# As default parameters to ENTRYPOINT
CMD ["param1","param2"]

# Shell form
CMD command param1 param2
```

**Combination Examples:**

```dockerfile
# ENTRYPOINT + CMD pattern
ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["--spring.profiles.active=prod"]

# Runtime: docker run myapp --spring.profiles.active=dev
# Executes: java -jar app.jar --spring.profiles.active=dev
```

**Best Practices:**

```dockerfile
# ✅ Exec form for precise control
ENTRYPOINT ["java", "-jar", "app.jar"]

# ✅ Signal handling (for graceful shutdown)
ENTRYPOINT ["java", "-jar", "app.jar"]

# ❌ Shell form breaks signal forwarding
ENTRYPOINT java -jar app.jar
```

---

## 🏗️ Advanced Instructions

### `ARG` - Build Arguments

Pass variables at build time.

**Syntax:**

```dockerfile
ARG <name>[=<default value>]
```

**Examples:**

```dockerfile
# With default value
ARG JAR_FILE=target/*.jar

# Without default (must be provided)
ARG VERSION
ARG BUILD_DATE

# Using in instructions
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Build-time metadata
ARG BUILD_DATE
ARG VCS_REF
LABEL build-date=$BUILD_DATE
LABEL vcs-ref=$VCS_REF
```

**Build Command:**

```bash
# Docker
docker build --build-arg VERSION=1.2.3 --build-arg BUILD_DATE=$(date) -t myapp .

# Podman
podman build --build-arg VERSION=1.2.3 --build-arg BUILD_DATE=$(date) -t myapp .
```

### `LABEL` - Metadata

Add metadata to images.

**Syntax:**

```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

**Best Practices:**

```dockerfile
# Standard labels (OCI specification)
LABEL org.opencontainers.image.title="My Java App"
LABEL org.opencontainers.image.description="Spring Boot REST API"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="your-email@company.com"
LABEL org.opencontainers.image.url="https://github.com/company/repo"
LABEL org.opencontainers.image.source="https://github.com/company/repo"
LABEL org.opencontainers.image.vendor="Your Company"
LABEL org.opencontainers.image.licenses="MIT"

# Custom labels
LABEL maintainer="team@company.com"
LABEL environment="production"
LABEL java.version="17"
LABEL spring-boot.version="3.2.0"
```

**Viewing Labels:**

```bash
# Docker
docker inspect myapp | jq '.[0].Config.Labels'

# Podman
podman inspect myapp | jq '.[0].Config.Labels'
```

### `VOLUME` - Mount Points

Declare mount points for external volumes.

**Syntax:**

```dockerfile
VOLUME ["/data"]
VOLUME /var/log /var/db
```

**Examples:**

```dockerfile
# Database data
VOLUME /var/lib/mysql

# Application logs
VOLUME /app/logs

# Configuration directory
VOLUME /app/config

# Multiple volumes
VOLUME ["/app/data", "/app/logs", "/app/config"]
```

**Runtime Usage:**

```bash
# Docker
docker run -v /host/data:/app/data myapp

# Podman
podman run -v /host/data:/app/data myapp

# Named volumes
docker volume create myapp-data
docker run -v myapp-data:/app/data myapp
```

### `HEALTHCHECK` - Container Health

Monitor container health.

**Syntax:**

```dockerfile
HEALTHCHECK [OPTIONS] CMD command
HEALTHCHECK NONE
```

**Options:**

- `--interval=DURATION` (default: 30s)
- `--timeout=DURATION` (default: 30s)
- `--start-period=DURATION` (default: 0s)
- `--retries=N` (default: 3)

**Examples:**

```dockerfile
# Basic HTTP health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Custom health script
COPY health-check.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.sh
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD ["/usr/local/bin/health-check.sh"]

# Disable inherited health check
HEALTHCHECK NONE
```

**Health Check Script Example:**

```bash
#!/bin/bash
# health-check.sh
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)
if [ $response = "200" ]; then
    exit 0
else
    exit 1
fi
```

---

## 🔄 Multi-stage Build Instructions

### `FROM ... AS` - Named Stages

Create named build stages for optimization.

**Complete Example:**

```dockerfile
# Build stage
FROM maven:3.8.6-openjdk-17-slim AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim AS runtime
WORKDIR /app

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Copy JAR from build stage
COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar

USER spring:spring
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### `COPY --from` - Cross-stage Copying

Copy files from other stages or images.

**Examples:**

```dockerfile
# From named stage
COPY --from=builder /app/target/*.jar app.jar

# From external image
COPY --from=nginx:alpine /etc/nginx/nginx.conf /etc/nginx/

# From previous stage with ownership
COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar

# Multiple files
COPY --from=builder /app/target/*.jar /app/config/ ./
```

---

## 🛡️ Security Best Practices

### 1. **Non-root Users**

```dockerfile
# ✅ Always create and use non-root user
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# ✅ Use specific UID/GID for consistency
RUN groupadd -r -g 1000 spring && useradd -r -u 1000 -g spring spring
USER 1000:1000
```

### 2. **Minimal Base Images**

```dockerfile
# ✅ Use slim/alpine variants
FROM openjdk:17-jre-slim

# ✅ Distroless for maximum security (Google)
FROM gcr.io/distroless/java17-debian11
```

### 3. **Package Management**

```dockerfile
# ✅ Clean package caches
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ✅ Alpine equivalent
RUN apk add --no-cache curl
```

### 4. **File Permissions**

```dockerfile
# ✅ Explicit permissions
COPY --chmod=644 config.yml /app/
COPY --chmod=755 startup.sh /app/

# ✅ Change ownership
COPY --chown=spring:spring app.jar /app/
```

---

## 🐳 Docker vs Podman Commands

### Build Commands

```bash
# Build image
docker build -t myapp .
podman build -t myapp .

# Build with args
docker build --build-arg VERSION=1.0 -t myapp .
podman build --build-arg VERSION=1.0 -t myapp .

# Multi-platform build (Docker with buildx)
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
# Podman equivalent
podman build --platform linux/amd64,linux/arm64 -t myapp .
```

### Run Commands

```bash
# Basic run
docker run -p 8080:8080 myapp
podman run -p 8080:8080 myapp

# With environment variables
docker run -e SPRING_PROFILES_ACTIVE=dev -p 8080:8080 myapp
podman run -e SPRING_PROFILES_ACTIVE=dev -p 8080:8080 myapp

# With volumes
docker run -v /host/data:/app/data -p 8080:8080 myapp
podman run -v /host/data:/app/data -p 8080:8080 myapp
```

### Image Management

```bash
# List images
docker images
podman images

# Remove image
docker rmi myapp
podman rmi myapp

# Push to registry
docker push myregistry/myapp
podman push myregistry/myapp
```

### Key Podman Advantages

- **Daemonless**: No background daemon required
- **Rootless**: Run containers without root privileges
- **Pod Support**: Kubernetes-style pod grouping
- **SystemD Integration**: Better service management
- **Security**: Better default security posture

### Podman-specific Features

```bash
# Generate Kubernetes YAML
podman generate kube myapp > myapp-k8s.yaml

# Create pods (like Kubernetes)
podman pod create --name mypod -p 8080:8080
podman run --pod mypod myapp

# Generate systemd unit files
podman generate systemd --name myapp > myapp.service
```

---

## ⚡ Performance Optimization

### 1. **Layer Caching**

```dockerfile
# ✅ Copy dependencies first (changes less frequently)
COPY pom.xml .
RUN mvn dependency:go-offline

# ✅ Copy source code last (changes frequently)
COPY src ./src
RUN mvn package -DskipTests
```

### 2. **Multi-stage Optimization**

```dockerfile
# Minimize final image size
FROM maven:3.8.6-openjdk-17-slim AS builder
# ... build steps ...

FROM openjdk:17-jre-slim
COPY --from=builder /app/target/*.jar app.jar
# Final image only contains runtime + JAR
```

### 3. **.dockerignore**

```dockerignore
# Exclude unnecessary files
.git
.gitignore
*.md
.idea/
.vscode/
target/
node_modules/
*.log
```

### 4. **Base Image Selection**

| Priority | Image Type | Size     | Security | Compatibility |
| -------- | ---------- | -------- | -------- | ------------- |
| 1st      | Distroless | Smallest | Highest  | Limited       |
| 2nd      | Alpine     | Small    | High     | Good          |
| 3rd      | Slim       | Medium   | Good     | Best          |
| 4th      | Full       | Large    | Lower    | Complete      |

---

## 📚 Complete Example: Production-Ready Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
# Production-ready Spring Boot Dockerfile

ARG JAVA_VERSION=17
ARG MAVEN_VERSION=3.8.6

# Build stage
FROM maven:${MAVEN_VERSION}-openjdk-${JAVA_VERSION}-slim AS builder

# Set build metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL stage=builder

WORKDIR /app

# Copy POM first for better caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -B && \
    java -Djarmode=layertools -jar target/*.jar extract

# Runtime stage
FROM openjdk:${JAVA_VERSION}-jre-slim AS runtime

# Install security updates and required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r -g 1000 spring && \
    useradd -r -u 1000 -g spring spring

WORKDIR /app

# Copy layers from builder (Spring Boot layered approach)
COPY --from=builder --chown=spring:spring /app/dependencies/ ./
COPY --from=builder --chown=spring:spring /app/spring-boot-loader/ ./
COPY --from=builder --chown=spring:spring /app/snapshot-dependencies/ ./
COPY --from=builder --chown=spring:spring /app/application/ ./

# Set metadata
LABEL org.opencontainers.image.title="Spring Boot Java App"
LABEL org.opencontainers.image.description="Production-ready Spring Boot application"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.vendor="Your Company"
LABEL org.opencontainers.image.authors="team@company.com"

# Security: switch to non-root user
USER spring:spring

# Network
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM tuning for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Application entry point
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
```

**Build Command:**

```bash
docker build \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg VCS_REF=$(git rev-parse HEAD) \
    --build-arg VERSION=1.0.0 \
    -t myapp:latest .

# Podman equivalent
podman build \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg VCS_REF=$(git rev-parse HEAD) \
    --build-arg VERSION=1.0.0 \
    -t myapp:latest .
```

---

## 🎯 Quick Reference

### Most Common Instructions

```dockerfile
FROM openjdk:17-jre-slim
WORKDIR /app
COPY app.jar .
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring
EXPOSE 8080
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Container Engine Commands

```bash
# Build
docker/podman build -t myapp .

# Run
docker/podman run -d -p 8080:8080 --name myapp-container myapp

# Debug
docker/podman exec -it myapp-container /bin/sh

# Logs
docker/podman logs -f myapp-container
```

This reference should be your go-to guide for all Dockerfile questions throughout the learning modules! 🚀

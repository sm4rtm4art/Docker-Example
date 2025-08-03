# Part C: Minimal & Secure Images

> **Duration**: 1 hour  
> **Focus**: Creating the smallest, most secure container images possible

## 🎯 Learning Objectives

By the end of this section, you will:

- Build distroless images for production
- Create scratch-based containers
- Scan and fix security vulnerabilities
- Reduce image size by 90%+

## 📦 The Problem: Bloated, Vulnerable Images

```bash
# Typical "bad" image
$ docker images
REPOSITORY    TAG       SIZE
bloated-app   latest    1.2GB   # 😱

$ docker scout cves bloated-app
✗ 247 vulnerabilities found
✗ 38 HIGH severity
✗ 12 CRITICAL severity
```

## 🎯 Strategy 1: Distroless Images

### What is Distroless?

- No shell, no package manager, no utilities
- Only your app and runtime dependencies
- Significantly smaller attack surface

### Python Distroless Example

```dockerfile
# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

COPY . .

# Runtime stage - distroless
FROM gcr.io/distroless/python3-debian12

COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

WORKDIR /app
ENV PATH=/root/.local/bin:$PATH

CMD ["python", "main.py"]
```

### Java Distroless Example

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# Runtime stage - distroless
FROM gcr.io/distroless/java17-debian12

COPY --from=builder /app/target/app.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 🚀 Strategy 2: Scratch Images (Ultimate Minimal)

### Rust Static Binary Example

```dockerfile
# Build stage
FROM rust:alpine AS builder

# Install musl for static linking
RUN apk add --no-cache musl-dev

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build static binary
RUN cargo build --release --target x86_64-unknown-linux-musl

# Runtime stage - literally nothing!
FROM scratch

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/app /app

ENTRYPOINT ["/app"]
```

### Go Scratch Example

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o app .

# Runtime stage
FROM scratch

COPY --from=builder /app/app /app

ENTRYPOINT ["/app"]
```

## 🔒 Security Scanning & Fixes

### 1. Scan with Docker Scout

```bash
# Enable Scout
$ docker scout quickview myapp:latest

# Detailed CVE report
$ docker scout cves myapp:latest

# Compare versions
$ docker scout compare myapp:latest myapp:previous
```

### 2. Common Vulnerabilities & Fixes

```dockerfile
# BAD: Old base image with vulnerabilities
FROM ubuntu:20.04

# GOOD: Updated base image
FROM ubuntu:22.04

# BETTER: Minimal base
FROM ubuntu:22.04-minimal

# BEST: Distroless
FROM gcr.io/distroless/base-debian12
```

## 📏 Size Optimization Techniques

### 1. Multi-stage Build Optimization

```dockerfile
# BAD: Everything in one stage (1.2GB)
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]

# GOOD: Multi-stage (120MB)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "index.js"]
```

### 2. Layer Optimization

```dockerfile
# BAD: Many layers, poor caching
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# GOOD: Single layer, better caching
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git && \
    rm -rf /var/lib/apt/lists/*
```

## 🎯 Exercise: Shrink That Image!

### Challenge: Reduce a 1GB Python Image to <100MB

Start with this bloated image:

```dockerfile
# bloated/Dockerfile (1GB+)
FROM python:3.12

RUN apt-get update && apt-get install -y \
    gcc \
    git \
    vim \
    curl \
    build-essential

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "app.py"]
```

Your mission: Make it minimal!

### Solution: Distroless + Multi-stage

```dockerfile
# minimal/Dockerfile (<100MB)
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM gcr.io/distroless/python3-debian12

COPY --from=builder /root/.local /root/.local
COPY app.py /app/

WORKDIR /app
ENV PATH=/root/.local/bin:$PATH

CMD ["python", "app.py"]
```

## 📊 Image Size Comparison

| Approach         | Size      | Security     | Debugging |
| ---------------- | --------- | ------------ | --------- |
| Full OS (Ubuntu) | 500MB-2GB | Many CVEs    | Easy      |
| Alpine           | 50-200MB  | Fewer CVEs   | Moderate  |
| Distroless       | 20-100MB  | Minimal CVEs | Hard      |
| Scratch          | 5-50MB    | No CVEs      | Very Hard |

## 🛠️ Debugging Distroless Containers

Since there's no shell:

```bash
# Option 1: Debug container
$ docker debug mycontainer  # Docker Desktop feature

# Option 2: Copy binary out
$ docker cp mycontainer:/app/myapp ./myapp-debug

# Option 3: Ephemeral debug container
$ kubectl debug -it mypod --image=busybox --target=mycontainer
```

## 🎓 Key Takeaways

1. **Smaller = More Secure** - Less attack surface
2. **Distroless for Production** - No unnecessary tools
3. **Scan Everything** - Make security scanning part of CI/CD
4. **Multi-stage Builds** - Separate build from runtime
5. **Test Thoroughly** - Minimal images can break assumptions

## ✅ Module 07 Complete!

You now have the skills to create production-grade containers that are:

- ✅ Health-checked and gracefully shutting down
- ✅ Resource-constrained and monitored
- ✅ Minimal and secure

Ready for Module 08: The Monitoring Stack! 🚀

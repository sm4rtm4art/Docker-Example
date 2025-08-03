# Module 02: Dockerfile Basics 🐳

Welcome to your first containerization experience! In this module, you'll transform your Spring Boot application into a portable, deployable container that runs anywhere.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Write Dockerfiles to containerize Java applications
- ✅ Build and manage Docker images effectively
- ✅ Choose appropriate base images for different scenarios
- ✅ Optimize image size and build performance
- ✅ Implement security best practices (non-root users)
- ✅ Run and manage containers from your images
- ✅ Debug common containerization issues

## 📚 What You'll Build

Two versions of your Spring Boot container:

1. **Ubuntu-based image**: Full-featured, maximum compatibility
2. **Alpine-based image**: Lightweight, security-focused

You'll understand the trade-offs and when to use each.

## ⏱️ Time Investment

- **Reading & Understanding**: 20 minutes
- **Building Images**: 15 minutes
- **Running & Testing**: 15 minutes
- **Exercises**: 20 minutes
- **Troubleshooting**: 10 minutes
- **Total**: ~1.5 hours

## 📋 Prerequisites

- Completed [Module 01: Java in Eclipse](../01-java-in-eclipse/java-setup-guide.md)
- Docker Desktop running (or Podman)
- Spring Boot JAR built from Module 01
- Basic command line familiarity

## 📁 Module Structure

```
02-dockerfile-basics/
├── src/                    # Spring Boot source (copied from Module 01)
├── pom.xml                 # Maven configuration
├── Dockerfile              # Ubuntu/Debian-based image
├── Dockerfile.alpine       # Alpine Linux-based image
├── .dockerignore          # Files to exclude from build context
└── README.md              # This file
```

## 🏗️ Understanding Dockerfiles

A Dockerfile is a text document containing instructions to build a Docker image. Each instruction creates a layer in the image.

### Key Instructions

| Instruction  | Purpose               | Example                                  |
| ------------ | --------------------- | ---------------------------------------- |
| `FROM`       | Base image            | `FROM openjdk:17-jdk-slim`               |
| `WORKDIR`    | Set working directory | `WORKDIR /app`                           |
| `COPY`       | Copy files into image | `COPY app.jar app.jar`                   |
| `RUN`        | Execute commands      | `RUN apt-get update`                     |
| `EXPOSE`     | Document port         | `EXPOSE 8080`                            |
| `USER`       | Set user              | `USER spring`                            |
| `ENTRYPOINT` | Main command          | `ENTRYPOINT ["java", "-jar", "app.jar"]` |
| `CMD`        | Default arguments     | `CMD ["--spring.profiles.active=prod"]`  |

## 🚀 Building Your First Docker Image

### Step 1: Build the Spring Boot JAR

```bash
cd 02-dockerfile-basics
mvn clean package

# Verify JAR was created
ls -la target/*.jar
```

### Step 2: Build Ubuntu-based Image

```bash
# Build the image
docker build -t docker-demo:ubuntu .

# List images
docker images | grep docker-demo

# Inspect image details
docker inspect docker-demo:ubuntu
```

### Step 3: Build Alpine-based Image

```bash
# Build using Alpine Dockerfile
docker build -f Dockerfile.alpine -t docker-demo:alpine .

# Compare image sizes
docker images | grep docker-demo
```

## 🏃 Running Containers

### Basic Run Commands

```bash
# Run Ubuntu-based container
docker run -p 8080:8080 docker-demo:ubuntu

# Run in detached mode with name
docker run -d -p 8080:8080 --name demo-ubuntu docker-demo:ubuntu

# Run Alpine-based container on different port
docker run -d -p 8081:8080 --name demo-alpine docker-demo:alpine
```

### Verify Applications

```bash
# Check Ubuntu-based app
curl http://localhost:8080/
curl http://localhost:8080/api/tasks

# Check Alpine-based app
curl http://localhost:8081/
curl http://localhost:8081/api/tasks

# View logs
docker logs demo-ubuntu
docker logs -f demo-alpine  # Follow logs
```

## 🔍 Ubuntu vs Alpine Comparison

### Ubuntu/Debian (openjdk:17-jdk-slim)

- **Base Size**: ~470MB
- **Package Manager**: apt-get
- **Shell**: bash
- **C Library**: glibc
- **Pros**: More compatible, familiar tools
- **Cons**: Larger size

### Alpine Linux (openjdk:17-jdk-alpine)

- **Base Size**: ~320MB
- **Package Manager**: apk
- **Shell**: sh (ash)
- **C Library**: musl
- **Pros**: Smaller, security-focused
- **Cons**: Potential compatibility issues

### Practical Comparison

```bash
# Check image sizes
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep docker-demo

# Explore Ubuntu container
docker run -it --rm docker-demo:ubuntu /bin/bash
$ apt-get update && apt-get install -y curl
$ curl --version
$ exit

# Explore Alpine container
docker run -it --rm docker-demo:alpine /bin/sh
$ apk add --no-cache curl
$ curl --version
$ exit
```

## 🛡️ Security Best Practices

### 1. Non-root User

Both Dockerfiles create and use a non-root user:

```dockerfile
# Ubuntu approach
RUN groupadd -r spring && useradd -r -g spring spring

# Alpine approach
RUN addgroup -g 1000 spring && adduser -D -u 1000 -G spring spring
```

Verify:

```bash
# Check user in running container
docker exec demo-ubuntu whoami
docker exec demo-alpine id
```

### 2. Minimal Base Images

Using `-slim` or `-alpine` variants reduces attack surface:

- Fewer packages = fewer vulnerabilities
- Smaller size = faster deployment

## 🔧 Docker Commands Cheat Sheet

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi docker-demo:ubuntu

# Remove unused images
docker image prune

# Tag image
docker tag docker-demo:ubuntu myrepo/docker-demo:latest
```

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop demo-ubuntu

# Remove container
docker rm demo-ubuntu

# Stop and remove
docker rm -f demo-alpine
```

### Debugging Commands

```bash
# Execute command in running container
docker exec -it demo-ubuntu /bin/bash

# View container logs
docker logs --tail 50 -f demo-ubuntu

# Inspect container
docker inspect demo-ubuntu

# View resource usage
docker stats demo-ubuntu
```

## 🎯 Hands-on Exercises

### Exercise 1: Modify and Rebuild

1. Change the welcome message in `HomeController.java`
2. Rebuild the JAR: `mvn clean package`
3. Rebuild the Docker image
4. Run and verify the change

### Exercise 2: Add Health Check

Add to Dockerfile:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
```

Note: Requires curl in the image!

### Exercise 3: Environment Variables

```bash
# Run with custom port
docker run -d -p 9090:9090 -e SERVER_PORT=9090 docker-demo:ubuntu

# Run with custom profile
docker run -d -p 8080:8080 -e SPRING_PROFILES_ACTIVE=dev docker-demo:alpine
```

## 🐛 Troubleshooting & Explore

### Common Issues

1. **"Cannot find target/\*.jar"**

   - Run `mvn clean package` first
   - Check target directory exists
   - Verify .dockerignore isn't excluding it

2. **"Port already in use"**

   - Stop existing containers: `docker stop $(docker ps -q)`
   - Use different ports: `-p 8082:8080`

3. **Alpine compatibility issues**

   - Some libraries need glibc (not in Alpine)
   - Solution: Use Ubuntu-based or install compatibility layer

4. **Container exits immediately**
   - Check logs: `docker logs container-name`
   - Run interactively: `docker run -it docker-demo:ubuntu /bin/bash`

### Advanced Exploration

1. **Analyze image layers**:

   ```bash
   docker history docker-demo:ubuntu
   docker history docker-demo:alpine
   ```

2. **Export and examine image**:

   ```bash
   docker save docker-demo:ubuntu -o ubuntu-image.tar
   tar -tf ubuntu-image.tar | head -20
   ```

3. **Multi-architecture builds**:

   ```bash
   # Check current architecture
   docker version --format '{{.Server.Arch}}'
   ```

4. **Security scanning**:
   ```bash
   # If using Docker Desktop with enabled scanning
   docker scan docker-demo:ubuntu
   ```

## 📊 Image Optimization Tips

1. **Order matters**: Put less frequently changing instructions first
2. **Combine RUN commands**: Reduces layers
3. **Clean up in same layer**:
   ```dockerfile
   RUN apt-get update && apt-get install -y curl \
       && rm -rf /var/lib/apt/lists/*
   ```
4. **Use specific tags**: Not `latest`
5. **Multi-stage builds**: Coming in Module 04!

## 🏋️ Practice Exercises

### Exercise 1: Minimal Dockerfile

Create the smallest possible Java image:

```dockerfile
# Create a new file: Dockerfile.minimal
FROM openjdk:17-jre-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build and compare size:

```bash
docker build -f Dockerfile.minimal -t docker-demo:minimal .
docker images | grep docker-demo
```

### Exercise 2: Debug Image

Create a debug-friendly image with tools:

```dockerfile
# Create Dockerfile.debug
FROM openjdk:17-jdk-slim
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    netcat \
    telnet \
    vim \
    procps \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080 5005
ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "-jar", "app.jar"]
```

### Exercise 3: Build Arguments

Use build arguments for flexibility:

```dockerfile
# Update your Dockerfile
ARG BASE_IMAGE=openjdk:17-jdk-slim
ARG JAR_FILE=target/*.jar

FROM ${BASE_IMAGE}
WORKDIR /app
COPY ${JAR_FILE} app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build with different base:

```bash
docker build --build-arg BASE_IMAGE=eclipse-temurin:17-jre-alpine -t docker-demo:temurin .
```

### Exercise 4: Layer Analysis

Analyze your image layers:

```bash
# See layer history
docker history docker-demo:ubuntu

# Export and examine
docker save docker-demo:ubuntu -o ubuntu-image.tar
tar -tf ubuntu-image.tar | head -20

# Use dive tool (if installed)
dive docker-demo:ubuntu
```

## 📝 Self-Assessment Questions

Test your Docker knowledge:

1. **What happens when you run `docker build .`?**

   - Docker reads Dockerfile in current directory
   - Sends build context to daemon
   - Executes each instruction creating layers
   - Tags final image with generated ID

2. **Why use Alpine Linux for containers?**

   - Smaller size (~5MB base)
   - Security-focused design
   - Minimal attack surface
   - BUT: musl libc can cause compatibility issues

3. **What's the difference between COPY and ADD?**

   - COPY: Simple file/directory copying (preferred)
   - ADD: Can extract tar files, download URLs
   - Use COPY unless you need ADD's features

4. **Why create a non-root user?**

   - Security: Limits container escape impact
   - Compliance: Many policies require it
   - Best practice: Principle of least privilege

5. **What does EXPOSE do?**
   - Documents which ports the app uses
   - Does NOT publish ports (that's `-p` flag)
   - Metadata for developers and tools

## 🎮 Hands-On Challenge

**Challenge**: Create an Optimized Production Image

Requirements:

1. Use multi-stage build (preview of Module 04)
2. Final image under 200MB
3. Non-root user
4. Health check included
5. Proper labels

<details>
<summary>💡 Click for solution</summary>

```dockerfile
# Build stage
FROM maven:3.8.6-openjdk-17-slim AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim
LABEL maintainer="your@email.com"
LABEL description="Optimized Spring Boot image"

RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app
COPY --from=builder --chown=spring:spring /build/target/*.jar app.jar

USER spring:spring
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build: `docker build -f Dockerfile.optimized -t docker-demo:prod .`

</details>

## 🔍 Deep Dive: Container Concepts

### Image Layers Explained

```
┌─────────────────────────┐
│   Your App (COPY)       │ ← Layer 4 (few KB)
├─────────────────────────┤
│   User Creation (RUN)   │ ← Layer 3 (few KB)
├─────────────────────────┤
│   Package Install (RUN) │ ← Layer 2 (varies)
├─────────────────────────┤
│   Base Image (FROM)     │ ← Layer 1 (hundreds MB)
└─────────────────────────┘
```

### Container vs Image

- **Image**: Read-only template (like a class)
- **Container**: Running instance (like an object)
- Multiple containers can run from one image
- Containers add writable layer on top

### Port Mapping Explained

```
Host Machine          Container
│                    │
│  Port 8080  ←────→ │ Port 8080
│                    │
│  Browser           │ Spring Boot
│  localhost:8080    │ 0.0.0.0:8080
```

## 🎯 Common Pitfalls to Avoid

1. **Using `latest` tag**

   ```dockerfile
   # ❌ Bad
   FROM openjdk:latest

   # ✅ Good
   FROM openjdk:17-jre-slim
   ```

2. **Not cleaning package manager cache**

   ```dockerfile
   # ❌ Bad
   RUN apt-get update && apt-get install curl

   # ✅ Good
   RUN apt-get update && apt-get install -y curl \
       && rm -rf /var/lib/apt/lists/*
   ```

3. **Running as root**

   ```dockerfile
   # ❌ Bad
   # No USER instruction

   # ✅ Good
   USER spring:spring
   ```

## ✅ Module Checklist

Before proceeding, ensure you can:

- [ ] Build Docker images from Dockerfiles
- [ ] Run containers from your images
- [ ] Access the Spring Boot application in containers
- [ ] Understand the difference between Ubuntu and Alpine base images
- [ ] Use basic Docker commands for images and containers
- [ ] Implement security best practices (non-root user)
- [ ] Debug containers using logs and exec

## 📚 Additional Resources

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Alpine Linux Package Management](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)
- [OpenJDK Docker Images](https://hub.docker.com/_/openjdk)
- [Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

---

**Ready to integrate Docker with your IDE? Continue to [Module 03: Eclipse Docker Plugin →](../03-eclipse-docker-plugin/ide-docker-integration.md)**

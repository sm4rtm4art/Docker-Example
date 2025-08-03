# Module 04: Multi-stage Builds - Image Optimization Mastery 🏗️

Welcome to the optimization game-changer! Multi-stage builds are the secret weapon for creating production-ready Java containers that are fast, secure, and efficient.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Understand the problem with single-stage Java builds
- ✅ Create multi-stage Dockerfiles for optimal image size
- ✅ Implement dependency caching strategies
- ✅ Use Spring Boot layered JARs for even better optimization
- ✅ Compare and measure optimization results
- ✅ Apply advanced build techniques
- ✅ Understand when and why to use different strategies

## 📚 What You'll Master

**The Optimization Journey:**

1. **Problem**: Single-stage builds create huge images (600-800MB)
2. **Solution**: Multi-stage builds separate build and runtime (200-300MB)
3. **Advanced**: Layer optimization for even faster builds
4. **Production**: Security and performance considerations

**Key Concepts:**

- Build vs Runtime environments
- Layer caching strategies
- Dependency optimization
- Image size analysis

## ⏱️ Time Investment

- **Understanding Concepts**: 15 minutes
- **Building Images**: 20 minutes
- **Size Comparisons**: 15 minutes
- **Advanced Techniques**: 25 minutes
- **Exercises**: 15 minutes
- **Total**: ~1.5 hours

## 📋 Prerequisites

- Completed [Module 02: Dockerfile Basics](../02-dockerfile-basics/dockerfile-fundamentals.md)
- Understanding of Docker layer concepts
- Maven knowledge (basic)
- 2-3 GB free disk space for multiple images

## 📁 Module Structure

```
04-multistage-builds/
├── src/                          # Spring Boot source (copied from Module 02)
├── pom.xml                       # Maven configuration
├── Dockerfile.single-stage       # Traditional approach (comparison)
├── Dockerfile.multistage         # Optimized multi-stage build
├── Dockerfile.layered            # Advanced: Spring Boot layers
├── Dockerfile.distroless          # Ultra-minimal with Distroless
└── multistage-optimization.md    # This guide
```

## 🚨 The Problem: Bloated Images

Let's start by understanding what we're solving.

### Traditional Single-Stage Build

```dockerfile
# Dockerfile.single-stage - DON'T DO THIS
FROM openjdk:17-jdk-slim

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy everything
COPY . .

# Build inside the container
RUN mvn clean package -DskipTests

# Run the app
ENTRYPOINT ["java", "-jar", "target/*.jar"]
```

**Problems with this approach:**

- ❌ **Huge size**: 600-800MB (includes Maven, JDK, source code)
- ❌ **Security**: Build tools in production image
- ❌ **Slow**: Downloads dependencies every build
- ❌ **Bloated**: Contains source code and build artifacts

### Size Comparison Demo

Let's build both and see the difference:

```bash
# Build single-stage (the old way)
docker build -f Dockerfile.single-stage -t demo:single-stage .

# Build multi-stage (the optimized way)
docker build -f Dockerfile.multistage -t demo:multistage .

# Compare sizes
docker images | grep demo
```

**Typical Results:**

```
REPOSITORY   TAG           SIZE
demo         single-stage  678MB  😱
demo         multistage    254MB  🎉
```

**That's 62% smaller!** 🚀

## 🏗️ Multi-stage Build Solution

Here's how multi-stage builds solve the problem:

### Stage 1: Build Environment

- Full JDK for compilation
- Maven for dependency management
- All build tools and source code
- **Discarded after build**

### Stage 2: Runtime Environment

- Minimal JRE for running
- Only the final JAR file
- No build tools or source code
- **This becomes your final image**

## 🎯 Hands-on Implementation

### Step 1: Basic Multi-stage Build

Let's create our first optimized Dockerfile:

```dockerfile
# Stage 1: Build Environment
FROM maven:3.8.6-openjdk-17-slim AS builder

WORKDIR /build

# Copy POM first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime Environment
FROM openjdk:17-jre-slim AS runtime

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Security: Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy ONLY the JAR from build stage
COPY --from=builder --chown=spring:spring /build/target/*.jar app.jar

USER spring:spring
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Step 2: Build and Compare

```bash
# Build all versions for comparison
docker build -f Dockerfile.single-stage -t demo:single .
docker build -f Dockerfile.multistage -t demo:multi .
docker build -f Dockerfile.layered -t demo:layered .
docker build -f Dockerfile.distroless -t demo:distroless .

# Compare sizes
docker images | grep demo
```

**Expected Results:**

```
REPOSITORY   TAG          SIZE        DESCRIPTION
demo         single       678MB       ❌ Contains build tools + source
demo         multi        254MB       ✅ Build/runtime separated
demo         layered      251MB       🚀 Optimized layer caching
demo         distroless   189MB       🔒 Ultra-secure, minimal
```

### Step 3: Understanding Layer Optimization

The magic happens in dependency caching. Let's see it in action:

```bash
# First build - downloads everything
time docker build -f Dockerfile.multistage -t demo:multi .

# Make a small code change
echo "// Modified" >> src/main/java/com/example/dockerdemo/controller/HomeController.java

# Second build - much faster!
time docker build -f Dockerfile.multistage -t demo:multi .
```

**Why the second build is faster:**

1. POM didn't change → dependencies layer cached
2. Only application code changed → only rebuilds final layers
3. Base images and dependencies reused

## 🔍 Deep Dive: How Multi-stage Works

### Build Process Visualization

```
Stage 1 (Builder)               Stage 2 (Runtime)
┌─────────────────────┐        ┌─────────────────────┐
│ maven:3.8.6-openjdk │   ──>  │ openjdk:17-jre-slim │
│ - Full JDK          │        │ - JRE only          │
│ - Maven             │        │ - curl (health)     │
│ - Source code       │        │ - app.jar           │
│ - Dependencies      │        │ - Non-root user     │
│ - Build artifacts   │        │                     │
│ ~ 600MB             │        │ ~ 250MB             │
└─────────────────────┘        └─────────────────────┘
        │                               ↑
        └──── COPY --from=builder ──────┘
             (only app.jar)
```

### Layer Caching Strategy

**Optimal Dockerfile Order:**

1. **Base image** (changes never)
2. **POM file** (changes rarely)
3. **Dependencies download** (changes rarely)
4. **Source code** (changes frequently)
5. **Build command** (changes frequently)

**Why This Matters:**

- Docker caches layers that haven't changed
- Changing layer invalidates all subsequent layers
- Put most stable things first, volatile things last

### Advanced: Spring Boot Layered JARs

Spring Boot 2.3+ supports layered JARs for even better optimization:

```bash
# Enable in pom.xml (already configured in our example)
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <layers>
            <enabled>true</enabled>
        </layers>
    </configuration>
</plugin>

# Extract layers
java -Djarmode=layertools -jar app.jar list
# dependencies
# spring-boot-loader
# snapshot-dependencies
# application
```

**Layer Strategy:**

1. **Dependencies**: External libraries (rarely change)
2. **Spring Boot Loader**: Framework code (rarely change)
3. **Snapshot Dependencies**: Development libraries (sometimes change)
4. **Application**: Your code (changes frequently)

## 🏋️ Practice Exercises

### Exercise 1: Build Time Comparison

Measure build times with different approaches:

```bash
# Create a simple timer script
cat > time-builds.sh << 'EOF'
#!/bin/bash
echo "=== Build Time Comparison ==="

echo "1. Single-stage build:"
time docker build -f Dockerfile.single-stage -t test:single . 2>&1 | grep real

echo "2. Multi-stage build:"
time docker build -f Dockerfile.multistage -t test:multi . 2>&1 | grep real

echo "3. Layered build:"
time docker build -f Dockerfile.layered -t test:layered . 2>&1 | grep real
EOF

chmod +x time-builds.sh
./time-builds.sh
```

### Exercise 2: Cache Effectiveness Test

Test layer caching by making small changes:

```bash
# 1. Initial build (cold cache)
docker build -f Dockerfile.multistage -t cache-test:v1 .

# 2. Change only application code
echo "// Cache test" >> src/main/java/com/example/dockerdemo/controller/HomeController.java

# 3. Rebuild and note which layers are cached
docker build -f Dockerfile.multistage -t cache-test:v2 .

# Look for "Using cache" vs "Running" in output
```

### Exercise 3: Security Comparison

Compare security footprints:

```bash
# Check what's inside each image
echo "=== Single-stage content ==="
docker run --rm demo:single find /usr -name "mvn" 2>/dev/null

echo "=== Multi-stage content ==="
docker run --rm demo:multi find /usr -name "mvn" 2>/dev/null || echo "Maven not found (good!)"

echo "=== Distroless content ==="
docker run --rm demo:distroless ls /bin 2>/dev/null || echo "No shell (maximum security!)"
```

### Exercise 4: Performance Testing

Test application startup and runtime performance:

```bash
# Start containers and measure startup time
echo "Testing startup times..."

echo "Multi-stage:"
time docker run --rm -p 8080:8080 demo:multi &
sleep 10
curl -s http://localhost:8080/actuator/health
docker stop $(docker ps -q --filter ancestor=demo:multi)

echo "Distroless:"
time docker run --rm -p 8081:8080 demo:distroless &
sleep 10
curl -s http://localhost:8081/actuator/health
docker stop $(docker ps -q --filter ancestor=demo:distroless)
```

## 📝 Self-Assessment Questions

Test your understanding:

1. **Why do multi-stage builds reduce image size?**

   - Only final stage becomes the image
   - Build tools and source code discarded
   - Separate build and runtime environments

2. **What's the optimal order for Dockerfile instructions?**

   - Least frequently changing first
   - Most frequently changing last
   - Maximizes layer cache hits

3. **How does COPY --from=builder work?**

   - Copies files from named build stage
   - Only specified files/directories copied
   - Source stage can be discarded

4. **What are Spring Boot layered JARs?**

   - JARs split into logical layers
   - Dependencies separated from application code
   - Better Docker layer caching

5. **When would you use distroless images?**
   - Maximum security requirements
   - No shell/debugging tools needed
   - Compliance with minimal attack surface policies

## 🎮 Hands-On Challenge

**Challenge**: Create the Ultimate Optimized Build

Requirements:

1. Multi-stage build with layered JARs
2. Non-root user security
3. Health check capability
4. Build time under 30 seconds (with cache)
5. Final image under 200MB
6. Include JVM optimization flags

<details>
<summary>💡 Solution Approach</summary>

```dockerfile
# Ultimate Dockerfile
FROM maven:3.8.6-openjdk-17-slim AS builder

WORKDIR /build

# Aggressive dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build with layers
COPY src ./src
RUN mvn clean package -DskipTests -B && \
    java -Djarmode=layertools -jar target/*.jar extract

# Optimized runtime
FROM openjdk:17-jre-slim

# Minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Security
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Optimal layer order
COPY --from=builder --chown=spring:spring /build/dependencies/ ./
COPY --from=builder --chown=spring:spring /build/spring-boot-loader/ ./
COPY --from=builder --chown=spring:spring /build/snapshot-dependencies/ ./
COPY --from=builder --chown=spring:spring /build/application/ ./

USER spring:spring
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
```

**Optimizations included:**

- ✅ Layered JAR approach
- ✅ Aggressive caching strategy
- ✅ Non-root user
- ✅ Health check
- ✅ Container-aware JVM settings
- ✅ Minimal base image
</details>

## 🔧 Build Optimization Tips

### 1. .dockerignore Optimization

```dockerignore
# Exclude everything not needed for build
**/target
**/.git
**/.idea
**/.vscode
**/*.md
**/Dockerfile*
**/.gitignore
**/node_modules
**/.DS_Store
```

### 2. Maven Optimizations

```xml
<!-- In pom.xml for faster builds -->
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <layers>
            <enabled>true</enabled>
        </layers>
        <!-- Skip tests in container build -->
        <excludes>
            <exclude>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-devtools</artifactId>
            </exclude>
        </excludes>
    </configuration>
</plugin>
```

### 3. Build Arguments for Flexibility

```dockerfile
ARG MAVEN_VERSION=3.8.6
ARG JAVA_VERSION=17
ARG BASE_IMAGE=openjdk:${JAVA_VERSION}-jre-slim

FROM maven:${MAVEN_VERSION}-openjdk-${JAVA_VERSION}-slim AS builder
# ... build stage ...

FROM ${BASE_IMAGE} AS runtime
# ... runtime stage ...
```

### 4. Multi-platform Builds

```bash
# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64 \
    -f Dockerfile.multistage \
    -t myapp:multi-platform .
```

## 📊 Optimization Results Summary

| Approach     | Size  | Build Time | Security  | Caching   |
| ------------ | ----- | ---------- | --------- | --------- |
| Single-stage | 678MB | Slow       | Poor      | Bad       |
| Multi-stage  | 254MB | Fast       | Good      | Good      |
| Layered      | 251MB | Very Fast  | Good      | Excellent |
| Distroless   | 189MB | Fast       | Excellent | Good      |

**Recommendations:**

- **Development**: Multi-stage with health checks
- **Production**: Layered for fast updates
- **High Security**: Distroless with external monitoring
- **CI/CD**: Layer-optimized for build speed

## ✅ Module Checklist

Before proceeding, ensure you can:

- [ ] Explain the problems with single-stage builds
- [ ] Create multi-stage Dockerfiles
- [ ] Implement dependency caching strategies
- [ ] Use Spring Boot layered JARs
- [ ] Compare image sizes and build times
- [ ] Choose appropriate base images for different scenarios
- [ ] Apply security best practices in multi-stage builds

## 📚 Additional Resources

- [Docker Multi-stage Builds Documentation](https://docs.docker.com/develop/develop-images/multistage-build/)
- [Spring Boot Docker Layers](https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3)
- [Google Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [JVM Container Optimization](https://developers.redhat.com/blog/2017/03/14/java-inside-docker)

---

**Ready to orchestrate multiple containers? Continue to [Module 05: Docker Compose with Database →](../05-docker-compose-db/)**

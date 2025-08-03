# Java Docker Implementation Guide ☕

Apply Docker best practices specifically to Java applications. Learn JVM-optimized patterns, Spring Boot integration, and Maven/Gradle considerations.

## 🎯 Java-Specific Docker Considerations

### JVM Container Optimizations

```dockerfile
# JVM-aware resource limits
ENTRYPOINT ["java",
    "-XX:+UseContainerSupport",
    "-XX:MaxRAMPercentage=75.0",
    "-jar", "app.jar"]
```

### Spring Boot Optimizations

```dockerfile
# Enable Spring Boot health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1
```

## 📁 Complete Java Dockerfile Templates

### Basic Single-Stage (Development)

```dockerfile
FROM openjdk:17-jre-slim

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy pre-built JAR (build with mvn clean package first)
COPY --chown=spring:spring target/task-api-*.jar app.jar

USER spring:spring
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Production Multi-Stage

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM maven:3.8.6-openjdk-17-slim AS builder

LABEL stage=builder
LABEL description="Maven build stage"

WORKDIR /build

# Copy POM first for dependency caching
COPY pom.xml .

# Download dependencies (cached if POM unchanged)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests -B

# ==========================================
# Stage 2: Runtime Environment
# ==========================================
FROM openjdk:17-jre-slim AS runtime

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder --chown=spring:spring /build/target/*.jar app.jar

USER spring:spring
EXPOSE 8080

# Spring Boot health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM container optimizations
ENTRYPOINT ["java",
    "-XX:+UseContainerSupport",
    "-XX:MaxRAMPercentage=75.0",
    "-jar", "app.jar"]
```

### Ultra-Secure Distroless

```dockerfile
# ==========================================
# Stage 1: Build Environment
# ==========================================
FROM maven:3.8.6-openjdk-17-slim AS builder

WORKDIR /build

# Dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build application
COPY src ./src
RUN mvn clean package -DskipTests -B

# ==========================================
# Stage 2: Distroless Runtime
# ==========================================
FROM gcr.io/distroless/java17-debian11 AS runtime

LABEL maintainer="your-email@example.com"
LABEL description="Ultra-secure Spring Boot - Distroless"
LABEL security="Maximum - no shell, no package manager"

# Copy JAR (distroless runs as non-root by default)
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

# Note: No health check possible - no curl in distroless
# Health checks must be done externally (e.g., Kubernetes)

ENTRYPOINT ["java",
    "-XX:+UseContainerSupport",
    "-XX:MaxRAMPercentage=75.0",
    "-jar", "app.jar"]
```

## 🔧 Build & Run Commands

### Build Your Java Application

```bash
# Single-stage development build
docker build -t task-api:dev .

# Multi-stage production build
docker build -f Dockerfile.multi -t task-api:prod .

# Distroless build
docker build -f Dockerfile.distroless -t task-api:secure .
```

### Size Comparison

```bash
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep task-api

# Expected results:
# task-api:dev      ~400MB
# task-api:prod     ~250MB
# task-api:secure   ~180MB
```

### Run and Test

```bash
# Run production image
docker run -d -p 8080:8080 --name java-api task-api:prod

# Test endpoints
curl http://localhost:8080/api/tasks
curl http://localhost:8080/actuator/health

# Check JVM settings
docker exec java-api java -XX:+PrintFlagsFinal -version | grep -E "UseContainerSupport|MaxRAMPercentage"

# Cleanup
docker rm -f java-api
```

## 🚀 Java-Specific Optimizations

### Maven Dependency Caching

The key to fast rebuilds is copying `pom.xml` first:

```dockerfile
# This order enables caching
COPY pom.xml .                    # Changes rarely
RUN mvn dependency:go-offline -B  # Downloads cached if POM unchanged
COPY src ./src                    # Changes frequently
RUN mvn clean package -B          # Only rebuilds if needed
```

### Spring Boot Layer Optimization

Enable layered JARs in `pom.xml`:

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <layers>
            <enabled>true</enabled>
        </layers>
    </configuration>
</plugin>
```

Then extract layers for even better caching:

```dockerfile
FROM openjdk:17-jre-slim
WORKDIR /app

# Extract layers
COPY --from=builder /build/target/task-api-*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# Copy layers in order of change frequency
COPY dependencies/ ./
COPY spring-boot-loader/ ./
COPY snapshot-dependencies/ ./
COPY application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
```

### JVM Memory Configuration

```dockerfile
# Let JVM detect container memory limits
ENTRYPOINT ["java",
    "-XX:+UseContainerSupport",
    "-XX:MaxRAMPercentage=75.0",     # Use 75% of container memory
    "-XX:+UseG1GC",                  # Use G1 garbage collector
    "-jar", "app.jar"]
```

## 🐛 Java-Specific Troubleshooting

### Issue 1: OutOfMemoryError

```bash
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
```

**Solution**: Add memory limits

```dockerfile
ENTRYPOINT ["java", "-Xmx512m", "-jar", "app.jar"]
```

### Issue 2: Slow Startup

```bash
# Takes 60+ seconds to start
```

**Solution**: Enable class data sharing

```dockerfile
RUN java -Xshare:dump
ENTRYPOINT ["java", "-Xshare:on", "-jar", "app.jar"]
```

### Issue 3: Spring Boot Actuator Health Check Fails

```bash
curl: (7) Failed to connect to localhost port 8080
```

**Solution**: Ensure proper startup time

```dockerfile
HEALTHCHECK --start-period=60s --timeout=10s \
    CMD curl -f http://localhost:8080/actuator/health || exit 1
```

## 📊 Performance Comparison

Test your optimizations:

```bash
# Memory usage
docker stats task-api --no-stream

# Startup time
time docker run --rm task-api:prod curl -f http://localhost:8080/actuator/health

# Image layers
docker history task-api:prod
```

## ✅ Java Implementation Checklist

- [ ] Multi-stage build reduces image size by 50%+
- [ ] JVM uses container-aware memory settings
- [ ] Spring Boot health check works correctly
- [ ] Non-root user implemented
- [ ] Maven dependencies cached for fast rebuilds
- [ ] Application starts in <60 seconds

## 🔗 Integration with Your Task API

Your Java Task API from Module 02 should now be containerized with:

1. **Security**: Non-root user, minimal runtime
2. **Performance**: Multi-stage build, JVM optimization
3. **Monitoring**: Health checks, proper logging
4. **Production**: Distroless option for maximum security

Ready for the next challenge? Proceed to [Module 04: Docker Compose](../../04-docker-compose/) to orchestrate your Java API with a PostgreSQL database!

---

**Remember**: These patterns work for any Java application - Spring Boot, Quarkus, Micronaut, or plain Java. The Docker concepts remain the same!

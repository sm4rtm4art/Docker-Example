# Java Track: Your First Containerized Application ☕

> **Build a Task Management REST API with Spring Boot and Docker**

Welcome to the Java track! In this module, you'll build a real Spring Boot application and containerize it, learning Docker concepts through practical Java development.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Navigate a real Spring Boot Task API in this repository (Docker lesson first)
- ✅ Build and test REST endpoints using Spring Boot
- ✅ **Containerize** a Java application with Docker
- ✅ Understand **port mapping** and container networking
- ✅ Implement **health checks** in containers
- ✅ Use **environment variables** for configuration
- ✅ Debug issues with **logs and container inspection**

## 🚀 Project Overview

A **Task Management REST API** with Docker integration:

### Application Features:

- CRUD operations (Create, Read, Update, Delete)
- In-memory data storage
- Health monitoring endpoints
- JSON API responses
- Spring Boot DevTools for development

### Docker Features:

- Containerized Spring Boot application
- Proper port mapping (8080)
- Health check integration
- Environment-based configuration
- Non-root user security

### ⏱️ Time Investment

- **Understanding the App**: 15 minutes
- **Building & Testing**: 20 minutes
- **Containerizing**: 20 minutes
- **Docker Exploration**: 15 minutes
- **Total**: ~1 hour

## 📦 Project Setup

- ✅ Completed [Module 00: Prerequisites](../../00-prerequisites/) with Java track
- ✅ Completed [Module 01: Docker Fundamentals](../../01-docker-fundamentals/)
- ✅ Java 17+ and Maven installed
- ✅ Basic Java knowledge (classes, methods, annotations)

### 🏗️ Project Structure

The Java track in this repository is already implemented under `com.example.dockerdemo`. Use the tree below to find source files; snippets match what is checked in.

```
java/
├── pom.xml
├── Dockerfile
├── docker-compose.yml
├── src/
│   ├── main/
│   │   ├── java/com/example/dockerdemo/
│   │   │   ├── DockerDemoApplication.java
│   │   │   ├── controller/
│   │   │   │   ├── HomeController.java      # GET /
│   │   │   │   └── TaskController.java      # /api/tasks
│   │   │   ├── model/
│   │   │   │   └── Task.java                # Lombok model
│   │   │   └── service/
│   │   │       └── TaskService.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
└── .dockerignore
```

## ☕ Java Implementation

You do **not** need to retype the application from scratch for the Docker lesson. Open the files above in your editor, or refer to the excerpts below (they mirror the repository).

### Maven Configuration (`pom.xml`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>docker-demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>docker-demo</name>
    <description>Demo Spring Boot project for Docker learning</description>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### Application Configuration (`application.properties`)

```properties
# Application Configuration
spring.application.name=docker-demo
server.port=8080

# Actuator Configuration
management.endpoints.web.exposure.include=health,info,metrics,env
management.endpoint.health.show-details=always
management.info.env.enabled=true

# Application Info
info.app.name=Docker Demo API
info.app.description=Spring Boot REST API for Docker learning
info.app.version=0.0.1
info.app.java.version=@java.version@

# Logging
logging.level.root=INFO
logging.level.com.example.dockerdemo=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Jackson Configuration
spring.jackson.serialization.write-dates-as-timestamps=false
spring.jackson.serialization.indent-output=true

# DevTools (will be disabled in production)
spring.devtools.restart.enabled=true
spring.devtools.livereload.enabled=true
```

Actuator exposes health at `/actuator/health` by default (no need to set `management.endpoints.web.base-path` unless you customize it).

### 🔧 Application source (reference)

#### `DockerDemoApplication.java`

```java
package com.example.dockerdemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DockerDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DockerDemoApplication.class, args);
    }
}
```

#### `Task.java` (Lombok)

```java
package com.example.dockerdemo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Task {
    private Long id;
    private String title;
    private String description;
    private boolean completed;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

#### `TaskService.java`

```java
package com.example.dockerdemo.service;

import com.example.dockerdemo.model.Task;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final ConcurrentHashMap<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong idCounter = new AtomicLong();

    public TaskService() {
        createTask("Learn Docker", "Understand containerization basics");
        createTask("Setup Spring Boot", "Create REST API with Spring Boot");
        createTask("Connect to Database", "Learn Docker Compose with MariaDB");
    }

    public List<Task> getAllTasks() {
        return new ArrayList<>(tasks.values());
    }

    public Optional<Task> getTaskById(Long id) {
        return Optional.ofNullable(tasks.get(id));
    }

    public Task createTask(String title, String description) {
        Task task = Task.builder()
                .id(idCounter.incrementAndGet())
                .title(title)
                .description(description)
                .completed(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        tasks.put(task.getId(), task);
        return task;
    }

    public Optional<Task> updateTask(Long id, Task taskUpdate) {
        return Optional.ofNullable(tasks.computeIfPresent(id, (key, existingTask) -> {
            existingTask.setTitle(taskUpdate.getTitle());
            existingTask.setDescription(taskUpdate.getDescription());
            existingTask.setCompleted(taskUpdate.isCompleted());
            existingTask.setUpdatedAt(LocalDateTime.now());
            return existingTask;
        }));
    }

    public boolean deleteTask(Long id) {
        return tasks.remove(id) != null;
    }

    public long getTaskCount() {
        return tasks.size();
    }
}
```

#### `TaskController.java`

```java
package com.example.dockerdemo.controller;

import com.example.dockerdemo.model.Task;
import com.example.dockerdemo.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public List<Task> getAllTasks() {
        return taskService.getAllTasks();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody Task task) {
        Task createdTask = taskService.createTask(task.getTitle(), task.getDescription());
        return ResponseEntity.status(HttpStatus.CREATED).body(createdTask);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Task> updateTask(@PathVariable Long id, @RequestBody Task task) {
        return taskService.updateTask(id, task)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        if (taskService.deleteTask(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/count")
    public ResponseEntity<Map<String, Long>> getTaskCount() {
        return ResponseEntity.ok(Map.of("count", taskService.getTaskCount()));
    }
}
```

#### `HomeController.java` (root JSON and endpoint hints)

```java
package com.example.dockerdemo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
public class HomeController {

    @Value("${spring.application.name:docker-demo}")
    private String applicationName;

    @GetMapping("/")
    public Map<String, Object> home() {
        return Map.of(
            "message", "Welcome to Docker Demo API!",
            "application", applicationName,
            "version", "0.0.1",
            "timestamp", LocalDateTime.now(),
            "endpoints", Map.of(
                "tasks", "/api/tasks",
                "health", "/actuator/health",
                "info", "/actuator/info"
            )
        );
    }
}
```

## 🧪 Testing Your Java Container

### Build and Run Locally

```bash
# Build the application
mvn clean compile

# Run the application
mvn spring-boot:run

# The application will start on http://localhost:8080
```

### Test the API

```bash
# Test the home endpoint
curl http://localhost:8080/

# Get all tasks
curl http://localhost:8080/api/tasks

# Create a new task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Docker", "description": "Learn containerization"}'

# Check health (Spring Boot Actuator endpoint)
curl http://localhost:8080/actuator/health
```

## 🐳 Java Docker Patterns

### Create Dockerfile

Create `Dockerfile`:

```dockerfile
# Production Dockerfile for Java Task API
# Multi-stage build for optimized image size

# Build stage - using Maven image to avoid wrapper dependencies
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy configuration first for better caching
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage - smaller image
FROM eclipse-temurin:17-jre-jammy

# Install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
# UID 1000 is standard
ARG UID=1000
ARG GID=1000
RUN groupadd -r -g ${GID} appgroup && \
    useradd -r -g appgroup -u ${UID} appuser

# Set working directory
WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Create .dockerignore

Create `.dockerignore`:

```
target/
.mvn/
*.iml
.idea/
.git/
.gitignore
README.md
Dockerfile
docker-compose.yml
.dockerignore
.DS_Store
```

### Build and Run Container

```bash
# Build the Docker image
docker build -t task-api-java .

# Run the container
docker run -d -p 8080:8080 --name task-api task-api-java

# Check if it's running
docker ps

# Test the containerized application
curl http://localhost:8080/api/tasks
```

### Optional: Run with Docker Compose

Use the included `docker-compose.yml` if you prefer a one-command run flow:

```bash
# Start the Java quickstart service (optional: map host UID/GID for permission experiments)
docker compose up -d
# If you need host UID/GID and the image supports it:
# UID=$(id -u) GID=$(id -g) docker compose up -d

# Check service health
docker compose ps
curl http://localhost:8080/actuator/health

# Stop and clean up
docker compose down
```

> **Host UID/GID**: On some hosts (for example macOS), your `GID` may already exist inside the image build and cause `groupadd`/`addgroup` to fail during image build. If that happens, run `docker compose up` without passing `UID`/`GID`, or use the default build args in `docker-compose.yml`.

> Note: In this module, Java Compose intentionally builds from the production `Dockerfile` instead of a separate `Dockerfile.dev`. This keeps the quickstart simple and focused on baseline container behavior before development-workflow variants in later modules. Spring Boot provides health checks through Actuator at `/actuator/health`.

## 🔧 Java-Specific Docker Optimizations

### Container Inspection

```bash
# View container logs (name depends how you started the container)
docker logs task-api          # if you used: docker run --name task-api ...
docker logs task-api-java    # if you used: docker compose up (see docker-compose.yml container_name)

# Execute commands inside the container
docker exec -it task-api bash
# or: docker exec -it task-api-java bash

# Inside the container, explore:
ps aux                    # See running processes
ls -la /app              # Check application files
whoami                   # Verify non-root user
curl localhost:8080/actuator/health  # Test from inside
```

### Image Analysis

```bash
# Check image size
docker images task-api-java

# Inspect image layers
docker history task-api-java

# Compare with a basic Java image
docker images eclipse-temurin:17-jre
```

## 🐛 Java Container Troubleshooting

Use these quick checks if the Java container does not behave as expected:

1. **Why do we use multi-stage builds for Java applications?**
   <details>
   <summary>Answer</summary>
   Multi-stage builds allow us to use a full JDK for building (including Maven) but only include the JRE in the final image, reducing size and attack surface.
   </details>

2. **What happens if you remove the `USER appuser` instruction?**
   <details>
   <summary>Answer</summary>
   The container would run as root, which is a security risk. Always run containers as non-root users when possible.
   </details>

3. **How does the health check work in this container?**
   <details>
   <summary>Answer</summary>
   Docker periodically calls `curl -f http://localhost:8080/actuator/health` inside the container. If it fails 3 times, the container is marked unhealthy.
   </details>

## 🧹 Cleanup

### Standalone `docker run`

```bash
docker stop task-api 2>/dev/null || true
docker rm task-api 2>/dev/null || true
docker rmi task-api-java 2>/dev/null || true
```

### Docker Compose

From the `java/` directory:

```bash
docker compose down --remove-orphans
docker rmi task-api-java 2>/dev/null || true
```

## 🚀 Next Steps

### Environment Variables

Try running with different configurations:

```bash
docker run -d -p 8080:8080 \
  -e SERVER_PORT=8080 \
  -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics \
  --name task-api-configured \
  task-api-java
```

### Volume Mounting

Mount a directory for logs:

```bash
docker run -d -p 8080:8080 \
  -v $(pwd)/logs:/app/logs \
  --name task-api-with-logs \
  task-api-java
```

### Resource Limits

Limit container resources:

```bash
docker run -d -p 8080:8080 \
  --memory=512m \
  --cpus=0.5 \
  --name task-api-limited \
  task-api-java
```

## ✅ Java Quickstart Checklist

- [ ] Spring Boot Task API running in a container
- [ ] Non-root user security implemented
- [ ] Health checks working through `/actuator/health`
- [ ] Multi-stage Java Docker build understood
- [ ] Compose workflow tested for quick local startup
- [ ] Container inspection and debugging commands practiced

**Next steps**: [Module 03: Dockerfile Essentials](../../03-dockerfile-essentials/), then [Module 04: Docker Compose](../04-docker-compose/).

---

_"You've just containerized your first Java application! The concepts you've learned - multi-stage builds, health checks, and security - apply to containerizing any Java application."_

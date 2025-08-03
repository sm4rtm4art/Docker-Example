# Java Track: Your First Containerized Application ☕

> **Build a Task Management REST API with Spring Boot and Docker**

Welcome to the Java track! In this module, you'll build a real Spring Boot application and containerize it, learning Docker concepts through practical Java development.

## 🎯 Learning Objectives

By completing this module, you will be able to:

- ✅ Create a Spring Boot REST API from scratch
- ✅ Build and test REST endpoints using Spring Boot
- ✅ **Containerize** a Java application with Docker
- ✅ Understand **port mapping** and container networking
- ✅ Implement **health checks** in containers
- ✅ Use **environment variables** for configuration
- ✅ Debug issues with **logs and container inspection**

## 📚 What You'll Build

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

## ⏱️ Time Investment

- **Understanding the App**: 15 minutes
- **Building & Testing**: 20 minutes
- **Containerizing**: 20 minutes
- **Docker Exploration**: 15 minutes
- **Total**: ~1 hour

## 📋 Prerequisites

- ✅ Completed [Module 00: Prerequisites](../../00-prerequisites/) with Java track
- ✅ Completed [Module 01: Docker Fundamentals](../../01-docker-fundamentals/)
- ✅ Java 17+ and Maven installed
- ✅ Basic Java knowledge (classes, methods, annotations)

## 🏗️ Project Structure

```
java/
├── pom.xml                           # Maven configuration
├── Dockerfile                       # Container definition
├── src/
│   ├── main/
│   │   ├── java/com/example/taskapi/
│   │   │   ├── TaskApiApplication.java     # Main class
│   │   │   ├── controller/
│   │   │   │   ├── HealthController.java   # Health endpoint
│   │   │   │   └── TaskController.java     # REST API
│   │   │   ├── model/
│   │   │   │   └── Task.java               # Data model
│   │   │   └── service/
│   │   │       └── TaskService.java        # Business logic
│   │   └── resources/
│   │       └── application.properties      # Configuration
│   └── test/                               # Test classes
└── .dockerignore                           # Docker ignore file
```

## 🚀 Step 1: Create the Spring Boot Application

### Maven Configuration (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>task-api</artifactId>
    <version>1.0.0</version>
    <name>Task Management API</name>
    <description>Docker Learning Path - Java Track Example</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Actuator for health checks -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Development tools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>

        <!-- Testing -->
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
            </plugin>
        </plugins>
    </build>
</project>
```

### Application Configuration (application.properties)

```properties
# Server configuration
server.port=8080
server.servlet.context-path=/api

# Actuator configuration (for health checks)
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always
management.endpoints.web.base-path=/

# Application information
info.app.name=Task Management API
info.app.description=Docker Learning Path Example
info.app.version=1.0.0
```

## 🔧 Step 2: Build the Application Code

### Main Application Class

Create `src/main/java/com/example/taskapi/TaskApiApplication.java`:

```java
package com.example.taskapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TaskApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(TaskApiApplication.class, args);
    }
}
```

### Task Model

Create `src/main/java/com/example/taskapi/model/Task.java`:

```java
package com.example.taskapi.model;

import java.time.LocalDateTime;

public class Task {
    private Long id;
    private String title;
    private String description;
    private boolean completed;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Task() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public Task(String title, String description) {
        this();
        this.title = title;
        this.description = description;
        this.completed = false;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) {
        this.title = title;
        this.updatedAt = LocalDateTime.now();
    }

    public String getDescription() { return description; }
    public void setDescription(String description) {
        this.description = description;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) {
        this.completed = completed;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
```

### Task Service

Create `src/main/java/com/example/taskapi/service/TaskService.java`:

```java
package com.example.taskapi.service;

import com.example.taskapi.model.Task;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final Map<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong nextId = new AtomicLong(1);

    public TaskService() {
        // Add some sample data
        createTask("Learn Docker fundamentals", "Complete Module 01 exercises");
        createTask("Build first container", "Containerize this Java application");
        createTask("Explore Docker Compose", "Learn multi-container applications");
    }

    public List<Task> getAllTasks() {
        return new ArrayList<>(tasks.values());
    }

    public Optional<Task> getTaskById(Long id) {
        return Optional.ofNullable(tasks.get(id));
    }

    public Task createTask(String title, String description) {
        Task task = new Task(title, description);
        task.setId(nextId.getAndIncrement());
        tasks.put(task.getId(), task);
        return task;
    }

    public Optional<Task> updateTask(Long id, Task updatedTask) {
        Task existingTask = tasks.get(id);
        if (existingTask != null) {
            existingTask.setTitle(updatedTask.getTitle());
            existingTask.setDescription(updatedTask.getDescription());
            existingTask.setCompleted(updatedTask.isCompleted());
            return Optional.of(existingTask);
        }
        return Optional.empty();
    }

    public boolean deleteTask(Long id) {
        return tasks.remove(id) != null;
    }

    public long getTaskCount() {
        return tasks.size();
    }
}
```

### REST Controller

Create `src/main/java/com/example/taskapi/controller/TaskController.java`:

```java
package com.example.taskapi.controller;

import com.example.taskapi.model.Task;
import com.example.taskapi.service.TaskService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

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
    public Task createTask(@RequestBody Map<String, String> request) {
        String title = request.get("title");
        String description = request.get("description");
        return taskService.createTask(title, description);
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
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

### Health Controller

Create `src/main/java/com/example/taskapi/controller/HealthController.java`:

```java
package com.example.taskapi.controller;

import com.example.taskapi.service.TaskService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HealthController {

    private final TaskService taskService;

    public HealthController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping("/")
    public Map<String, Object> home() {
        return Map.of(
            "message", "Task Management API is running!",
            "version", "1.0.0",
            "endpoints", Map.of(
                "tasks", "/api/tasks",
                "health", "/health"
            )
        );
    }
}
```

## 🧪 Step 3: Test the Application

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

# Check health
curl http://localhost:8080/health
```

## 🐳 Step 4: Containerize with Docker

### Create Dockerfile

Create `Dockerfile`:

```dockerfile
# Multi-stage build for optimized Java containers
FROM eclipse-temurin:17-jdk AS builder

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download dependencies (cached layer)
RUN ./mvnw dependency:resolve

# Copy source code
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Runtime stage - smaller image
FROM eclipse-temurin:17-jre

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

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
  CMD curl -f http://localhost:8080/health || exit 1

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
.dockerignore
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

## 🔍 Step 5: Docker Exploration

### Container Inspection

```bash
# View container logs
docker logs task-api

# Execute commands inside the container
docker exec -it task-api bash

# Inside the container, explore:
ps aux                    # See running processes
ls -la /app              # Check application files
whoami                   # Verify non-root user
curl localhost:8080/health  # Test from inside
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

## 🎓 Knowledge Check

Test your understanding:

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
   Docker periodically calls `curl -f http://localhost:8080/health` inside the container. If it fails 3 times, the container is marked unhealthy.
   </details>

## 🧹 Cleanup

```bash
# Stop and remove the container
docker stop task-api
docker rm task-api

# Remove the image (optional)
docker rmi task-api-java
```

## 🚀 Going Further

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

## 📋 Summary

**You've successfully:**

✅ Built a real Spring Boot REST API  
✅ Created a secure, optimized Docker container  
✅ Implemented health checks and non-root security  
✅ Learned container inspection and debugging  
✅ Understood multi-stage builds for Java

**Next Step**: [Module 03: Dockerfile Essentials](../../03-dockerfile-essentials/) to master Docker image creation techniques!

---

_"You've just containerized your first Java application! The concepts you've learned - multi-stage builds, health checks, and security - apply to containerizing any Java application."_

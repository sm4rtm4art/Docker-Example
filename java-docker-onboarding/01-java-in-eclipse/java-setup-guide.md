# Module 01: Java Spring Boot in Eclipse 🚀

Welcome to hands-on Spring Boot development! In this module, you'll build a real REST API that will serve as the foundation for all containerization work.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Create a Spring Boot REST API from scratch
- ✅ Import and manage Maven projects in Eclipse IDE
- ✅ Build and run Spring Boot applications
- ✅ Test REST endpoints using various tools
- ✅ Use Spring Boot DevTools for rapid development
- ✅ Monitor application health with Actuator
- ✅ Debug Spring Boot applications in Eclipse

## 📚 What You'll Build

A **Task Management REST API** with:

- CRUD operations (Create, Read, Update, Delete)
- In-memory data storage (for now)
- Health monitoring endpoints
- Automatic hot reload capability
- RESTful design principles

## ⏱️ Time Investment

- **Setup & Import**: 10 minutes
- **Understanding Code**: 15 minutes
- **Running & Testing**: 20 minutes
- **Exercises**: 15 minutes
- **Total**: ~1 hour

## 📋 Prerequisites

- Completed [Module 00: Prerequisites](../00-prerequisites/prerequisites-setup.md)
- Eclipse IDE with Spring Tools installed
- Java 17 and Maven configured
- Basic Java knowledge (classes, methods, annotations)

## 🏗️ Project Structure

```
01-java-in-eclipse/
├── pom.xml                           # Maven configuration
├── src/
│   ├── main/
│   │   ├── java/com/example/dockerdemo/
│   │   │   ├── DockerDemoApplication.java    # Main class
│   │   │   ├── controller/
│   │   │   │   ├── HomeController.java       # Root endpoint
│   │   │   │   └── TaskController.java       # REST API
│   │   │   ├── model/
│   │   │   │   └── Task.java                 # Data model
│   │   │   └── service/
│   │   │       └── TaskService.java          # Business logic
│   │   └── resources/
│   │       └── application.properties        # Configuration
│   └── test/                         # Test classes
└── README.md                         # This file
```

## 🚀 Getting Started

### Step 1: Import Project in Eclipse

1. **Open Eclipse IDE**
2. **File → Import → Maven → Existing Maven Projects**
3. **Browse** to `java-docker-onboarding/01-java-in-eclipse`
4. **Select** pom.xml and click **Finish**
5. Wait for Maven to download dependencies (check Progress view)

### Step 2: Configure Eclipse for Spring Boot

1. **Right-click project → Spring → Add Spring Project Nature**
2. **Window → Preferences → Java → Installed JREs**
   - Ensure Java 17 is selected
3. **Project → Properties → Java Build Path**
   - Verify JRE System Library is JavaSE-17

### Step 3: Run the Application

#### Option A: Using Spring Boot Dashboard

1. **Window → Show View → Other → Spring → Boot Dashboard**
2. Find `docker-demo` in the dashboard
3. Click the **play button** to start

#### Option B: Run as Java Application

1. Right-click `DockerDemoApplication.java`
2. **Run As → Spring Boot App** (or Java Application)

#### Option C: Using Maven

```bash
cd 01-java-in-eclipse
mvn spring-boot:run
```

### Step 4: Verify Application

Open your browser or use curl:

```bash
# Check home endpoint
curl http://localhost:8080/

# Check health
curl http://localhost:8080/actuator/health

# Get all tasks
curl http://localhost:8080/api/tasks

# Create a new task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Eclipse","description":"Master Eclipse IDE for Spring Boot"}'
```

## 💻 VS Code Alternative Setup

If using VS Code instead of Eclipse:

1. **Open VS Code**
2. **File → Open Folder** → Select `01-java-in-eclipse`
3. **Install Extensions** (if not already):
   - Java Extension Pack
   - Spring Boot Extension Pack
4. **Run Application**:
   - Press `F5` or
   - Click "Run" above the main method in `DockerDemoApplication.java`
   - Terminal: `mvn spring-boot:run`

## 🔧 Understanding the Code

### 1. Main Application Class

```java
@SpringBootApplication  // Enables auto-configuration, component scan, and more
public class DockerDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DockerDemoApplication.class, args);
    }
}
```

### 2. REST Controller

- `@RestController`: Combines @Controller and @ResponseBody
- `@RequestMapping`: Maps HTTP requests to methods
- `@GetMapping`, `@PostMapping`, etc.: HTTP method specific mappings

### 3. Service Layer

- `@Service`: Marks class as a service component
- Uses `ConcurrentHashMap` for thread-safe in-memory storage
- Will be replaced with database in later modules

### 4. Model with Lombok

- `@Data`: Generates getters, setters, toString, equals, hashCode
- `@Builder`: Implements builder pattern
- Reduces boilerplate code significantly

## 🔥 Hot Reload with DevTools

Spring Boot DevTools enables automatic restart when code changes:

1. **Make a change** in any Java file
2. **Save the file** (Ctrl+S)
3. **Build project** (Eclipse: automatic, VS Code: may need manual build)
4. Application **restarts automatically**

Try it:

1. Change the welcome message in `HomeController`
2. Save and wait 2-3 seconds
3. Refresh http://localhost:8080/ to see changes

## 📊 Actuator Endpoints

Spring Boot Actuator provides production-ready features:

```bash
# Health check
curl http://localhost:8080/actuator/health

# Application info
curl http://localhost:8080/actuator/info

# Metrics
curl http://localhost:8080/actuator/metrics

# Environment properties
curl http://localhost:8080/actuator/env
```

## 🧪 Testing the API

### Using Postman or Thunder Client (VS Code)

1. **GET** `http://localhost:8080/api/tasks` - List all tasks
2. **POST** `http://localhost:8080/api/tasks` - Create task
   ```json
   {
     "title": "New Task",
     "description": "Task description"
   }
   ```
3. **PUT** `http://localhost:8080/api/tasks/{id}` - Update task
4. **DELETE** `http://localhost:8080/api/tasks/{id}` - Delete task

### Using HTTPie (command line)

```bash
# Install HTTPie
pip install httpie

# Get tasks
http GET localhost:8080/api/tasks

# Create task
http POST localhost:8080/api/tasks title="Test" description="Testing HTTPie"

# Update task
http PUT localhost:8080/api/tasks/1 title="Updated" completed=true

# Delete task
http DELETE localhost:8080/api/tasks/1
```

## 🐛 Debugging in Eclipse

### Set up Remote Debugging

1. **Add breakpoint**: Double-click left margin in code editor
2. **Debug As → Spring Boot App**
3. **Test endpoint** that hits your breakpoint
4. Use **Debug perspective** to:
   - Step through code (F6)
   - Step into methods (F5)
   - Inspect variables
   - Evaluate expressions

### Debug Configuration

```bash
# Run with debug enabled (if running from terminal)
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

## 🎯 Troubleshooting & Explore

### Common Issues

1. **Port 8080 already in use**

   ```bash
   # Find process using port
   lsof -i :8080  # macOS/Linux
   netstat -ano | findstr :8080  # Windows

   # Or change port in application.properties
   server.port=8081
   ```

2. **Maven dependencies not downloading**

   - Right-click project → Maven → Update Project
   - Check Eclipse → Preferences → Maven → User Settings
   - Verify internet/proxy settings

3. **Lombok not working**

   - Install Lombok in Eclipse: Run lombok.jar
   - VS Code: Lombok Annotations Support extension
   - Rebuild project after installation

4. **Hot reload not working**
   - Ensure DevTools dependency is included
   - Eclipse: Project → Build Automatically is checked
   - VS Code: May need to manually trigger build

### Explore Further

1. **Add custom banner**:

   - Create `src/main/resources/banner.txt`
   - Use [Banner Generator](https://devops.datenkollektiv.de/banner.txt/index.html)

2. **Profile-specific configuration**:

   ```bash
   # Create application-dev.properties
   echo "server.port=8081" > src/main/resources/application-dev.properties

   # Run with profile
   mvn spring-boot:run -Dspring-boot.run.profiles=dev
   ```

3. **Enable colored console output**:

   ```properties
   # Add to application.properties
   spring.output.ansi.enabled=always
   ```

4. **Add API documentation with SpringDoc**:
   ```xml
   <!-- Add to pom.xml dependencies -->
   <dependency>
       <groupId>org.springdoc</groupId>
       <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
       <version>2.3.0</version>
   </dependency>
   ```
   Then visit: http://localhost:8080/swagger-ui.html

## 🏋️ Practice Exercises

### Exercise 1: Add a New Endpoint

Create a search endpoint that filters tasks by title:

```java
// Add to TaskController.java
@GetMapping("/search")
public List<Task> searchTasks(@RequestParam String query) {
    return taskService.getAllTasks().stream()
        .filter(task -> task.getTitle().toLowerCase()
            .contains(query.toLowerCase()))
        .collect(Collectors.toList());
}
```

Test it:

```bash
curl "http://localhost:8080/api/tasks/search?query=docker"
```

### Exercise 2: Add Validation

Add input validation using Spring Boot validation:

1. Add dependency to pom.xml:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

2. Update Task model:

```java
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@NotBlank(message = "Title is required")
@Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
private String title;
```

3. Update controller:

```java
@PostMapping
public ResponseEntity<Task> createTask(@Valid @RequestBody Task task) {
    // existing code
}
```

### Exercise 3: Custom Health Indicator

Create a custom health check:

```java
// Create new file: src/main/java/com/example/dockerdemo/health/CustomHealthIndicator.java
@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Autowired
    private TaskService taskService;

    @Override
    public Health health() {
        long taskCount = taskService.getTaskCount();
        if (taskCount < 100) {
            return Health.up()
                .withDetail("taskCount", taskCount)
                .withDetail("status", "System is healthy")
                .build();
        } else {
            return Health.down()
                .withDetail("taskCount", taskCount)
                .withDetail("status", "Too many tasks!")
                .build();
        }
    }
}
```

## 📝 Self-Assessment Questions

Test your understanding:

1. **What's the purpose of @RestController annotation?**

   - Combines @Controller and @ResponseBody
   - Every method returns data (not views)
   - Automatic JSON serialization

2. **How does Spring Boot DevTools improve development?**

   - Automatic application restart on code changes
   - LiveReload for browser refresh
   - Enhanced error reporting

3. **What's the difference between @GetMapping and @RequestMapping?**

   - @GetMapping is shorthand for @RequestMapping(method = RequestMethod.GET)
   - More readable and specific
   - Part of Spring 4.3+ shortcuts

4. **Why use Lombok in the project?**

   - Reduces boilerplate code
   - Automatic getter/setter generation
   - Cleaner, more maintainable code

5. **What does the Actuator provide?**
   - Production-ready features
   - Health checks, metrics, info
   - Monitoring and management endpoints

## 🎮 Hands-On Challenge

**Challenge**: Extend the API with a Priority System

1. **Add priority field to Task**:

   - Priority levels: HIGH, MEDIUM, LOW
   - Default to MEDIUM

2. **Create priority filtering endpoint**:

   - GET /api/tasks/priority/{priority}
   - Return tasks matching priority

3. **Add priority statistics**:

   - GET /api/tasks/stats
   - Return count by priority

4. **Implement priority-based sorting**:
   - Modify getAllTasks to sort by priority

<details>
<summary>💡 Hint: Click to see solution outline</summary>

```java
// 1. Add enum
public enum Priority {
    HIGH, MEDIUM, LOW
}

// 2. Update Task model
private Priority priority = Priority.MEDIUM;

// 3. Add endpoint
@GetMapping("/priority/{priority}")
public List<Task> getTasksByPriority(@PathVariable Priority priority) {
    return taskService.getTasksByPriority(priority);
}

// 4. Statistics endpoint
@GetMapping("/stats")
public Map<Priority, Long> getTaskStats() {
    return taskService.getTaskStats();
}
```

</details>

## 🔍 Deep Dive: Understanding Annotations

### Essential Spring Boot Annotations

| Annotation               | Purpose                | Example                    |
| ------------------------ | ---------------------- | -------------------------- |
| `@SpringBootApplication` | Main application class | Enables auto-configuration |
| `@RestController`        | REST API controller    | Returns JSON/XML           |
| `@Service`               | Business logic layer   | Singleton bean             |
| `@Autowired`             | Dependency injection   | Auto-wiring beans          |
| `@GetMapping`            | HTTP GET handler       | `@GetMapping("/tasks")`    |
| `@PostMapping`           | HTTP POST handler      | `@PostMapping("/tasks")`   |
| `@RequestBody`           | Parse request body     | JSON → Java object         |
| `@PathVariable`          | URL path parameter     | `/tasks/{id}`              |
| `@RequestParam`          | Query parameter        | `/tasks?status=done`       |

### Lombok Annotations

| Annotation            | Generated Code                               |
| --------------------- | -------------------------------------------- |
| `@Data`               | Getters, setters, toString, equals, hashCode |
| `@Builder`            | Builder pattern implementation               |
| `@NoArgsConstructor`  | Default constructor                          |
| `@AllArgsConstructor` | Constructor with all fields                  |
| `@Slf4j`              | Logger field (log)                           |

## ✅ Module Checklist

Before moving to the next module, ensure you can:

- [ ] Import and run Spring Boot project in Eclipse
- [ ] Access all REST endpoints successfully
- [ ] See hot reload working with code changes
- [ ] Debug the application with breakpoints
- [ ] View Actuator health and metrics
- [ ] Understand the project structure
- [ ] Create, read, update, and delete tasks via API

## 📚 Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Boot in Eclipse](https://spring.io/guides/gs/sts/)
- [REST API Best Practices](https://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api)
- [Lombok Project](https://projectlombok.org/)

---

**Ready for containers? Continue to [Module 02: Dockerfile Basics →](../02-dockerfile-basics/dockerfile-fundamentals.md)**

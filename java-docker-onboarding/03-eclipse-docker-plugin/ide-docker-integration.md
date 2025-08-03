# Module 03: Eclipse Docker Plugin Integration 🔌

Now that you can build and run Docker containers, let's supercharge your development workflow by integrating Docker directly into your IDE! No more switching between terminals and Eclipse.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Install and configure Docker tooling in Eclipse IDE
- ✅ Build images and manage containers without leaving Eclipse
- ✅ Set up remote debugging for containerized Java applications
- ✅ Monitor logs and execute commands from IDE
- ✅ Use VS Code Docker extension as an alternative
- ✅ Implement efficient container development workflows
- ✅ Debug Java applications running inside containers

## 📚 What You'll Master

**Eclipse Docker Integration:**

- Visual container management
- One-click build and run
- Integrated debugging setup
- Log streaming in IDE console

**Developer Productivity:**

- Faster iteration cycles
- Seamless debugging experience
- Visual container inspection

## ⏱️ Time Investment

- **Plugin Setup**: 10 minutes
- **Configuration**: 10 minutes
- **Remote Debugging**: 20 minutes
- **Practice Exercises**: 20 minutes
- **Total**: ~1 hour

## 📋 Prerequisites

- Completed [Module 02: Dockerfile Basics](../02-dockerfile-basics/dockerfile-fundamentals.md)
- Eclipse IDE with Spring Tools installed
- Docker Desktop running
- Built Docker images from previous module
- Basic debugging knowledge

## 🔧 Eclipse Docker Plugin Setup

### Step 1: Install Docker Tooling

1. **Help → Eclipse Marketplace**
2. **Search** for "Docker Tooling"
3. **Install** "Docker Tooling for Eclipse" by Eclipse Foundation
4. **Restart Eclipse** when prompted

Alternative installation via Update Site:

1. **Help → Install New Software**
2. **Add** update site: `https://download.eclipse.org/linuxtools/updates-nightly/`
3. Select **Linux Tools → Docker Tooling**
4. **Install** and restart

### Step 2: Configure Docker Connection

1. **Window → Show View → Other → Docker → Docker Explorer**
2. In Docker Explorer, you should see local Docker connection
3. **Right-click** → **Properties** to verify connection settings
4. Test connection by expanding the connection node

If connection fails:

- Ensure Docker Desktop is running
- Check Docker daemon is accessible: `docker info`
- Verify Docker socket permissions (Linux/macOS)

## 🐳 Docker Operations in Eclipse

### Managing Images

1. **Docker Explorer → Local → Images**
2. **Right-click** on an image for options:
   - **Run...** - Start container with configuration
   - **Tag Image** - Add tags
   - **Remove Image** - Delete image
   - **Push Image** - Push to registry (after login)

### Building Images from Eclipse

1. **Right-click** project → **Build Docker Image**
2. **Select Dockerfile** (should auto-detect)
3. **Configure**:
   - Repository name: `docker-demo:eclipse`
   - Build context: project root
   - Build arguments (if any)
4. **Build** and monitor progress in Console

### Running Containers

1. **Docker Explorer → Images → docker-demo:ubuntu**
2. **Right-click → Run...**
3. **Configure Run Settings**:
   - **Container name**: `demo-eclipse`
   - **Port mapping**: `8080:8080`
   - **Environment variables**: (if needed)
   - **Volume mounts**: (for development)
4. **Run** and verify in Docker Explorer

## 🐛 Remote Debugging Setup

### Step 1: Modify Dockerfile for Debugging

Create `Dockerfile.debug`:

```dockerfile
FROM openjdk:17-jdk-slim

# Set metadata
LABEL maintainer="your-email@example.com"
LABEL description="Spring Boot Docker Demo - Debug enabled"

# Create app directory
WORKDIR /app

# Copy the JAR file
COPY target/docker-demo-0.0.1-SNAPSHOT.jar app.jar

# Expose application and debug ports
EXPOSE 8080 5005

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Run with debug enabled
ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "-jar", "app.jar"]
```

### Step 2: Build Debug Image

```bash
cd 02-dockerfile-basics
docker build -f Dockerfile.debug -t docker-demo:debug .
```

### Step 3: Run Debug Container

From Eclipse:

1. **Docker Explorer → Images → docker-demo:debug**
2. **Right-click → Run...**
3. **Port mapping**:
   - `8080:8080` (application)
   - `5005:5005` (debug port)
4. **Start container**

### Step 4: Configure Eclipse Debug Configuration

1. **Run → Debug Configurations...**
2. **Remote Java Application → New**
3. **Configure**:
   - **Project**: `docker-demo`
   - **Connection Type**: Standard (Socket Attach)
   - **Host**: `localhost`
   - **Port**: `5005`
4. **Apply** and **Debug**

### Step 5: Test Remote Debugging

1. **Set breakpoint** in `TaskController.getAllTasks()`
2. **Call endpoint**: `curl http://localhost:8080/api/tasks`
3. **Debug perspective** should activate
4. **Step through code**, inspect variables

## 📱 Container Management Features

### Eclipse Docker View Features

1. **Container Logs**:

   - Right-click container → **Display Log**
   - Live log streaming in Eclipse console

2. **Execute Commands**:

   - Right-click container → **Execute in Container**
   - Choose shell: `/bin/bash` or `/bin/sh`

3. **File Transfer**:

   - Drag files from Eclipse to container
   - Copy files from container to workspace

4. **Resource Monitoring**:
   - Right-click container → **Show In → Properties**
   - View CPU, memory, network usage

### Advanced Features (Outlook)

1. **Docker Compose Support**:

   - Right-click `docker-compose.yml` → **Run As → Docker Compose**
   - Manage multi-container applications

2. **Registry Integration**:

   - **Docker Explorer → Registries**
   - Add Docker Hub, private registries
   - Push/pull images directly

3. **Dockerfile Editing**:
   - Syntax highlighting
   - Content assist
   - Validation and error checking

## 💻 VS Code Docker Extension Alternative

### Installation and Setup

1. **Install Extensions**:

   - Docker (Microsoft)
   - Java Extension Pack
   - Spring Boot Extension Pack

2. **View Docker**:
   - **View → Docker** (or Ctrl+Shift+P → "Docker: Focus on Docker View")

### Key Features

1. **Image Management**:

   - View images in Docker Explorer
   - Right-click for run, tag, remove options
   - Build images from Dockerfile

2. **Container Operations**:

   - Start, stop, remove containers
   - View logs (Ctrl+Shift+P → "Docker Logs")
   - Attach shell (right-click container → "Attach Shell")

3. **Remote Debugging**:

   ```json
   // .vscode/launch.json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "type": "java",
         "name": "Debug Docker Container",
         "request": "attach",
         "hostName": "localhost",
         "port": 5005
       }
     ]
   }
   ```

4. **Dev Containers** (Advanced):
   - Develop inside containers
   - `.devcontainer/devcontainer.json` configuration
   - Full IDE experience in container

## 🔧 Practical Exercises

### Exercise 1: Build and Debug from Eclipse

1. **Import project** from Module 02
2. **Build image** using Eclipse Docker plugin
3. **Run container** with debug port exposed
4. **Connect debugger** and test breakpoints
5. **Modify code**, rebuild, and redeploy

### Exercise 2: Container Inspection

1. **Run Alpine and Ubuntu containers** side by side
2. **Compare**:
   - Process lists: `ps aux`
   - Package managers: `apk` vs `apt`
   - Disk usage: `df -h`
3. **Document differences** in comment

### Exercise 3: Log Management

1. **Generate application logs** by calling endpoints
2. **View logs** in Eclipse Docker view
3. **Filter logs** by log level
4. **Export logs** to file for analysis

## 🎯 Development Workflow Integration

### Recommended Workflow

1. **Code Changes**:

   - Make changes in Eclipse
   - Use Spring Boot DevTools for quick testing

2. **Container Testing**:

   - Build image from Eclipse
   - Run container with port mapping
   - Test API endpoints

3. **Debugging**:

   - Run debug container
   - Connect Eclipse debugger
   - Debug issues in containerized environment

4. **Iteration**:
   - Stop container
   - Rebuild image with changes
   - Redeploy and test

### Hot Reload in Containers (Preview)

For development containers with volume mounting:

```dockerfile
# Development Dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
# Mount source code as volume
VOLUME ["/app/src"]
# Copy dependencies only
COPY target/dependency/* ./lib/
# Use development profile
ENV SPRING_PROFILES_ACTIVE=dev
# Enable debugging
EXPOSE 8080 5005
ENTRYPOINT ["java", "-cp", "lib/*:.", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "com.example.dockerdemo.DockerDemoApplication"]
```

## 🐛 Troubleshooting & Explore

### Common Issues

1. **Eclipse Docker plugin not connecting**:

   - Verify Docker Desktop is running
   - Check Eclipse error log: **Window → Show View → Error Log**
   - Restart Eclipse and Docker Desktop

2. **Remote debugging not working**:

   - Verify debug port is exposed: `docker port container-name`
   - Check firewall/network settings
   - Ensure JDWP agent is running: check container logs

3. **Can't see images/containers**:

   - Refresh Docker Explorer: **F5**
   - Check Docker connection in preferences
   - Verify Docker CLI works: `docker ps`

4. **Build context too large**:
   - Add `.dockerignore` file
   - Exclude `target/`, `node_modules/`, etc.
   - Use specific COPY instructions

### Advanced Exploration

1. **Docker Registry Integration**:

   ```bash
   # Login to Docker Hub from Eclipse
   # Docker Explorer → Registries → Add Registry
   # Use Docker Hub credentials
   ```

2. **Multi-platform builds**:

   ```bash
   # Build for different architectures
   docker buildx build --platform linux/amd64,linux/arm64 -t docker-demo:multi .
   ```

3. **Container health monitoring**:

   - Add health checks to Dockerfile
   - Monitor in Eclipse Docker view
   - Set up alerts for unhealthy containers

4. **Eclipse Docker Compose**:
   - Install Docker Compose plugin
   - Manage multi-container apps
   - View service dependencies

## 🔍 Comparison: Eclipse vs VS Code

| Feature              | Eclipse Docker Plugin      | VS Code Docker Extension |
| -------------------- | -------------------------- | ------------------------ |
| **Installation**     | Marketplace/Update Site    | Extension marketplace    |
| **Image Management** | Full GUI with properties   | Explorer tree view       |
| **Container Logs**   | Integrated console         | Terminal output          |
| **Debugging**        | Native Java debugging      | Launch configurations    |
| **File Transfer**    | Drag & drop                | Command palette          |
| **Docker Compose**   | Plugin required            | Built-in support         |
| **Dev Containers**   | Limited                    | Full support             |
| **Learning Curve**   | Familiar for Eclipse users | Simpler, more intuitive  |

## 🏋️ Practice Exercises

### Exercise 1: Build and Debug Cycle

Complete a full development cycle in Eclipse:

1. **Make a code change** in TaskController:

   ```java
   @GetMapping("/debug-test")
   public Map<String, String> debugTest() {
       String message = "Debugging from container!";
       System.out.println("Debug endpoint called");
       return Map.of("message", message, "timestamp", LocalDateTime.now().toString());
   }
   ```

2. **Build image from Eclipse**:

   - Right-click project → Build Docker Image
   - Tag as `docker-demo:debug-test`

3. **Run with debug port**:

   - Docker Explorer → Run → Configure ports
   - Map 8080:8080 and 5005:5005

4. **Set breakpoint** on the `message` line

5. **Attach debugger** and hit the endpoint

### Exercise 2: Container File Operations

Practice file management:

1. **Create a test file** in container:

   ```bash
   # From Eclipse Docker Explorer
   Right-click container → Execute in Container
   echo "Test from Eclipse" > /tmp/test.txt
   ```

2. **Copy file from container**:

   - Right-click container → Copy From Container
   - Source: `/tmp/test.txt`
   - Destination: Your workspace

3. **Modify and copy back**:
   - Edit the file locally
   - Drag to container in Docker Explorer

### Exercise 3: Multi-Container Debugging

Debug with database container:

1. **Start MariaDB**:

   ```bash
   docker run -d --name test-db \
     -e MYSQL_ROOT_PASSWORD=secret \
     -e MYSQL_DATABASE=testdb \
     -p 3306:3306 \
     mariadb:latest
   ```

2. **Update application.properties**:

   ```properties
   spring.datasource.url=jdbc:mysql://test-db:3306/testdb
   spring.datasource.username=root
   spring.datasource.password=secret
   ```

3. **Run app container** on same network:
   - Create network in Docker Explorer
   - Run both containers on that network
   - Debug database connections

### Exercise 4: VS Code Alternative

If you have VS Code, try the same workflow:

1. **Install Docker extension**
2. **Open the project** in VS Code
3. **Right-click Dockerfile** → Build Image
4. **Docker view** → Images → Run
5. **Add debug configuration** to `.vscode/launch.json`
6. **F5** to attach debugger

## 📝 Self-Assessment Questions

Test your IDE integration knowledge:

1. **What's the advantage of IDE Docker integration?**

   - Unified development environment
   - Visual management of containers
   - Integrated debugging workflow
   - Reduced context switching

2. **How does remote debugging work?**

   - JVM opens debug port (5005)
   - IDE connects via Debug Wire Protocol
   - Breakpoints work across network
   - Code must match running version

3. **What's the difference between "Execute in Container" and SSH?**

   - Execute: Runs command via Docker API
   - No SSH server needed in container
   - More secure (no exposed SSH port)
   - Works with minimal containers

4. **Why might VS Code be preferred for containers?**

   - Better Docker Compose support
   - Dev Containers feature
   - More active development
   - Lighter resource usage

5. **What are Dev Containers (VS Code)?**
   - Development inside containers
   - Full IDE features in container
   - Consistent dev environments
   - Configuration as code

## 🎮 Hands-On Challenge

**Challenge**: Create a Complete Debug-Ready Development Setup

Requirements:

1. Custom Dockerfile with debug support
2. Eclipse debug configuration
3. Volume mount for hot reload
4. Health check visible in IDE
5. One-click build and run

<details>
<summary>💡 Solution Guide</summary>

1. **Enhanced Dockerfile.dev**:

```dockerfile
FROM openjdk:17-jdk-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
VOLUME ["/app"]
EXPOSE 8080 5005
ENV JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
HEALTHCHECK CMD curl -f http://localhost:8080/actuator/health || exit 1
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

2. **Eclipse Run Configuration**:

   - Name: "Spring Boot Debug Container"
   - Image: docker-demo:dev
   - Ports: 8080:8080, 5005:5005
   - Volumes: ${workspace_loc}/target:/app

3. **Remote Debug Configuration**:

   - Type: Remote Java Application
   - Connection Type: Standard (Socket Attach)
   - Host: localhost
   - Port: 5005

4. **One-click Script** (External Tool):

```bash
#!/bin/bash
mvn clean package
docker build -f Dockerfile.dev -t docker-demo:dev .
docker run -d -p 8080:8080 -p 5005:5005 \
  -v $(pwd)/target:/app \
  --name debug-container \
  docker-demo:dev
```

</details>

## 🔍 Deep Dive: Debugging Architecture

### How Remote Debugging Works

```
Eclipse IDE                     Docker Container
│                              │
│  Debugger Client             │  JVM with Debug Agent
│  (localhost:5005) ←──────────┤  (-agentlib:jdwp)
│                              │
│  Breakpoints      ←──────────┤  Execution Control
│  Variables        ←──────────┤  Runtime State
│  Step Commands    ──────────→│  Flow Control
```

### Network Considerations

- **Same machine**: Use localhost
- **Remote Docker**: Use machine IP
- **Docker Machine**: Use `docker-machine ip`
- **Inside container**: Not localhost!

### Common Issues & Solutions

1. **"Connection refused on port 5005"**

   - Check port mapping: `-p 5005:5005`
   - Verify debug agent: `address=*:5005`
   - Check firewall rules

2. **"Source not found"**

   - Ensure project is in Eclipse workspace
   - Source must match running code
   - Check build path configuration

3. **Breakpoints not hitting**
   - Verify code is actually executed
   - Check for conditional breakpoints
   - Ensure debug mode is active

## 🎯 Productivity Tips

1. **Eclipse Keyboard Shortcuts**:

   - `Ctrl+Shift+D, D`: Show Docker Explorer
   - `F11`: Debug last launched
   - `Ctrl+Shift+B`: Toggle breakpoint

2. **Workflow Optimization**:

   - Keep Docker Explorer visible
   - Use Working Sets for containers
   - Create launch configurations
   - Use External Tools for scripts

3. **Performance Tips**:
   - Limit container resources in development
   - Use volume mounts for source code
   - Leverage build cache
   - Clean up stopped containers regularly

## ✅ Module Checklist

Before proceeding, ensure you can:

- [ ] Install and configure Eclipse Docker plugin
- [ ] Build Docker images from Eclipse IDE
- [ ] Run and manage containers from Eclipse
- [ ] Connect remote debugger to containerized Java application
- [ ] View container logs and execute commands
- [ ] Use VS Code Docker extension as alternative
- [ ] Debug Java application running in container

## 📚 Additional Resources

- [Eclipse Docker Tooling Documentation](https://www.eclipse.org/linuxtools/projectPages/docker/)
- [VS Code Docker Extension Guide](https://code.visualstudio.com/docs/containers/overview)
- [Remote Java Debugging](https://www.baeldung.com/java-application-remote-debugging)
- [Docker Development Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Ready to optimize your Docker images? Continue to [Module 04: Multi-stage Builds →](../04-multistage-builds/)**

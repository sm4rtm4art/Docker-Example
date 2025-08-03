# Part B: Debugging in Containers 🐛

Master debugging techniques that make troubleshooting containerized applications feel natural. Learn remote debugging, log management, and network troubleshooting that work across all languages.

## 🎯 Learning Outcomes

- ✅ Set up remote debugging for Java, Python, and Rust applications
- ✅ Effectively use container logs and log aggregation
- ✅ Debug network connectivity and port forwarding issues
- ✅ Troubleshoot container startup and runtime problems
- ✅ Use interactive debugging sessions in containers
- ✅ Diagnose performance and resource constraint issues

## 🚨 The Debugging Challenge

### Common Developer Frustrations

```bash
# These scenarios sound familiar?
"My app works locally but breaks in the container"
"I can't see what's happening inside the container"
"The debugger won't connect to the containerized app"
"Logs are scattered and hard to follow"
"Network calls fail but I don't know why"
```

**The Solution**: Proper debugging setup makes containers as debuggable as local applications!

## 🔍 Container Logging Strategies

### Basic Log Viewing

```bash
# View current logs
docker-compose logs task-api

# Follow logs in real-time
docker-compose logs -f task-api

# View last 100 lines
docker-compose logs --tail 100 task-api

# Show timestamps
docker-compose logs -t task-api

# Multiple services
docker-compose logs -f task-api postgres
```

### Structured Logging Setup

**Python (FastAPI) Logging**:

```python
# src/logging_config.py
import logging
import sys
from datetime import datetime

def setup_logging():
    """Configure structured logging for containers"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        stream=sys.stdout  # Important: Use stdout in containers
    )

    # Add request ID for tracing
    logger = logging.getLogger("task-api")
    return logger

# src/main.py
from logging_config import setup_logging

logger = setup_logging()

@app.get("/tasks")
async def list_tasks():
    logger.info(f"Fetching tasks at {datetime.now()}")
    try:
        tasks = await get_all_tasks()
        logger.info(f"Successfully fetched {len(tasks)} tasks")
        return {"tasks": tasks}
    except Exception as e:
        logger.error(f"Failed to fetch tasks: {str(e)}")
        raise
```

**Java (Spring Boot) Logging**:

```yaml
# src/main/resources/application-dev.yml
logging:
  level:
    com.example.dockerdemo: DEBUG
    org.springframework.web: DEBUG
  pattern:
    console: "%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: /app/logs/application.log
```

## 🐍 Python: Remote Debugging with PyCharm/VS Code

### Step 1: Enable Debug Mode

**Dockerfile.debug**:

```dockerfile
FROM python:3.12-slim

# Install debugging tools
RUN pip install debugpy fastapi uvicorn

# Create non-root user
RUN useradd -m -u 1000 debuguser
USER debuguser

WORKDIR /app

# Debug configuration
EXPOSE 8080 5678

# Start with debugger
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
```

### Step 2: Debug Compose Configuration

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.debug
    ports:
      - "8080:8080"
      - "5678:5678" # Debug port
    volumes:
      - ./src:/app/src:cached
    environment:
      - PYTHONPATH=/app
      - PYTHONUNBUFFERED=1
```

### Step 3: IDE Configuration

**VS Code (.vscode/launch.json)**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Remote Attach",
      "type": "python",
      "request": "attach",
      "connect": {
        "host": "localhost",
        "port": 5678
      },
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}/src",
          "remoteRoot": "/app/src"
        }
      ]
    }
  ]
}
```

**PyCharm Configuration**:

1. Run → Edit Configurations
2. Add → Python → Python Debug Server
3. Host: `localhost`, Port: `5678`
4. Path mappings: `./src` → `/app/src`

## ☕ Java: Remote Debugging with IntelliJ/Eclipse

### Step 1: Enable JVM Debug Mode

**Dockerfile.debug**:

```dockerfile
FROM eclipse-temurin:21-jdk-alpine

# Create non-root user
RUN addgroup -g 1000 debuguser && adduser -D -s /bin/sh -u 1000 -G debuguser debuguser

RUN apk add --no-cache maven

WORKDIR /app
RUN chown debuguser:debuguser /app
USER debuguser

# Expose debug port
EXPOSE 8080 5005

# JVM debug options
ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

CMD ["mvn", "spring-boot:run"]
```

### Step 2: Debug Compose Configuration

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.debug
    ports:
      - "8080:8080"
      - "5005:5005" # Debug port
    volumes:
      - ./src:/app/src:cached
      - ./pom.xml:/app/pom.xml:ro
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

### Step 3: IntelliJ Configuration

1. Run → Edit Configurations
2. Add → Remote JVM Debug
3. Host: `localhost`, Port: `5005`
4. Module classpath: Select your project module

## 🦀 Rust: Debugging with rust-gdb/lldb

### Step 1: Debug-Enabled Dockerfile

**Dockerfile.debug**:

```dockerfile
FROM rust:1.75-alpine

# Install debugging tools
RUN apk add --no-cache musl-dev gdb

# Create non-root user
RUN addgroup -g 1000 debuguser && adduser -D -s /bin/sh -u 1000 -G debuguser debuguser

WORKDIR /app
RUN chown debuguser:debuguser /app
USER debuguser

# Build with debug symbols
ENV RUSTFLAGS="-C debuginfo=2"

CMD ["cargo", "run"]
```

### Step 2: Debug Build Configuration

**Cargo.toml**:

```toml
[profile.dev]
debug = true
opt-level = 0

[profile.release]
debug = true  # Keep symbols for production debugging
```

### Step 3: GDB Remote Debugging

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.debug
    ports:
      - "8080:8080"
    volumes:
      - ./src:/app/src:cached
    # Keep container running for debugging
    command: ["tail", "-f", "/dev/null"]
    stdin_open: true
    tty: true
```

**Usage**:

```bash
# Start container with debug build
docker-compose up -d task-api

# Execute into container
docker-compose exec task-api sh

# Run with gdb
cargo build
gdb target/debug/task-api
```

## 🌐 Network Debugging

### Container-to-Container Communication

```bash
# Test service discovery
docker-compose exec task-api nslookup postgres

# Test port connectivity
docker-compose exec task-api nc -zv postgres 5432

# Check network configuration
docker network ls
docker network inspect <network_name>
```

### Common Network Issues

**Issue 1: Service Not Found**

```bash
# Problem: Cannot connect to 'postgres'
# Solution: Check service names in compose file
docker-compose exec task-api nslookup postgres
docker-compose exec task-api ping postgres
```

**Issue 2: Connection Refused**

```bash
# Problem: Connection refused on port 5432
# Solution: Check if service is listening
docker-compose exec postgres netstat -tuln
docker-compose logs postgres
```

**Issue 3: Port Binding Issues**

```bash
# Problem: Port already in use
# Solution: Check what's using the port
sudo lsof -i :8080
docker ps -a
```

## 🔧 Interactive Debugging Sessions

### Method 1: Exec Into Running Container

```bash
# Start your application
docker-compose up -d task-api

# Get an interactive shell
docker-compose exec task-api /bin/bash

# Or specific user
docker-compose exec --user root task-api /bin/bash

# Run debugging commands
ps aux
ls -la /app
env | grep -i path
```

### Method 2: Override Entry Point for Debugging

```yaml
# docker-compose.debug.yml
version: "3.8"
services:
  task-api:
    entrypoint: ["/bin/bash"]
    command: ["-c", "sleep infinity"]
    stdin_open: true
    tty: true
```

Usage:

```bash
# Start in debug mode
docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d

# Attach to container
docker-compose exec task-api /bin/bash

# Manually start your application
cd /app && python src/main.py
```

## 📊 Performance and Resource Debugging

### Monitor Container Resources

```bash
# Real-time resource usage
docker stats

# Specific container stats
docker stats task-api

# Container processes
docker-compose exec task-api top

# Memory usage details
docker-compose exec task-api cat /proc/meminfo

# Disk usage
docker-compose exec task-api df -h
```

### Resource Limit Testing

```yaml
# docker-compose.yml - Add resource limits for testing
services:
  task-api:
    build: .
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "0.5"
        reservations:
          memory: 256M
          cpus: "0.25"
```

**Monitor limit violations**:

```bash
# Check if container is hitting limits
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Check OOM kills
dmesg | grep -i "killed process"
```

## 🚨 Common Debugging Scenarios

### Scenario 1: Application Won't Start

**Debugging Steps**:

```bash
# 1. Check container logs
docker-compose logs task-api

# 2. Check if process is running
docker-compose exec task-api ps aux

# 3. Try starting manually
docker-compose exec task-api /bin/bash
# Then manually run your startup command

# 4. Check file permissions
docker-compose exec task-api ls -la /app

# 5. Check environment variables
docker-compose exec task-api env
```

### Scenario 2: Database Connection Fails

**Debugging Steps**:

```bash
# 1. Check if database container is running
docker-compose ps

# 2. Test network connectivity
docker-compose exec task-api nc -zv postgres 5432

# 3. Check database logs
docker-compose logs postgres

# 4. Verify credentials
docker-compose exec postgres psql -U postgres -d tasks -c '\l'

# 5. Check connection string
docker-compose exec task-api env | grep -i db
```

### Scenario 3: API Returns 500 Errors

**Debugging Steps**:

```bash
# 1. Enable debug logging
# Add to docker-compose.yml:
environment:
  - LOG_LEVEL=DEBUG

# 2. Follow application logs
docker-compose logs -f task-api

# 3. Test API endpoints manually
docker-compose exec task-api curl localhost:8080/health

# 4. Check application status
docker-compose exec task-api ps aux | grep python
```

## ✅ Hands-On Exercise: Debug Hunt Challenge

### Set Up a Broken Application

Create this intentionally broken configuration:

```yaml
# docker-compose.broken.yml
version: "3.8"
services:
  task-api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:wrongpassword@database:5432/tasks
    depends_on:
      - database

  database:
    image: postgres:16
    environment:
      - POSTGRES_DB=tasks
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=correctpassword
```

### Your Mission: Debug and Fix

1. **Start the broken stack**: `docker-compose -f docker-compose.broken.yml up`
2. **Identify the issues** using the debugging techniques you learned
3. **Fix the configuration** and verify it works
4. **Document your debugging process**

### Expected Issues to Find

- [ ] Database connection failure (wrong password)
- [ ] Network connectivity problems
- [ ] Environment variable mismatches
- [ ] Container startup order issues

## 🎉 What You've Mastered

🐛 **Debugging superpowers!** You can now troubleshoot containerized applications as effectively as local ones. You've learned remote debugging, log analysis, network troubleshooting, and performance monitoring!

**Next**: Complete your development workflow with [Part C: IDE Integration](./03-ide-integration.md) for seamless editor integration!

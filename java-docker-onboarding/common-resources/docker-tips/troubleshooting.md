# Docker & Podman Troubleshooting Guide 🚨

Comprehensive solutions for common issues you'll encounter during your Java containerization journey.

## 🎯 Quick Issue Navigator

- [Build Issues](#build-issues)
- [Runtime Issues](#runtime-issues)
- [Networking Problems](#networking-problems)
- [Performance Issues](#performance-issues)
- [Security & Permissions](#security--permissions)
- [Java-Specific Issues](#java-specific-issues)
- [IDE Integration Problems](#ide-integration-problems)
- [Platform-Specific Issues](#platform-specific-issues)

---

## 🏗️ Build Issues

### ❌ "Cannot find target/\*.jar"

**Problem:** Dockerfile can't find the JAR file

```
COPY target/docker-demo-0.0.1-SNAPSHOT.jar app.jar
# Error: COPY failed: file not found
```

**Solutions:**

```bash
# 1. Build the JAR first
mvn clean package

# 2. Check if JAR exists
ls -la target/*.jar

# 3. Use wildcard pattern in Dockerfile
COPY target/*.jar app.jar

# 4. Check .dockerignore isn't excluding target/
cat .dockerignore | grep -v target
```

**Prevention:**

```dockerfile
# Multi-stage build approach
FROM maven:3.8.6-openjdk-17-slim AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:17-jre-slim
COPY --from=builder /app/target/*.jar app.jar
```

### ❌ "Build Context Too Large"

**Problem:** Docker build is slow or fails due to large context

```
Sending build context to Docker daemon  2.5GB
```

**Solutions:**

```bash
# 1. Create/update .dockerignore
cat > .dockerignore << 'EOF'
.git
.gitignore
*.md
.idea/
.vscode/
target/classes
target/test-classes
node_modules/
*.log
.DS_Store
EOF

# 2. Check build context size
du -sh .

# 3. Use specific COPY instructions
COPY target/*.jar app.jar  # Instead of COPY . .
```

### ❌ "Package Not Found" (Alpine)

**Problem:** Packages can't be installed on Alpine

```
RUN apt-get install curl
# Error: apt-get: command not found
```

**Solutions:**

```dockerfile
# Alpine uses apk, not apt
RUN apk add --no-cache curl

# Ubuntu/Debian uses apt
RUN apt-get update && apt-get install -y curl
```

**Package Manager Reference:**
| OS | Package Manager | Install Command | Update Command |
|----|----------------|----------------|----------------|
| Alpine | apk | `apk add curl` | `apk update` |
| Ubuntu/Debian | apt | `apt-get install curl` | `apt-get update` |
| CentOS/RHEL | yum/dnf | `yum install curl` | `yum update` |

---

## 🚀 Runtime Issues

### ❌ "Port Already in Use"

**Problem:** Can't bind to port 8080

```bash
docker run -p 8080:8080 myapp
# Error: port is already allocated
```

**Solutions:**

```bash
# 1. Find what's using the port
lsof -i :8080          # macOS/Linux
netstat -ano | findstr :8080  # Windows

# 2. Stop the conflicting process
docker stop $(docker ps -q --filter "publish=8080")

# 3. Use different port
docker run -p 8081:8080 myapp

# 4. Kill all containers on that port
docker kill $(docker ps -q --filter "publish=8080-8080")
```

### ❌ "Container Exits Immediately"

**Problem:** Container starts then stops

```bash
docker run myapp
# Container exits with code 0 or 1
```

**Debugging Steps:**

```bash
# 1. Check container logs
docker logs container-name

# 2. Run interactively
docker run -it myapp /bin/bash

# 3. Check if main process exits
docker run -it myapp java -jar app.jar

# 4. Override entrypoint for debugging
docker run -it --entrypoint="" myapp /bin/bash
```

**Common Causes:**

- Main process finishes execution
- Application crashes on startup
- Missing dependencies
- Wrong ENTRYPOINT/CMD format

### ❌ "Cannot Connect to Application"

**Problem:** App runs but can't access endpoints

```bash
curl http://localhost:8080
# Connection refused
```

**Debugging Checklist:**

```bash
# 1. Is container running?
docker ps

# 2. Check port mapping
docker port container-name

# 3. Check application logs
docker logs -f container-name

# 4. Test from inside container
docker exec -it container-name curl http://localhost:8080

# 5. Check if app binds to 0.0.0.0 (not 127.0.0.1)
docker exec -it container-name netstat -tlnp
```

**Spring Boot Fix:**

```properties
# In application.properties
server.address=0.0.0.0
server.port=8080
```

---

## 🌐 Networking Problems

### ❌ "Container-to-Container Communication Fails"

**Problem:** Containers can't reach each other

```bash
docker run --name app1 myapp
docker run --name app2 myapp
# app2 can't reach app1
```

**Solutions:**

```bash
# 1. Use custom network
docker network create mynetwork
docker run --network mynetwork --name app1 myapp
docker run --network mynetwork --name app2 myapp

# 2. Use container names as hostnames
# From app2: curl http://app1:8080

# 3. Check network connectivity
docker exec -it app2 ping app1
docker exec -it app2 nslookup app1
```

### ❌ "DNS Resolution Issues"

**Problem:** Can't resolve external domains

```bash
docker exec -it container curl https://google.com
# Could not resolve host
```

**Solutions:**

```bash
# 1. Check Docker daemon DNS
docker run --rm busybox nslookup google.com

# 2. Set custom DNS
docker run --dns=8.8.8.8 myapp

# 3. Check host DNS
cat /etc/resolv.conf

# 4. Restart Docker service
sudo systemctl restart docker  # Linux
# Restart Docker Desktop        # Mac/Windows
```

---

## ⚡ Performance Issues

### ❌ "Slow Build Times"

**Problem:** Docker builds take too long

```bash
docker build -t myapp .
# Takes 10+ minutes
```

**Optimization Strategies:**

```dockerfile
# 1. Order instructions by change frequency
FROM openjdk:17-jre-slim

# Dependencies (rarely change)
COPY pom.xml .
RUN mvn dependency:go-offline

# Source code (changes frequently)
COPY src ./src
RUN mvn package

# 2. Use multi-stage builds
FROM maven:3.8.6-openjdk-17-slim AS builder
# ... build steps ...

FROM openjdk:17-jre-slim
COPY --from=builder /app/target/*.jar app.jar

# 3. Use .dockerignore
echo "target/" >> .dockerignore
echo ".git/" >> .dockerignore
```

### ❌ "High Memory Usage"

**Problem:** Containers use too much memory

```bash
docker stats
# CONTAINER   MEM USAGE / LIMIT   MEM %
# myapp       2GB / 4GB          50%
```

**Solutions:**

```bash
# 1. Set memory limits
docker run -m 512m myapp

# 2. Optimize JVM settings
docker run -e JAVA_OPTS="-Xmx256m -Xms128m" myapp

# 3. Use container-aware JVM flags
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# 4. Monitor heap usage
docker exec -it container jstat -gc $(pidof java)
```

---

## 🛡️ Security & Permissions

### ❌ "Permission Denied" Errors

**Problem:** Can't write files or access resources

```bash
docker exec -it container touch /app/test.txt
# Permission denied
```

**Solutions:**

```bash
# 1. Check user context
docker exec -it container whoami
docker exec -it container id

# 2. Run as root for debugging
docker exec -it --user root container /bin/bash

# 3. Fix ownership in Dockerfile
RUN chown -R spring:spring /app
USER spring:spring

# 4. Use proper COPY ownership
COPY --chown=spring:spring app.jar /app/
```

### ❌ "Docker Daemon Permission Issues"

**Problem:** Docker commands require sudo

```bash
docker ps
# permission denied while trying to connect to Docker daemon socket
```

**Solutions:**

```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# Alternative: Use rootless Docker
dockerd-rootless-setuptool.sh install

# Check Docker socket permissions
ls -la /var/run/docker.sock

# Podman alternative (rootless by default)
podman ps  # No sudo needed
```

### ❌ "Rootless Container Issues"

**Problem:** Features don't work in rootless mode

```bash
podman run --privileged myapp
# Warning: running in rootless mode
```

**Solutions:**

```bash
# 1. Check rootless configuration
podman unshare cat /proc/self/uid_map

# 2. Enable rootless features
echo 'user.max_user_namespaces=15000' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Use proper port ranges (>1024)
podman run -p 8080:8080 myapp  # ✅ Works
podman run -p 80:8080 myapp    # ❌ Needs root
```

---

## ☕ Java-Specific Issues

### ❌ "OutOfMemoryError in Container"

**Problem:** Java app crashes with OOM

```
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
```

**Solutions:**

```dockerfile
# 1. Set explicit heap size
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 2. Use container-aware JVM
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# 3. Enable heap dumps for debugging
ENV JAVA_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp"

# 4. Monitor memory in container
RUN apt-get update && apt-get install -y procps
```

**Runtime Memory Monitoring:**

```bash
# Check container memory limit
docker inspect container | grep -i memory

# Check Java process memory
docker exec -it container ps aux | grep java

# Get heap usage
docker exec -it container jstat -gc $(pidof java)
```

### ❌ "Spring Boot Won't Start"

**Problem:** Spring Boot application fails to start

```
APPLICATION FAILED TO START
Description: Failed to configure a DataSource
```

**Common Issues & Solutions:**

```bash
# 1. Missing environment variables
docker run -e SPRING_PROFILES_ACTIVE=dev myapp

# 2. Database connection issues
docker run -e SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/mydb myapp

# 3. Port already in use
docker run -e SERVER_PORT=8081 myapp

# 4. Check application.properties
docker exec -it container cat /app/application.properties
```

### ❌ "Remote Debugging Not Working"

**Problem:** Can't connect debugger to containerized app

```bash
# Debug port exposed but connection fails
docker run -p 5005:5005 -p 8080:8080 myapp
```

**Solutions:**

```dockerfile
# 1. Ensure debug agent binds to all interfaces
ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "-jar", "app.jar"]

# 2. Check port mapping
docker port container-name

# 3. Test debug port
telnet localhost 5005

# 4. Check firewall settings
# Make sure port 5005 is open
```

**IDE Debug Configuration:**

```
Host: localhost
Port: 5005
Transport: Socket
Debugger mode: Attach
```

---

## 🖥️ IDE Integration Problems

### ❌ "Eclipse Docker Plugin Not Working"

**Problem:** Can't see Docker containers in Eclipse

```
Docker Explorer shows "No connection available"
```

**Solutions:**

```bash
# 1. Check Docker daemon is running
docker info

# 2. Restart Eclipse Docker connection
# Right-click connection → Refresh

# 3. Check Docker socket path
# Windows: npipe:////./pipe/docker_engine
# macOS/Linux: unix:///var/run/docker.sock

# 4. Use Docker Desktop with enabled API
# Docker Desktop → Settings → General → Expose daemon on tcp://localhost:2376
```

### ❌ "VS Code Can't Connect to Containers"

**Problem:** Docker extension doesn't show containers

```
"Failed to connect. Is Docker running?"
```

**Solutions:**

```bash
# 1. Check VS Code Docker extension settings
# File → Preferences → Settings → Docker

# 2. Set correct Docker path
"docker.dockerPath": "docker"

# 3. For Podman users
"docker.dockerPath": "podman"

# 4. Reload VS Code window
# Ctrl+Shift+P → "Developer: Reload Window"
```

---

## 💻 Platform-Specific Issues

### 🍎 macOS Issues

**❌ "Volume Mounts Slow"**

```bash
# Problem: -v /host/path:/container/path is slow
docker run -v /Users/me/code:/app myapp
```

**Solutions:**

```bash
# 1. Use :cached for read-heavy workloads
docker run -v /Users/me/code:/app:cached myapp

# 2. Use :delegated for write-heavy workloads
docker run -v /Users/me/code:/app:delegated myapp

# 3. Use Docker Desktop performance settings
# Docker Desktop → Preferences → Resources → Advanced → Disk image location
```

**❌ "M1 Mac Compatibility Issues"**

```bash
# Problem: Image built for x86_64 won't run
docker run myapp
# WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8)
```

**Solutions:**

```bash
# 1. Build for correct platform
docker build --platform linux/arm64 -t myapp .

# 2. Use multi-platform base images
FROM --platform=linux/arm64 openjdk:17-jre-slim

# 3. Force x86_64 emulation (slower)
docker run --platform linux/amd64 myapp
```

### 🪟 Windows Issues

**❌ "Line Ending Issues"**

```bash
# Problem: Scripts fail with "bad interpreter"
/bin/bash^M: bad interpreter: No such file or directory
```

**Solutions:**

```bash
# 1. Configure Git to handle line endings
git config --global core.autocrlf false

# 2. Convert existing files
dos2unix script.sh

# 3. Set Git attributes
echo "*.sh text eol=lf" >> .gitattributes
```

**❌ "WSL2 Integration Issues"**

```bash
# Problem: Docker Desktop not accessible from WSL2
docker: command not found
```

**Solutions:**

```bash
# 1. Enable WSL2 integration in Docker Desktop
# Docker Desktop → Settings → Resources → WSL Integration

# 2. Install Docker in WSL2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Use Docker Desktop from WSL2
export DOCKER_HOST=tcp://localhost:2375
```

### 🐧 Linux Issues

**❌ "SELinux Issues"**

```bash
# Problem: Permission denied despite correct ownership
docker run -v /host/data:/app/data myapp
# Permission denied
```

**Solutions:**

```bash
# 1. Check SELinux status
sestatus

# 2. Use Z flag for SELinux labeling
docker run -v /host/data:/app/data:Z myapp

# 3. Temporarily disable SELinux (not recommended)
sudo setenforce 0

# 4. Create SELinux policy (advanced)
setsebool -P container_manage_cgroup on
```

---

## 🆘 Emergency Procedures

### 🔥 "Everything is Broken"

When nothing works, try these nuclear options:

```bash
# 1. Stop all containers
docker stop $(docker ps -q)
podman stop $(podman ps -q)

# 2. Remove all containers
docker rm $(docker ps -aq)
podman rm $(podman ps -aq)

# 3. Remove all images
docker rmi $(docker images -q)
podman rmi $(podman images -q)

# 4. Clean everything
docker system prune -af --volumes
podman system prune -af --volumes

# 5. Reset Docker Desktop (GUI)
# Docker Desktop → Troubleshoot → Reset to factory defaults

# 6. Reset Podman
podman system reset
```

### 🔄 "Fresh Start Procedure"

Complete environment reset:

```bash
# 1. Uninstall Docker/Podman
sudo apt remove docker.io podman  # Ubuntu
brew uninstall docker podman      # macOS

# 2. Remove data directories
sudo rm -rf /var/lib/docker
rm -rf ~/.local/share/containers

# 3. Reinstall
# Follow installation guides in Module 00

# 4. Verify installation
docker --version
podman --version
docker run hello-world
podman run hello-world
```

---

## 🔍 Diagnostic Commands

### System Information

```bash
# Docker system info
docker info
docker version

# Podman system info
podman info
podman version

# Check resource usage
docker system df
podman system df

# Check running processes
docker ps -a
podman ps -a
```

### Network Diagnostics

```bash
# List networks
docker network ls
podman network ls

# Inspect network
docker network inspect bridge
podman network inspect podman

# Test connectivity
docker run --rm nicolaka/netshoot ping google.com
podman run --rm nicolaka/netshoot ping google.com
```

### Container Diagnostics

```bash
# Detailed container info
docker inspect container-name
podman inspect container-name

# Resource usage
docker stats container-name
podman stats container-name

# Process list
docker top container-name
podman top container-name

# File system changes
docker diff container-name
podman diff container-name
```

---

## 📞 Getting Help

### Community Resources

- **Docker Community**: https://forums.docker.com
- **Podman Issues**: https://github.com/containers/podman/issues
- **Stack Overflow**: Tag questions with `docker`, `podman`, `containers`
- **Reddit**: r/docker, r/podman

### Professional Support

- **Docker**: Docker Pro/Team/Business subscriptions
- **Podman**: Red Hat Enterprise Linux subscriptions
- **Cloud Providers**: AWS ECS, Google GKE, Azure AKS support

### Reporting Issues

When asking for help, include:

1. **Environment**: OS, Docker/Podman version
2. **Command**: Exact command that failed
3. **Error**: Complete error message
4. **Logs**: Container logs (`docker logs container-name`)
5. **Context**: What you were trying to achieve

**Template:**

```
Environment: macOS 13.0, Docker Desktop 4.15.0
Command: docker run -p 8080:8080 myapp
Error: bind: address already in use
Logs: [paste container logs]
Goal: Run Spring Boot app on port 8080
```

---

Remember: Most issues have been encountered by others before. Don't hesitate to search for existing solutions before starting from scratch! 🚀

# Critical Docker Topics - Deep Dive Plans

## 🔒 Security: Non-Root by Default

### The Golden Rule

**NEVER run containers as root unless absolutely necessary**

### Implementation Strategy

#### Module 2 (First Container):

```dockerfile
# BAD - Default root user
FROM python:3.12-slim
COPY app.py .
CMD ["python", "app.py"]

# GOOD - Non-root user
FROM python:3.12-slim
RUN useradd -m -u 1000 appuser
USER appuser
COPY --chown=appuser:appuser app.py .
CMD ["python", "app.py"]
```

#### When Root IS Needed (Module 6):

1. **Installing packages during build** (but switch to non-root after)

```dockerfile
FROM node:18-alpine
# Need root for package installation
RUN apk add --no-cache dumb-init
# Switch to non-root for runtime
USER node
```

2. **Binding to privileged ports (<1024)**

   - Solution 1: Use higher ports (8080 instead of 80)
   - Solution 2: Use capabilities

   ```dockerfile
   RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/node
   ```

3. **Accessing host resources**
   - Use proper volume permissions
   - Consider user namespace remapping

## 💾 Volumes: Data That Survives

### Module 4: Complete Volume Coverage

#### Types of Storage:

1. **Bind Mounts** (host directory)

   ```yaml
   volumes:
     - ./data:/app/data # Development
   ```

2. **Named Volumes** (Docker managed)

   ```yaml
   volumes:
     - postgres_data:/var/lib/postgresql/data # Production
   ```

3. **Anonymous Volumes** (temporary)
   ```dockerfile
   VOLUME /tmp/cache  # Cleared on container removal
   ```

#### Volume Lifecycle Management:

```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect postgres_data

# Remove unused volumes (orphan cleanup!)
docker volume prune

# Remove specific volume
docker volume rm postgres_data
```

#### Orphan Container Problem:

```yaml
# Problem: Changing service names creates orphans
version: "3.8"
services:
  # Was 'web', now 'webapp' - old container becomes orphan
  webapp:
    image: myapp
```

**Solutions**:

```bash
# Remove orphan containers for specific project
docker-compose down --remove-orphans

# Clean everything (careful!)
docker system prune -a --volumes

# Better: Use consistent project names
docker-compose -p myproject up
```

## 🐘 Podman: The Daemonless Alternative

### Module 11: Beyond Docker

#### Key Differences:

```bash
# Docker (client-server architecture)
docker run nginx  # Talks to Docker daemon

# Podman (daemonless, fork-exec model)
podman run nginx  # Direct execution, no daemon
```

#### Advantages of Podman:

1. **No root daemon** - Better security
2. **Systemd integration** - Generate service files
3. **Pod support** - K8s-like pod concept
4. **Docker compatible** - Same CLI commands

#### Migration Example:

```bash
# Docker
alias docker=podman

# Most commands work identically
podman build -t myapp .
podman run -p 8080:8080 myapp
podman-compose up  # With podman-compose installed
```

#### When to Use What:

- **Docker**: Full ecosystem, GUI tools, widespread adoption
- **Podman**: Security-focused, systemd environments, rootless by default
- **Both**: Can coexist, similar workflow

## 🚨 Real-World Problems & Solutions

### 1. Orphan Containers (Your Current Issue!)

```bash
# Identify orphans
docker ps -a --filter "status=exited"

# Nuclear option (removes ALL stopped containers)
docker container prune

# Better: Label your containers
docker run --label project=monitoring nginx
docker container prune --filter "label!=project=monitoring"
```

### 2. Volume Permission Issues

```dockerfile
# Problem: Volume owned by root
VOLUME /data

# Solution: Pre-create with correct ownership
RUN mkdir /data && chown appuser:appuser /data
USER appuser
VOLUME /data
```

### 3. Secret Management

```yaml
# BAD: Secrets in environment
environment:
  - DB_PASSWORD=mysecret

# GOOD: Use secrets
secrets:
  - db_password
environment:
  - DB_PASSWORD_FILE=/run/secrets/db_password
```

## 📚 Teaching Approach

### Progressive Security Hardening:

1. **Module 2**: Introduce USER instruction
2. **Module 4**: Volume permissions with non-root
3. **Module 6**: Full security deep-dive
4. **Module 7**: Read-only containers, minimal images
5. **Module 11**: Rootless alternatives (Podman)

### Practical Exercises:

1. **Break Things**: Run as root, show exploit
2. **Fix Things**: Convert to non-root, test again
3. **Real Scenarios**: Database containers, web servers
4. **Clean Up**: Orphan hunting exercise

### Common Gotchas to Address:

- npm install needs root? → Use multi-stage builds
- Can't write to volume? → Check ownership
- Port 80 not working? → Use 8080 or capabilities
- Orphan containers? → Consistent naming, cleanup scripts

## 🔧 Tooling Recommendations

### For Development:

```bash
# Cleanup script (add to each project)
#!/bin/bash
docker-compose down --remove-orphans
docker volume prune -f
docker network prune -f
```

### For Monitoring:

```bash
# Watch for orphans
docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}"

# Disk usage check
docker system df
```

### For Security:

```bash
# Check for root containers
docker ps --format "table {{.Names}}\t{{.User}}" | grep -E "^.*\s+root$|^.*\s+$"

# Scan for vulnerabilities
docker scout cves myimage
```

This ensures students learn Docker the RIGHT way from the start, avoiding the painful lessons you're experiencing with orphan containers!

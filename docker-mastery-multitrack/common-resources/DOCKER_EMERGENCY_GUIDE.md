# Docker Emergency Troubleshooting Guide 🆘

> **When Docker goes wrong, this guide gets you back on track fast!**

## 🚨 Container Won't Start - Exit Codes

### Most Common Exit Codes

| Exit Code | Meaning                               | Quick Fix                              |
| --------- | ------------------------------------- | -------------------------------------- |
| **125**   | Docker daemon error / Invalid command | Check Dockerfile syntax                |
| **126**   | Container command not executable      | Check file permissions, add `chmod +x` |
| **127**   | Container command not found           | Verify command exists in PATH          |
| **137**   | Container killed (OOM)                | Increase memory limit                  |
| **143**   | Container terminated (SIGTERM)        | Normal graceful shutdown               |
| **1**     | General application error             | Check application logs                 |

### Exit Code Diagnosis

```bash
# Check exit code
docker ps -a
# Look at "STATUS" column for exit codes

# Get detailed container info
docker inspect container_name | grep -A 5 "State"

# Check if OOM killed
docker inspect container_name | grep "OOMKilled"
```

## 🔍 Debug Container Startup Issues

### Step-by-Step Debugging

```bash
# 1. Check if image exists
docker images | grep your-image

# 2. Try running interactively
docker run -it your-image /bin/sh

# 3. Check what's actually in the image
docker run --rm your-image ls -la /

# 4. Verify entry point/command
docker inspect your-image | grep -A 5 "Entrypoint\|Cmd"

# 5. Check resource limits
docker stats container_name
```

### "Command Not Found" Fixes

```bash
# Debug missing commands
docker run --rm alpine which python
# If not found, install it:

# Check what's actually available
docker run --rm your-image find /usr/bin -name "*python*"

# Common fixes:
# Python: Use python3 instead of python
# Java: Use java -jar instead of jar
# Node: Make sure node is in PATH
```

## 🌐 Network Connectivity Issues

### "Can't Connect to Service" Flowchart

```bash
# 1. Are containers on same network?
docker network ls
docker inspect network_name

# 2. Can container resolve DNS?
docker exec container1 nslookup container2
docker exec container1 ping container2

# 3. Is the port actually open?
docker exec container1 nc -zv container2 5432

# 4. Is service actually listening?
docker exec container2 netstat -tlnp

# 5. Check compose networking
docker-compose exec service1 ping service2
```

### Common Network Fixes

```yaml
# Fix 1: Ensure containers are on same network
services:
  web:
    networks:
      - app-network
  db:
    networks:
      - app-network

networks:
  app-network:

# Fix 2: Use service names, not localhost
# BAD:
DATABASE_URL=postgresql://localhost:5432/db

# GOOD:
DATABASE_URL=postgresql://postgres:5432/db
```

## 💾 Volume & Permission Issues

**📖 See also: [Complete Volumes & Permissions Guide](./VOLUMES_AND_PERMISSIONS_GUIDE.md)**

### "Permission Denied" Solutions

```bash
# Check current permissions
docker exec container ls -la /data

# Check what user container runs as
docker exec container id

# Quick fixes:
# 1. Change ownership during build
COPY --chown=user:group file /destination

# 2. Fix existing volume
docker exec --user root container chown -R 1000:1000 /data

# 3. Use named volumes instead of bind mounts
# BAD (permissions issues):
volumes:
  - ./data:/app/data

# GOOD (Docker manages permissions):
volumes:
  - postgres_data:/var/lib/postgresql/data
```

### Volume Debugging Commands

```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect volume_name

# See what's actually in a volume
docker run --rm -v volume_name:/data alpine ls -la /data

# Clean up orphaned volumes
docker volume prune

# Emergency: Copy data out of container
docker cp container_name:/data ./backup/
```

## 🏗️ Build Issues

### Build Fails - Common Causes

```bash
# 1. Context too large
# Solution: Use .dockerignore
echo "node_modules" >> .dockerignore
echo "*.log" >> .dockerignore
echo ".git" >> .dockerignore

# 2. Cache issues
# Solution: Build with --no-cache
docker build --no-cache -t myapp .

# 3. Platform issues (M1 Macs)
# Solution: Specify platform
docker build --platform=linux/amd64 -t myapp .

# 4. Secrets in build
# Check for leaked secrets:
docker history myapp --no-trunc
```

### Build Performance Issues

```bash
# Slow builds? Check context size
du -sh .
# If > 100MB, improve .dockerignore

# Layer caching not working?
# Order Dockerfile from least to most changing:
# 1. System packages
# 2. Application dependencies
# 3. Application code

# Use BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker build -t myapp .
```

## 🔒 Security Issues

### "Container Running as Root"

```bash
# Check current user
docker exec container id

# Fix: Add non-root user to Dockerfile
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser
USER appuser
```

### "Secrets Exposed"

```bash
# Check for secrets in environment
docker exec container env | grep -i secret

# Check for secrets in image history
docker history your-image --no-trunc | grep -i secret

# Fix: Use secrets properly
# BAD:
ENV SECRET_KEY=abc123

# GOOD:
# Mount secret file and read it in app
```

## 🚑 Emergency Commands

### Nuclear Options (When All Else Fails)

```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all stopped containers
docker container prune -f

# Remove all unused images
docker image prune -a -f

# Remove all unused volumes
docker volume prune -f

# Remove all unused networks
docker network prune -f

# Nuclear option: Clean everything
docker system prune -a --volumes -f

# Free up space
docker system df
docker builder prune
```

### Quick Health Checks

```bash
# Docker daemon healthy?
docker version

# System resources ok?
docker system df
docker system events --since 1h

# Any failing containers?
docker ps -a --filter "status=exited"

# Recent container logs
docker logs --since 10m container_name
```

## 🔧 Performance Issues

### "Container is Slow"

```bash
# Check resource usage
docker stats

# Is container being throttled?
docker exec container cat /sys/fs/cgroup/memory/memory.stat

# Check for memory pressure
docker exec container dmesg | grep -i "killed process"

# Increase limits
docker run -m 1g --cpus="2.0" your-image
```

### "Build is Slow"

```bash
# Profile build time
time docker build -t myapp .

# Use BuildKit progress
docker build --progress=plain -t myapp .

# Check context size
du -sh .

# Optimize layer caching
# Move frequently changing files to bottom of Dockerfile
```

## 📋 Common Error Messages & Fixes

### Docker Daemon Issues

```
ERROR: Cannot connect to the Docker daemon
→ Fix: Start Docker Desktop / systemctl start docker

ERROR: permission denied while trying to connect
→ Fix: sudo usermod -aG docker $USER && newgrp docker

ERROR: docker: command not found
→ Fix: Install Docker / check PATH
```

### Image Issues

```
ERROR: no space left on device
→ Fix: docker system prune -a --volumes

ERROR: image not found
→ Fix: docker pull image:tag / check image name

ERROR: manifest unknown
→ Fix: Check tag exists / docker pull without tag for latest
```

### Compose Issues

```
ERROR: Version in "docker-compose.yml" is unsupported
→ Fix: Remove version line (Docker Compose V2)

ERROR: network not found
→ Fix: docker-compose down && docker-compose up

ERROR: orphan containers
→ Fix: docker-compose down --remove-orphans
```

## 🎯 Pro Tips

### Debugging Mindset

1. **Start Simple**: Can you run the image with `docker run -it image /bin/sh`?
2. **Check Logs**: Always check `docker logs container_name`
3. **Isolate**: Test each component separately
4. **Compare**: What's different between working and broken setups?
5. **Document**: Write down what fixed it for next time

### Essential Debug Commands

```bash
# The Big 5 Debug Commands
docker ps -a              # What's running/stopped?
docker logs container      # What did it say?
docker inspect container   # What's its config?
docker exec -it container /bin/sh  # Get inside
docker stats              # Resource usage

# Network debugging
docker network ls
docker exec container nslookup service_name
docker exec container nc -zv host port

# Volume debugging
docker volume ls
docker exec container ls -la /mount/point
```

---

## 🆘 **Still Stuck?**

If this guide doesn't solve your issue:

1. **Check Docker logs**: `journalctl -u docker.service`
2. **Restart Docker**: `systemctl restart docker`
3. **Check disk space**: `df -h`
4. **Update Docker**: Use latest stable version
5. **Ask for help**: Include output of `docker version` and `docker info`

**Remember**: Most Docker issues are configuration, not bugs. Check syntax, paths, and permissions first!

---

**Keep this guide handy - you'll need it!** 🚀

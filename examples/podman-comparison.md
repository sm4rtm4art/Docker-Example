# Docker vs Podman - Module 11 Reference

## Quick Comparison

| Feature                  | Docker                   | Podman                           |
| ------------------------ | ------------------------ | -------------------------------- |
| Architecture             | Client-Server (daemon)   | Daemonless (fork-exec)           |
| Root requirement         | Daemon runs as root      | Fully rootless possible          |
| Systemd integration      | Limited                  | Native (generate .service files) |
| Kubernetes compatibility | Via Docker Desktop       | Native pod concept               |
| Docker compatibility     | Native                   | ~99% compatible                  |
| Resource usage           | Higher (daemon overhead) | Lower (no daemon)                |

## Installation

```bash
# Docker (requires daemon)
sudo apt install docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

# Podman (no daemon needed)
sudo apt install podman
# That's it! No daemon to start
```

## Basic Usage - Nearly Identical!

```bash
# Docker
docker run -d -p 8080:80 nginx
docker ps
docker logs <container>
docker exec -it <container> sh

# Podman (exact same commands!)
podman run -d -p 8080:80 nginx
podman ps
podman logs <container>
podman exec -it <container> sh
```

## Rootless Containers (Podman's Strength)

```bash
# Podman - rootless by default
podman run -d -p 8080:80 nginx  # No sudo needed!

# Docker - requires extra setup
# Install rootless mode (complex)
curl -fsSL https://get.docker.com/rootless | sh
```

## Systemd Integration (Podman Exclusive)

```bash
# Generate systemd service from running container
podman generate systemd --name myapp > myapp.service

# Install and enable service
sudo cp myapp.service /etc/systemd/system/
sudo systemctl enable --now myapp.service

# Docker alternative (manual)
# Must write service file manually
```

## Pod Support (Kubernetes-like)

```bash
# Podman - native pod support
podman pod create --name mypod -p 8080:80
podman run --pod mypod nginx
podman run --pod mypod redis

# Docker - use docker-compose instead
```

## Building Images

```bash
# Both use the same Dockerfile format!
# Docker
docker build -t myapp .

# Podman
podman build -t myapp .
# OR use buildah (Podman's friend)
buildah bud -t myapp .
```

## Compose Support

```bash
# Docker
docker-compose up

# Podman (with podman-compose)
pip install podman-compose
podman-compose up

# Podman native (using systemd)
podman generate systemd --files --name myapp
```

## Key Differences in Practice

### 1. Volume Permissions (Better in Podman)

```bash
# Podman - automatic UID mapping
podman run -v ./data:/data alpine touch /data/test
ls -la ./data/test  # Owned by your user!

# Docker - often creates as root
docker run -v ./data:/data alpine touch /data/test
ls -la ./data/test  # Owned by root (problem!)
```

### 2. Network Management

```bash
# Docker - complex network daemon
docker network create mynet

# Podman - simpler, uses CNI
podman network create mynet
```

### 3. Registry Interaction

```bash
# Docker - single registry config
docker login registry.example.com

# Podman - multiple registries
podman login registry.example.com
# Searches multiple registries by default
```

## Migration Script Example

```bash
#!/bin/bash
# migrate-to-podman.sh

# 1. Export Docker images
for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
    echo "Exporting $image..."
    docker save $image | podman load
done

# 2. Recreate networks
for net in $(docker network ls --format "{{.Name}}" | grep -v bridge); do
    podman network create $net
done

# 3. Migrate volumes
for vol in $(docker volume ls -q); do
    # Create volume in Podman
    podman volume create $vol
    # Copy data (requires manual work)
done

# 4. Update scripts
find . -name "*.sh" -exec sed -i 's/docker/podman/g' {} \;
```

## When to Choose What?

### Choose Docker when:

- Need Docker Desktop GUI
- Using Docker Swarm
- Require specific Docker-only tools
- Team already knows Docker
- Need maximum compatibility

### Choose Podman when:

- Security is paramount
- Want rootless containers
- Need systemd integration
- Working in enterprise Linux
- Want Kubernetes-like features

## Practical Exercise: Run Both!

```bash
# They can coexist!
# Run app in Docker
docker run -d -p 8080:80 --name docker-nginx nginx

# Run same app in Podman
podman run -d -p 8081:80 --name podman-nginx nginx

# Compare
curl localhost:8080  # Docker
curl localhost:8081  # Podman

# Check processes
ps aux | grep nginx
# Notice: Docker nginx runs under dockerd
# Podman nginx runs directly
```

## Common Gotchas

1. **Docker Compose files**: Work with podman-compose but may need tweaks
2. **Privileged operations**: Podman more restrictive (good for security)
3. **Image names**: Podman searches multiple registries
4. **Systemd in containers**: Works better with Podman

## The Future?

- Docker: Focusing on developer experience, GUI tools
- Podman: Focusing on security, Kubernetes alignment
- Both: Committed to OCI standards

**Bottom line**: Learn Docker first (market standard), then try Podman for better security!

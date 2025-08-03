# Docker & Podman Cheat Sheet 🚀

Quick reference for the most commonly used commands during your Java Docker journey.

## 🏗️ Image Management

```bash
# Build image
docker build -t myapp .
podman build -t myapp .

# Build with specific Dockerfile
docker build -f Dockerfile.alpine -t myapp:alpine .
podman build -f Dockerfile.alpine -t myapp:alpine .

# Build with build args
docker build --build-arg VERSION=1.0 -t myapp .
podman build --build-arg VERSION=1.0 -t myapp .

# List images
docker images
podman images

# Remove image
docker rmi myapp
podman rmi myapp

# Remove unused images
docker image prune
podman image prune

# Tag image
docker tag myapp:latest myregistry/myapp:v1.0
podman tag myapp:latest myregistry/myapp:v1.0

# Push to registry
docker push myregistry/myapp:v1.0
podman push myregistry/myapp:v1.0

# Pull from registry
docker pull nginx:alpine
podman pull nginx:alpine

# Image history (layers)
docker history myapp
podman history myapp

# Inspect image
docker inspect myapp
podman inspect myapp
```

## 🚀 Container Management

```bash
# Run container
docker run -d -p 8080:8080 --name myapp-container myapp
podman run -d -p 8080:8080 --name myapp-container myapp

# Run interactively
docker run -it --rm ubuntu /bin/bash
podman run -it --rm ubuntu /bin/bash

# Run with environment variables
docker run -e SPRING_PROFILES_ACTIVE=dev -p 8080:8080 myapp
podman run -e SPRING_PROFILES_ACTIVE=dev -p 8080:8080 myapp

# Run with volume mount
docker run -v /host/data:/app/data -p 8080:8080 myapp
podman run -v /host/data:/app/data -p 8080:8080 myapp

# List running containers
docker ps
podman ps

# List all containers (including stopped)
docker ps -a
podman ps -a

# Stop container
docker stop myapp-container
podman stop myapp-container

# Start stopped container
docker start myapp-container
podman start myapp-container

# Restart container
docker restart myapp-container
podman restart myapp-container

# Remove container
docker rm myapp-container
podman rm myapp-container

# Remove running container (force)
docker rm -f myapp-container
podman rm -f myapp-container

# Remove all stopped containers
docker container prune
podman container prune
```

## 🔍 Debugging & Monitoring

```bash
# View container logs
docker logs myapp-container
podman logs myapp-container

# Follow logs (tail -f style)
docker logs -f myapp-container
podman logs -f myapp-container

# Last 50 lines of logs
docker logs --tail 50 myapp-container
podman logs --tail 50 myapp-container

# Logs with timestamps
docker logs -t myapp-container
podman logs -t myapp-container

# Execute command in running container
docker exec -it myapp-container /bin/bash
podman exec -it myapp-container /bin/bash

# Execute as root user
docker exec -it --user root myapp-container /bin/bash
podman exec -it --user root myapp-container /bin/bash

# Copy files to/from container
docker cp file.txt myapp-container:/app/
docker cp myapp-container:/app/logs ./local-logs
podman cp file.txt myapp-container:/app/
podman cp myapp-container:/app/logs ./local-logs

# Container resource usage
docker stats
podman stats

# Container resource usage (one-time)
docker stats --no-stream
podman stats --no-stream

# Inspect container details
docker inspect myapp-container
podman inspect myapp-container

# Container processes
docker top myapp-container
podman top myapp-container

# Port mapping info
docker port myapp-container
podman port myapp-container
```

## 🌐 Network Management

```bash
# List networks
docker network ls
podman network ls

# Create network
docker network create mynetwork
podman network create mynetwork

# Run container in specific network
docker run -d --network mynetwork --name app1 myapp
podman run -d --network mynetwork --name app1 myapp

# Connect container to network
docker network connect mynetwork myapp-container
podman network connect mynetwork myapp-container

# Inspect network
docker network inspect mynetwork
podman network inspect mynetwork

# Remove network
docker network rm mynetwork
podman network rm mynetwork
```

## 💾 Volume Management

```bash
# List volumes
docker volume ls
podman volume ls

# Create volume
docker volume create myvolume
podman volume create myvolume

# Use named volume
docker run -v myvolume:/app/data myapp
podman run -v myvolume:/app/data myapp

# Inspect volume
docker volume inspect myvolume
podman volume inspect myvolume

# Remove volume
docker volume rm myvolume
podman volume rm myvolume

# Remove unused volumes
docker volume prune
podman volume prune
```

## 🧹 System Cleanup

```bash
# Remove all unused resources
docker system prune
podman system prune

# Remove everything including volumes
docker system prune --volumes
podman system prune --volumes

# Remove all stopped containers
docker container prune
podman container prune

# Remove all unused images
docker image prune
podman image prune

# Remove all unused networks
docker network prune
podman network prune

# Remove all unused volumes
docker volume prune
podman volume prune

# Disk usage
docker system df
podman system df
```

## 🔧 Java-Specific Commands

```bash
# Build Spring Boot app
mvn clean package
docker build -t spring-app .
podman build -t spring-app .

# Run with debug port
docker run -d -p 8080:8080 -p 5005:5005 \
  -e JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
  spring-app
podman run -d -p 8080:8080 -p 5005:5005 \
  -e JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
  spring-app

# Run with JVM memory settings
docker run -d -p 8080:8080 \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  spring-app
podman run -d -p 8080:8080 \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  spring-app

# Run with Spring profile
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=production \
  spring-app
podman run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=production \
  spring-app

# Check Spring Boot health
curl http://localhost:8080/actuator/health

# View Spring Boot metrics
curl http://localhost:8080/actuator/metrics
```

## 🐛 Quick Debugging

```bash
# Can't connect to app?
docker ps                           # Is container running?
docker logs myapp-container         # Check application logs
docker port myapp-container         # Check port mappings
curl http://localhost:8080/actuator/health  # Test health endpoint

# Container won't start?
docker logs myapp-container         # Check startup errors
docker inspect myapp-container      # Check configuration
docker exec -it myapp-container /bin/bash  # Debug inside container

# Out of space?
docker system df                    # Check disk usage
docker system prune                 # Clean up unused resources

# Networking issues?
docker network ls                   # List networks
docker inspect bridge              # Check default network
docker run --rm -it nicolaka/netshoot  # Network debugging tools
```

## 🚀 Docker Compose Quick Commands

```bash
# Start services
docker-compose up -d
podman-compose up -d

# View running services
docker-compose ps
podman-compose ps

# View logs
docker-compose logs -f
podman-compose logs -f

# Stop services
docker-compose down
podman-compose down

# Rebuild and restart
docker-compose up --build -d
podman-compose up --build -d

# Scale service
docker-compose up --scale web=3
podman-compose up --scale web=3
```

## 📊 Monitoring Commands

```bash
# Real-time container stats
docker stats
podman stats

# Container processes
docker top myapp-container
podman top myapp-container

# System information
docker info
podman info

# Version information
docker version
podman version

# Check container health
docker inspect myapp-container | grep -i health
podman inspect myapp-container | grep -i health
```

## 🔐 Security Commands

```bash
# Scan image for vulnerabilities (Docker Desktop)
docker scan myapp

# Run container as non-root
docker run --user 1000:1000 myapp
podman run --user 1000:1000 myapp

# Read-only root filesystem
docker run --read-only myapp
podman run --read-only myapp

# Limit resources
docker run --memory=512m --cpus=1.0 myapp
podman run --memory=512m --cpus=1.0 myapp

# Drop capabilities
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp
podman run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp
```

## 🎯 Podman-Specific Commands

```bash
# Generate Kubernetes YAML
podman generate kube myapp-container > myapp.yaml

# Create pod
podman pod create --name mypod -p 8080:8080

# Add container to pod
podman run -d --pod mypod --name app myapp

# List pods
podman pod ls

# Generate systemd service
podman generate systemd --name myapp --files

# Rootless info
podman unshare cat /proc/self/uid_map
```

## 💡 Pro Tips

```bash
# Set aliases for convenience
alias d=docker
alias dc=docker-compose
alias p=podman
alias pc=podman-compose

# One-liner to stop all containers
docker stop $(docker ps -q)
podman stop $(podman ps -q)

# One-liner to remove all containers
docker rm $(docker ps -aq)
podman rm $(podman ps -aq)

# One-liner to remove all images
docker rmi $(docker images -q)
podman rmi $(podman images -q)

# Format output
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Use jq for JSON inspection
docker inspect myapp | jq '.[]'
podman inspect myapp | jq '.[]'
```

## 🆘 Emergency Commands

```bash
# Kill all containers
docker kill $(docker ps -q)
podman kill $(podman ps -q)

# Nuclear option - remove everything
docker system prune -af --volumes
podman system prune -af --volumes

# Reset Docker Desktop (GUI: Troubleshoot > Reset to factory defaults)
# Reset Podman
podman system reset
```

Save this cheat sheet and keep it handy during your Docker/Podman journey! 🚀

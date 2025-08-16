# Module 01: Docker Fundamentals 🐳

> **Master the core concepts that power every container technology**

Welcome to the heart of container technology! This module teaches you Docker fundamentals that apply regardless of which programming language you use. By the end, you'll understand what containers really are and why they've revolutionized software deployment.

## 🎯 Learning Objectives

By completing this module, you will:

- ✅ Understand what containers are and why they matter
- ✅ Distinguish between containers, VMs, and bare metal
- ✅ Navigate the Docker ecosystem confidently
- ✅ Execute essential Docker CLI commands
- ✅ Understand images, containers, and registries
- ✅ Grasp the container lifecycle
- ✅ Debug common container issues

## ⏱️ Time Investment

- **Reading & Understanding**: 25 minutes
- **Hands-on Exercises**: 25 minutes
- **Troubleshooting Practice**: 10 minutes
- **Total**: ~1 hour

## 📚 What Are Containers?

### The Evolution Story

```
Bare Metal → Virtual Machines → Containers → ?
```

#### Bare Metal (1990s)

```
┌─────────────────────────────────────┐
│             Application             │
├─────────────────────────────────────┤
│            Runtime/OS               │
├─────────────────────────────────────┤
│            Hardware                 │
└─────────────────────────────────────┘
```

- **Pros**: Maximum performance
- **Cons**: No isolation, resource waste, "works on my machine"

#### Virtual Machines (2000s)

```
┌──────────────┬──────────────┬──────────────┐
│     App1     │     App2     │     App3     │
├──────────────┼──────────────┼──────────────┤
│   Runtime    │   Runtime    │   Runtime    │
├──────────────┼──────────────┼──────────────┤
│  Guest OS    │  Guest OS    │  Guest OS    │
├──────────────┴──────────────┴──────────────┤
│           Hypervisor                       │
├─────────────────────────────────────────────┤
│             Host OS                        │
├─────────────────────────────────────────────┤
│            Hardware                        │
└─────────────────────────────────────────────┘
```

- **Pros**: Strong isolation, multiple OS support
- **Cons**: Resource overhead, slow startup, large size

#### Containers (2010s+)

```
┌──────────────┬──────────────┬──────────────┐
│     App1     │     App2     │     App3     │
├──────────────┼──────────────┼──────────────┤
│   Runtime    │   Runtime    │   Runtime    │
├──────────────┴──────────────┴──────────────┤
│           Container Engine                 │
├─────────────────────────────────────────────┤
│             Host OS                        │
├─────────────────────────────────────────────┤
│            Hardware                        │
└─────────────────────────────────────────────┘
```

- **Pros**: Fast startup, small size, good isolation
- **Cons**: Shared kernel, less isolation than VMs

### Container vs VM: The Real Difference

| Aspect           | Virtual Machines   | Containers              |
| ---------------- | ------------------ | ----------------------- |
| **OS Overhead**  | Full OS per VM     | Shared host OS          |
| **Startup Time** | 30-60 seconds      | 1-2 seconds             |
| **Memory Usage** | GB per instance    | MB per instance         |
| **Isolation**    | Hardware-level     | Process-level           |
| **Use Case**     | Different OS needs | Same OS, different apps |

## 🏗️ Docker Architecture

### The Big Picture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Docker CLI    │───▶│  Docker Daemon  │───▶│   Containers    │
│  (your commands)│    │  (dockerd)      │    │  (running apps) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │     Images      │
                       │ (blueprints)    │
                       └─────────────────┘
```

### Key Components

#### 1. **Docker Client** (CLI)

The command-line interface you interact with:

```bash
docker run nginx    # Client command
docker ps          # Client command
docker build .     # Client command
```

#### 2. **Docker Daemon** (dockerd)

The background service that does the actual work:

- Manages images, containers, networks, volumes
- Listens for Docker API requests
- Talks to the Linux kernel

#### 3. **Docker Images**

Read-only templates used to create containers:

- Like a "snapshot" or "blueprint"
- Layered filesystem
- Immutable (never change)

#### 4. **Docker Containers**

Running instances of images:

- Writable layer on top of image
- Isolated process space
- Temporary by default

#### 5. **Docker Registry**

Storage and distribution of images:

- **Docker Hub**: Public registry
- **Private registries**: Your own storage
- **Official images**: Verified, maintained

## 🛠️ Essential Docker Commands

### Container Lifecycle

```bash
# Pull an image from registry
docker pull nginx:latest

# Run a container
docker run nginx

# Run container in background (-d = detached)
docker run -d nginx

# Run with port mapping
docker run -d -p 8080:80 nginx

# Run with name
docker run -d -p 8080:80 --name my-web nginx

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop my-web

# Start a stopped container
docker start my-web

# Remove a container
docker rm my-web

# Remove a running container (force)
docker rm -f my-web
```

### Image Management

```bash
# List local images
docker images

# Remove an image
docker rmi nginx:latest

# Remove unused images
docker image prune

# Build image from Dockerfile
docker build -t my-app .

# Tag an image
docker tag my-app:latest my-app:v1.0
```

### Information & Debugging

```bash
# Show container logs
docker logs my-web

# Follow logs in real-time
docker logs -f my-web

# Execute command in running container
docker exec -it my-web bash

# Show container details
docker inspect my-web

# Show resource usage
docker stats

# Show system information
docker info

# Show disk usage
docker system df
```

## 🏃‍♂️ Hands-On Exercise 1: Your First Container

Let's run your first container! Open your terminal and follow along:

### Step 1: Hello World

```bash
# Pull and run the hello-world image
docker run hello-world
```

**What happened?**

1. Docker checked for `hello-world` image locally
2. Didn't find it, so pulled from Docker Hub
3. Created a container from the image
4. Ran the container (printed message)
5. Container exited

### Step 2: Interactive Container

```bash
# Run an interactive Ubuntu container
docker run -it ubuntu:20.04 bash

# You're now inside the container! Try:
ls /
ps aux
cat /etc/os-release

# Exit the container
exit
```

### Step 3: Web Server

```bash
# Run nginx web server
docker run -d -p 8080:80 --name web-server nginx

# Check if it's running
docker ps

# Test the web server
curl http://localhost:8080
# Or open browser to http://localhost:8080

# Check logs
docker logs web-server

# Clean up
docker stop web-server
docker rm web-server
```

## 🏃‍♂️ Hands-On Exercise 2: Understanding Images

### Explore Image Layers

```bash
# Pull a small image
docker pull alpine:latest

# Inspect the image
docker inspect alpine:latest

# Look at image history (layers)
docker history alpine:latest

# Run Alpine and explore
docker run -it alpine sh

# Inside container, try:
cat /etc/os-release
ls /bin
apk --help  # Alpine package manager

exit
```

### Image Sizes Matter

```bash
# Compare image sizes
docker pull ubuntu:20.04
docker pull alpine:latest
docker pull scratch

# See the size differences
docker images

# Notice:
# - ubuntu: ~70MB (full Linux distro)
# - alpine: ~5MB (minimal Linux)
# - scratch: 0MB (empty base)
```

## 🏃‍♂️ Hands-On Exercise 3: Container Persistence

### Understanding Ephemeral Nature

```bash
# Create a file in a container
docker run -it alpine sh
echo "Hello from container" > /tmp/myfile.txt
cat /tmp/myfile.txt
exit

# Start the same container again
docker run -it alpine sh
cat /tmp/myfile.txt  # File is gone!
exit
```

**Why?** Each `docker run` creates a NEW container from the image.

### Container vs Image Persistence

```bash
# Create and name a container
docker run -it --name persistent alpine sh
echo "This will persist" > /tmp/data.txt
exit

# Start the SAME container again
docker start -i persistent
cat /tmp/data.txt  # File is still there!
exit

# Clean up
docker rm persistent
```

## 🔍 Understanding the Container Lifecycle

```
Image → Container → Running → Stopped → Removed
  ↑         ↑         ↑         ↑         ↑
pull    create/run   start    stop      rm
```

### State Transitions

```bash
# Image exists locally
docker images

# Create container (but don't start)
docker create --name lifecycle nginx

# Container exists but not running
docker ps -a

# Start the container
docker start lifecycle

# Container is now running
docker ps

# Stop the container
docker stop lifecycle

# Container exists but stopped
docker ps -a

# Remove the container
docker rm lifecycle

# Container no longer exists
docker ps -a
```

## 🚨 Common Gotchas & Troubleshooting

### 1. Port Already in Use

```bash
# This will fail if something is on port 8080
docker run -p 8080:80 nginx
# Error: port is already allocated

# Solution: Use different port
docker run -p 8081:80 nginx
```

### 2. Container Names Must Be Unique

```bash
# This will fail if 'web' already exists
docker run --name web nginx
# Error: name is already in use

# Solution: Remove old container or use different name
docker rm web
# or
docker run --name web2 nginx
```

### 3. Permission Denied (Linux/macOS)

```bash
# If you get permission denied:
docker ps
# permission denied

# Solution: Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Then logout and login again

# Or use sudo (not recommended for regular use)
sudo docker ps
```

### 4. Image Not Found

```bash
# This might fail
docker run my-custom-app
# Error: Unable to find image

# Check if image exists locally
docker images

# Or pull from specific registry
docker run registry.example.com/my-custom-app
```

## 🎓 Knowledge Check

Test your understanding:

1. **What's the difference between an image and a container?**
   <details>
   <summary>Answer</summary>
   An image is a read-only template/blueprint. A container is a running instance of an image with a writable layer on top.
   </details>

2. **Why do containers start faster than VMs?**
   <details>
   <summary>Answer</summary>
   Containers share the host OS kernel and don't need to boot a full operating system.
   </details>

3. **What happens when you run `docker run hello-world` twice?**
   <details>
   <summary>Answer</summary>
   It creates two separate containers from the same image. Each run creates a new container instance.
   </details>

4. **How do you see logs from a detached container?**
   <details>
   <summary>Answer</summary>
   Use `docker logs <container-name>` or `docker logs -f <container-name>` to follow real-time.
   </details>

5. **What's the difference between `docker stop` and `docker kill`?**
   <details>
   <summary>Answer</summary>
   `docker stop` sends SIGTERM (graceful shutdown). `docker kill` sends SIGKILL (immediate termination).
   </details>

## 🚀 Going Further

### Explore Different Images

```bash
# Try different operating systems
docker run -it centos:7 bash
docker run -it debian:bullseye bash
docker run -it ubuntu:22.04 bash

# Try different applications
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret mysql:8
docker run -d -p 6379:6379 redis:alpine
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=secret postgres:13
```

### Resource Limits

```bash
# Limit memory and CPU
docker run -it --memory=100m --cpus=0.5 ubuntu bash

# Check resource usage
docker stats
```

### Environment Variables

```bash
# Pass environment variables
docker run -e MY_VAR=hello -e DEBUG=true alpine env

# Use environment file
echo "MY_VAR=hello" > .env
echo "DEBUG=true" >> .env
docker run --env-file .env alpine env
```

## 📋 Summary

**You've learned the Docker fundamentals!**

✅ **Containers** are lightweight, portable environments
✅ **Images** are blueprints, **containers** are running instances  
✅ **Docker CLI** is your interface to the Docker daemon
✅ **Container lifecycle** includes create, start, stop, remove
✅ **Containers are ephemeral** by default
✅ **Debugging tools** help you understand what's happening

**Next Step**: Choose your language track in [Module 02: Language Quickstart](../02-language-quickstart/) and start building real applications with containers!

## 📝 Knowledge Check

Before moving to the next module, make sure you can:

1. **Run a container**: `docker run nginx` and access it in your browser
2. **List containers**: Use `docker ps` and explain what each column means
3. **Stop cleanly**: Stop a container with `docker stop` (not `docker kill`)
4. **Manage images**: Pull, list, and remove images confidently
5. **Debug issues**: Check logs with `docker logs` when something breaks

**Quick Self-Test**: Can you run a web server container, access it from your browser, view its logs, and then stop and remove both the container and image? If yes, you're ready for Module 02!

## 🆘 Having Issues?

**Container won't start?** **Permission errors?** **Build taking forever?**

➡️ Check our [**Docker Emergency Guide**](../common-resources/DOCKER_EMERGENCY_GUIDE.md) for instant solutions to common problems.

**Need a clean slate?** Run our [cleanup script](../../scripts/docker-cleanup-v2.sh) to reset your Docker environment.

---

_"Understanding containers at this level will serve you in any technology stack. The concepts you've learned apply to Kubernetes, cloud platforms, and any containerization technology."_

# Docker Detective Challenges 🕵️‍♂️

> **Welcome, Detective!** Your mission: Solve these Docker mysteries using only your investigative skills and command-line tools.

## 🎯 How to Play

1. **Read the Case File** - Understand the symptoms
2. **Gather Evidence** - Use Docker commands to investigate
3. **Form a Theory** - What do you think is wrong?
4. **Test Your Theory** - Try to fix it
5. **Document the Solution** - What was the root cause?

## 🚨 Case #1: The Vanishing Variable

### Case File

```
Detective, we have a problem! Our web application keeps crashing with:
ERROR: Database connection failed - POSTGRES_PASSWORD is empty

But we SET the password in our docker-compose.yml file!
```

### Evidence

```yaml
# docker-compose.yml
services:
  web:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:${POSTGRES_PASSWORD}@db:5432/myapp

  db:
    image: postgres:16
    environment:
      - POSTGRES_PASSWORD=supersecret
```

### Your Investigation Tools

```bash
# Check environment variables
docker-compose exec web env | grep POSTGRES

# Check if variable is being passed
docker-compose config

# Check container configuration
docker inspect container_name | grep -A 10 "Env"
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Environment variable substitution expects a `.env` file or exported variable.

**Solution**:

```bash
# Method 1: Create .env file
echo "POSTGRES_PASSWORD=supersecret" > .env

# Method 2: Export variable
export POSTGRES_PASSWORD=supersecret

# Method 3: Use direct value (for dev only)
DATABASE_URL=postgresql://user:supersecret@db:5432/myapp
```

**Lesson**: Docker Compose variable substitution requires the variable to exist in your shell environment or `.env` file.

</details>

---

## 🚨 Case #2: The Phantom Port

### Case File

```
Detective, our API is running but unreachable!
- Container shows as "healthy" in docker ps
- Application logs show "Server listening on port 8080"
- But curl http://localhost:8080 returns "Connection refused"
```

### Evidence

```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD ["node", "server.js"]
```

```javascript
// server.js
app.listen(8080, "127.0.0.1", () => {
  console.log("Server listening on port 8080");
});
```

### Your Investigation Tools

```bash
# Check port mappings
docker ps

# Check what's actually listening
docker exec container netstat -tlnp

# Test internal connectivity
docker exec container curl localhost:8080
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Application binding to `127.0.0.1` (localhost) instead of `0.0.0.0` (all interfaces).

**Inside a container, 127.0.0.1 only accepts connections from within the container itself!**

**Solution**:

```javascript
// Fix: Bind to all interfaces
app.listen(8080, "0.0.0.0", () => {
  console.log("Server listening on port 8080");
});

// Or just omit the bind address
app.listen(8080, () => {
  console.log("Server listening on port 8080");
});
```

**Lesson**: Always bind to `0.0.0.0` in containers, not `127.0.0.1`.

</details>

---

## 🚨 Case #3: The Memory Thief

### Case File

```
Detective, our containers keep dying mysteriously!
- They run fine for a few minutes
- Then suddenly exit with code 137
- No error messages in application logs
- This started happening after we added image processing
```

### Evidence

```python
# app.py - Image processing service
from PIL import Image
import os

processed_images = []  # Global list - suspicious!

def process_image(image_path):
    img = Image.open(image_path)
    # Process image...
    processed_images.append(img)  # Never cleared!
    return processed_img
```

### Your Investigation Tools

```bash
# Check exit codes
docker ps -a

# Monitor memory usage
docker stats

# Check for OOM killer
docker inspect container | grep OOMKilled

# Check system memory
docker exec container cat /proc/meminfo
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Memory leak! The `processed_images` list keeps growing and never releases memory.

**Evidence**: Exit code 137 = 128 + 9 (SIGKILL from OOM killer)

**Solution**:

```python
# Fix 1: Clear the list
def process_image(image_path):
    img = Image.open(image_path)
    processed_img = process(img)
    img.close()  # Explicitly close
    return processed_img

# Fix 2: Use context manager
def process_image(image_path):
    with Image.open(image_path) as img:
        return process(img)  # Auto-closes
```

**Prevention**:

```yaml
# Set memory limits
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
```

**Lesson**: Exit code 137 usually means OOM (Out of Memory) killed your container.

</details>

---

## 🚨 Case #4: The Identity Crisis

### Case File

```
Detective, our application can't write files!
- Container starts successfully
- Application tries to create /app/uploads/image.jpg
- Gets "Permission denied" error
- But the directory exists in the container!
```

### Evidence

```dockerfile
FROM alpine:3.18
RUN apk add --no-cache python3
RUN mkdir -p /app/uploads
COPY app.py /app/
WORKDIR /app
CMD ["python3", "app.py"]
```

```python
# app.py
import os
upload_dir = "/app/uploads"
filename = os.path.join(upload_dir, "test.txt")
with open(filename, "w") as f:  # Fails here!
    f.write("Hello World")
```

### Your Investigation Tools

```bash
# Check file permissions
docker exec container ls -la /app/

# Check what user is running
docker exec container id

# Check directory ownership
docker exec container ls -la /app/uploads
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Container running as root, but directory owned by root with incorrect permissions.

**Better Root Cause**: Should never run as root in the first place!

**Solution**:

```dockerfile
FROM alpine:3.18
RUN apk add --no-cache python3

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Create directory with correct ownership
RUN mkdir -p /app/uploads && \
    chown -R appuser:appuser /app

COPY --chown=appuser:appuser app.py /app/
WORKDIR /app

# Switch to non-root user
USER appuser:appuser

CMD ["python3", "app.py"]
```

**Lesson**: Always run containers as non-root users and ensure proper file ownership.

</details>

---

## 🚨 Case #5: The Network Ninja

### Case File

```
Detective, our microservices can't talk to each other!
- Frontend can't reach backend API
- Backend can't connect to database
- All containers are running
- Used to work yesterday!
```

### Evidence

```yaml
# docker-compose.yml (modified recently)
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    networks:
      - web-tier

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    networks:
      - api-tier

  database:
    image: postgres:16
    networks:
      - data-tier

networks:
  web-tier:
  api-tier:
  data-tier:
```

### Your Investigation Tools

```bash
# Check network configuration
docker network ls
docker network inspect network_name

# Test connectivity between containers
docker exec frontend ping backend
docker exec backend ping database

# Check DNS resolution
docker exec frontend nslookup backend
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Network isolation! Each service is on a different network, so they can't communicate.

**Evidence**:

- Frontend (web-tier) can't reach Backend (api-tier)
- Backend (api-tier) can't reach Database (data-tier)

**Solution**:

```yaml
# Fix: Put services on shared networks
services:
  frontend:
    networks:
      - web-tier
      - api-tier  # Add this!

  backend:
    networks:
      - api-tier
      - data-tier  # Add this!

  database:
    networks:
      - data-tier

# Or simpler: Use default network
services:
  frontend:
    build: ./frontend
  backend:
    build: ./backend
  database:
    image: postgres:16
# No explicit networks = all on default network
```

**Lesson**: Containers must be on the same network to communicate. Docker Compose creates isolated networks by default.

</details>

---

## 🚨 Case #6: The Slow Builder

### Case File

```
Detective, our Docker builds take FOREVER!
- 15+ minutes for a simple Python app
- Re-downloading packages every time
- Developers are frustrated
- Need this fixed ASAP!
```

### Evidence

```dockerfile
FROM python:3.12
WORKDIR /app
COPY . .                    # Copies everything first!
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

### Your Investigation Tools

```bash
# Check build time layers
time docker build -t slow-app .

# Check what's being copied
docker build --progress=plain -t slow-app .

# Check context size
du -sh .
```

<details>
<summary>🔍 Click for Solution</summary>

**Root Cause**: Poor layer caching! Copying all files before installing dependencies invalidates the cache every time code changes.

**Solution**:

```dockerfile
FROM python:3.12
WORKDIR /app

# Copy dependencies first (changes less frequently)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy code last (changes most frequently)
COPY . .

CMD ["python", "app.py"]
```

**Better Solution with BuildKit**:

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12
WORKDIR /app

COPY requirements.txt .
# Use cache mount for pip
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

COPY . .
CMD ["python", "app.py"]
```

**Also add .dockerignore**:

```
__pycache__/
*.pyc
.git/
node_modules/
*.log
```

**Lesson**: Order Dockerfile instructions from least to most frequently changing for optimal layer caching.

</details>

---

## 🎓 Detective Graduation Test

### Final Challenge: The Production Mystery

```
URGENT: Production system down! Multiple issues detected:
1. Web service returning 500 errors
2. Database showing connection refused
3. Redis cache timing out
4. Monitoring shows one container restarting every 30 seconds

Your mission: Diagnose and fix ALL issues.
The CEO is watching. You have 20 minutes.

Good luck, Detective! 🕵️‍♂️
```

### Tools at Your Disposal

```bash
docker ps -a
docker logs service_name
docker stats
docker network ls
docker volume ls
docker exec container_name command
docker inspect container_name
docker-compose logs
```

<details>
<summary>🔍 Click for Multi-Part Solution</summary>

**Investigation Steps**:

1. **Check what's running**: `docker ps -a`
2. **Check recent logs**: `docker logs --since 5m container_name`
3. **Check resource usage**: `docker stats`
4. **Check networks**: `docker network inspect network_name`

**Likely Issues & Fixes**:

1. **Restarting container** → Check memory limits/OOM
2. **Connection refused** → Network isolation or wrong ports
3. **Cache timeout** → Redis not on same network
4. **500 errors** → Database connection string wrong

**Pro Detective Tip**: Start with the restarting container - it's often the root cause!

</details>

---

## 🏆 Congratulations, Detective!

You've solved the Docker mysteries! These debugging skills will serve you well in production environments.

### Key Detective Skills Learned

1. **Exit Code Analysis** - 137 = OOM, 126 = Permissions, etc.
2. **Network Debugging** - Same network required for communication
3. **Memory Investigation** - Monitor usage, set limits
4. **Permission Forensics** - Non-root users, proper ownership
5. **Build Optimization** - Layer caching, BuildKit features
6. **Environment Variables** - Substitution and scope

### Advanced Detective Training

Ready for more challenges? Try these:

- Debug a Kubernetes pod that won't start
- Investigate a container image with security vulnerabilities
- Solve a multi-service performance bottleneck
- Track down a container with a memory leak

**Remember**: Every Docker problem has a logical explanation. Use your tools, follow the evidence, and you'll solve any mystery! 🔍

---

**Keep your detective badge - you've earned it!** 🏆

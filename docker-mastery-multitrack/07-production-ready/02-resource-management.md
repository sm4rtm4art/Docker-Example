# Part B: Resource Management

> **Duration**: 1 hour  
> **Focus**: Preventing resource exhaustion and container sprawl

## 🎯 Learning Objectives

By the end of this section, you will:

- Set appropriate memory and CPU limits
- Understand the OOM killer and how to avoid it
- Implement log rotation strategies
- Debug resource constraint issues

## 💣 The Problem: Resource Bombs

```bash
# The container that ate production
$ docker stats
CONTAINER   CPU %    MEM USAGE / LIMIT
hungry-app  834.2%   31.4GB / 32GB       # 😱
```

## 📊 Resource Limits in Docker

### 1. Memory Limits

```yaml
# docker-compose.yml
services:
  api:
    image: myapp
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M # Guaranteed minimum
```

```dockerfile
# Or via docker run
docker run -m 512m --memory-reservation 256m myapp
```

### 2. CPU Limits

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '0.5'  # 50% of one CPU
          # or
          cpus: '2.0'  # 2 full CPUs
```

### 3. Understanding OOM Killer

```python
# This will trigger OOM killer
data = []
while True:
    data.append("x" * 1024 * 1024)  # 1MB strings
    print(f"Allocated {len(data)}MB")
```

When you hit the limit:

```
Allocated 510MB
Allocated 511MB
Killed  # Exit code 137 (128 + 9 SIGKILL)
```

## 🔍 Monitoring Resource Usage

### Real-time Monitoring

```bash
# Watch container resources
$ docker stats

# Check specific container
$ docker stats focused_container --no-stream

# See why container was killed
$ docker inspect focused_container | grep -i oom
"OOMKilled": true,
```

### Setting Alerts

```yaml
# Prometheus alert rule
- alert: ContainerHighMemory
  expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
  for: 5m
  annotations:
    summary: "Container {{ $labels.name }} memory > 90%"
```

## 📝 Log Management

### Problem: Logs Filling Disk

```bash
# 50GB of logs!
$ du -h /var/lib/docker/containers/*/\*.log
50G /var/lib/docker/containers/abc123/abc123-json.log
```

### Solution: Log Rotation

```yaml
# docker-compose.yml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Or globally in `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## 🎯 Exercise: Resource Exhaustion Lab

### Step 1: Create a Memory Bomb

```python
# memory-bomb/app.py
import time

print("Starting memory bomb...")
data = []
mb_count = 0

try:
    while True:
        # Allocate 10MB
        data.append("x" * 10 * 1024 * 1024)
        mb_count += 10
        print(f"Allocated {mb_count}MB")
        time.sleep(0.1)
except MemoryError:
    print("Out of memory!")
```

### Step 2: Run with Limits

```bash
# No limit - will eat all memory
$ docker run memory-bomb

# With limit - will be killed
$ docker run -m 100m memory-bomb
Allocated 90MB
Killed

# Check exit code
$ echo $?
137  # 128 + 9 (SIGKILL)
```

### Step 3: Handle Gracefully

```python
# Better approach
import resource
import signal

def check_memory_usage():
    """Check if we're approaching memory limit"""
    usage = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    # Implement graceful degradation
    if usage > MEMORY_THRESHOLD:
        clear_caches()
        gc.collect()
```

## ⚡ Best Practices

### 1. Start Conservative

```yaml
# Start with these limits and adjust based on monitoring
services:
  web:
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
        reservations:
          cpus: "0.25"
          memory: 256M
```

### 2. Java Special Considerations

```dockerfile
# Java needs explicit heap size with container limits
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0"
```

### 3. Node.js Considerations

```dockerfile
# Node needs explicit max-old-space-size
ENV NODE_OPTIONS="--max-old-space-size=384"  # 75% of 512MB
```

## 🚨 Common Pitfalls

1. **No Limits = Production Outage**

   ```yaml
   # BAD: No limits
   services:
     api:
       image: myapp
   ```

2. **Too Low Limits = Constant Restarts**

   ```yaml
   # BAD: Unrealistic limits
   memory: 50M # Most apps need more
   ```

3. **Ignoring Swap**
   ```yaml
   # Better: Disable swap for predictable behavior
   services:
     api:
       deploy:
         resources:
           limits:
             memory: 512M
           swap: 0
   ```

## 🎓 Key Takeaways

1. **Always Set Limits** - Protect your host and other containers
2. **Monitor Actual Usage** - Adjust limits based on reality
3. **Handle OOM Gracefully** - Don't just crash
4. **Rotate Logs** - Prevent disk exhaustion
5. **Test Under Load** - Verify limits are appropriate

## 🚀 Next: Minimal & Secure Images

With resources under control, let's minimize our attack surface...

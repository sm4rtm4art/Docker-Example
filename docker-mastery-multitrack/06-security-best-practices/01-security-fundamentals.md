# Security Fundamentals - Defense in Depth 🛡️

Master container security from the ground up! Learn to implement defense-in-depth strategies that protect your applications in production.

## 🎯 Learning Outcomes

- ✅ Implement non-root containers across all platforms
- ✅ Secure secrets management without environment variables
- ✅ Configure read-only root filesystems
- ✅ Debug common permission and access issues
- ✅ Apply security scanning and vulnerability detection
- ✅ Understand when root access IS necessary

## 🔒 The Security-First Mindset

### Why Container Security Matters

**Every container vulnerability can become a system compromise:**

```bash
# Dangerous: Container running as root
docker run -it --rm alpine
/ # id
uid=0(root) gid=0(root) groups=0(root)
/ # touch /host_file  # If volumes mounted, this affects host!
```

**The security principle**: **Containers should be "guests" not "owners"**

## 🛡️ Security Layer 1: Non-Root Users

### The Golden Rule: Always Non-Root

**Every Dockerfile MUST include:**

```dockerfile
# Ubuntu/Debian Pattern
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser
USER appuser:appuser

# Alpine Pattern
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser
USER appuser:appuser
```

### Platform-Specific Non-Root Implementation

#### Java (Spring Boot)

```dockerfile
FROM openjdk:17-jre-slim

# Create application user
RUN groupadd -r spring && useradd -r -g spring -u 1000 spring

# Create app directory with correct ownership
WORKDIR /app
RUN chown spring:spring /app

# Copy JAR with correct ownership
COPY --chown=spring:spring target/task-api-*.jar app.jar

# Switch to non-root user
USER spring:spring

# Security: Expose non-privileged port
EXPOSE 8080

# Health check as non-root user
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### Python (FastAPI)

```dockerfile
FROM python:3.12-slim

# Create application user
RUN groupadd -r fastapi && useradd -r -g fastapi -u 1000 fastapi

# Install dependencies as root (when needed)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create app directory with correct ownership
WORKDIR /app
RUN chown fastapi:fastapi /app

# Copy application with correct ownership
COPY --chown=fastapi:fastapi . .

# Switch to non-root user
USER fastapi:fastapi

# Security: Non-privileged port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

#### Rust (Actix-web)

```dockerfile
# Multi-stage build for Rust
FROM rust:1.75 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build release binary
RUN cargo build --release

# Runtime stage with minimal base
FROM debian:bookworm-slim

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN groupadd -r actix && useradd -r -g actix -u 1000 actix

# Create app directory
WORKDIR /app
RUN chown actix:actix /app

# Copy binary with correct ownership
COPY --from=builder --chown=actix:actix /usr/src/app/target/release/task-api .

# Switch to non-root user
USER actix:actix

# Security: Non-privileged port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["./task-api"]
```

### Testing Non-Root Implementation

```bash
# Build and test security
docker build -t task-api-secure .

# Verify non-root user
docker run --rm task-api-secure id
# Should show: uid=1000(appuser) gid=1000(appuser)

# Test file system access (should be limited)
docker run --rm task-api-secure touch /test-file
# Should fail with permission denied

# Test application functionality
docker run -d --name security-test -p 8080:8080 task-api-secure
curl http://localhost:8080/health
# Should work normally
```

## 🔐 Security Layer 2: Secrets Management

### The Problem with Environment Variables

```bash
# BAD: Secrets visible everywhere
docker run -e DB_PASSWORD=supersecret myapp
docker inspect myapp  # Shows password in plain text!
docker logs myapp     # May leak password in logs
```

### Docker Secrets (Recommended)

#### Docker Compose with Secrets

```yaml
version: "3.8"

services:
  task-api:
    build: .
    environment:
      - DATABASE_URL_FILE=/run/secrets/db_url
    secrets:
      - db_url
    networks:
      - backend

  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend

secrets:
  db_password:
    file: ./secrets/db_password.txt
  db_url:
    file: ./secrets/db_url.txt

volumes:
  postgres_data:

networks:
  backend:
```

#### Create Secret Files

```bash
# Create secrets directory (outside repository!)
mkdir -p secrets

# Store database password
echo "supersecurepassword123" > secrets/db_password.txt

# Store database URL
echo "postgresql://taskuser:supersecurepassword123@postgres:5432/taskdb" > secrets/db_url.txt

# Secure the files
chmod 600 secrets/*
```

#### Application Code Changes

**Java (Spring Boot)**:

```java
@Configuration
public class DatabaseConfig {

    @Value("${DATABASE_URL_FILE:#{null}}")
    private String databaseUrlFile;

    @Value("${DATABASE_URL:#{null}}")
    private String databaseUrl;

    @Bean
    public DataSource dataSource() {
        String url;

        if (databaseUrlFile != null) {
            // Read from secrets file
            try {
                url = Files.readString(Paths.get(databaseUrlFile)).trim();
            } catch (IOException e) {
                throw new RuntimeException("Failed to read database URL from file", e);
            }
        } else {
            // Fallback to environment variable (development)
            url = databaseUrl;
        }

        return DataSourceBuilder.create().url(url).build();
    }
}
```

**Python (FastAPI)**:

```python
import os
from pathlib import Path

def get_database_url():
    """Get database URL from secrets file or environment variable."""
    url_file = os.getenv("DATABASE_URL_FILE")

    if url_file and Path(url_file).exists():
        # Read from secrets file
        return Path(url_file).read_text().strip()
    else:
        # Fallback to environment variable (development)
        return os.getenv("DATABASE_URL", "postgresql://localhost/taskdb")

DATABASE_URL = get_database_url()
```

**Rust (Actix-web)**:

```rust
use std::env;
use std::fs;

fn get_database_url() -> Result<String, Box<dyn std::error::Error>> {
    if let Ok(url_file) = env::var("DATABASE_URL_FILE") {
        // Read from secrets file
        Ok(fs::read_to_string(url_file)?.trim().to_string())
    } else {
        // Fallback to environment variable (development)
        Ok(env::var("DATABASE_URL").unwrap_or_else(|_| {
            "postgresql://localhost/taskdb".to_string()
        }))
    }
}
```

## 🔒 Security Layer 3: Read-Only Root Filesystem

### Why Read-Only Matters

```dockerfile
# Without read-only: Container can write anywhere
FROM alpine
# Attacker could: echo "malicious" > /etc/passwd

# With read-only: Container filesystem is immutable
# Attacker cannot modify system files
```

### Implementing Read-Only Containers

#### Read-Only Dockerfile Pattern

```dockerfile
FROM python:3.12-slim

# Install dependencies (needs write access during build)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

# Create writable directories for application needs
RUN mkdir -p /app/logs /app/temp /app/cache && \
    chown -R appuser:appuser /app

WORKDIR /app
COPY --chown=appuser:appuser . .

USER appuser:appuser

# Application needs write access to these directories
VOLUME ["/app/logs", "/app/temp", "/app/cache"]

EXPOSE 8080
CMD ["python", "app.py"]
```

#### Docker Compose with Read-Only Root

```yaml
version: "3.8"

services:
  task-api:
    build: .
    read_only: true # Root filesystem is read-only
    tmpfs:
      - /tmp:size=100M # Writable temp space
      - /var/run:size=50M
    volumes:
      # Application writable directories
      - app_logs:/app/logs
      - app_cache:/app/cache
    environment:
      - LOG_DIR=/app/logs
      - CACHE_DIR=/app/cache
    networks:
      - backend

volumes:
  app_logs:
  app_cache:

networks:
  backend:
```

#### Testing Read-Only Containers

```bash
# Start read-only container
docker-compose up -d

# Test filesystem immutability
docker-compose exec task-api touch /test-file
# Should fail: Read-only file system

# Test application functionality
curl http://localhost:8080/health
# Should work normally

# Test writable volumes
docker-compose exec task-api touch /app/logs/test.log
# Should succeed
```

## 🔍 Security Layer 4: Vulnerability Scanning

### Using Docker Scout (Built-in)

```bash
# Scan your image for vulnerabilities
docker scout cves task-api:latest

# Quick scan output
✓ Image stored for indexing
✓ Indexed 147 packages
✓ No vulnerable packages detected

# Detailed recommendations
docker scout recommendations task-api:latest

# Compare with base image
docker scout compare --to alpine:latest task-api:latest
```

### Multi-Stage Build for Security

```dockerfile
# Build stage (contains build tools, compilers)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage (minimal, no build tools)
FROM node:18-alpine AS runtime

# Create non-root user
RUN addgroup -g 1000 nodeuser && \
    adduser -D -u 1000 -G nodeuser nodeuser

# Copy only production files
WORKDIR /app
COPY --from=builder --chown=nodeuser:nodeuser /app/node_modules ./node_modules
COPY --chown=nodeuser:nodeuser . .

USER nodeuser:nodeuser

# Security: read-only root filesystem
# Application writes to volumes only
EXPOSE 8080
CMD ["node", "server.js"]
```

## 🚨 Common Security Pitfalls & Solutions

### Pitfall 1: Root User for Package Installation

```dockerfile
# BAD: Stays as root
FROM alpine
RUN apk add --no-cache curl
CMD ["sh"]

# GOOD: Root for installation, non-root for runtime
FROM alpine
RUN apk add --no-cache curl && \
    adduser -D -u 1000 appuser
USER appuser
CMD ["sh"]
```

### Pitfall 2: Secrets in Dockerfile

```dockerfile
# BAD: Secret in image layer
FROM alpine
ENV API_KEY=secret123
RUN wget https://api.example.com/data

# GOOD: Secret from runtime
FROM alpine
# API_KEY provided via Docker secrets or runtime env
RUN apk add --no-cache wget
```

### Pitfall 3: Overprivileged Capabilities

```bash
# BAD: All capabilities
docker run --privileged myapp

# GOOD: Specific capabilities only
docker run --cap-add=NET_BIND_SERVICE myapp

# BETTER: Use higher ports, no capabilities needed
docker run -p 8080:8080 myapp
```

## 🔧 Security Debugging

### Permission Issues Troubleshooting

```bash
# Check container user
docker run --rm myapp id

# Check file ownership
docker run --rm -v $(pwd):/data myapp ls -la /data

# Fix ownership (if needed)
docker run --rm -v $(pwd):/data myapp chown -R 1000:1000 /data

# Debug volume permissions
docker run --rm -v myvolume:/test alpine ls -la /test
```

### Security Assessment Commands

```bash
# Check for root processes
docker exec myapp ps aux | grep -v "^USER" | awk '$1 == "root" {print}'

# Check mounted volumes
docker inspect myapp | jq '.[0].Mounts'

# Check network exposure
docker port myapp

# Check environment variables (look for secrets!)
docker exec myapp env | grep -i password
```

## ✅ Security Fundamentals Checklist

Master these security essentials:

- [ ] All containers run as non-root users (UID 1000+)
- [ ] Secrets use files or Docker secrets, never environment variables
- [ ] Read-only root filesystem implemented where possible
- [ ] Minimal base images used (Alpine, Distroless)
- [ ] Regular vulnerability scanning performed
- [ ] No hardcoded secrets in Dockerfiles or images
- [ ] Proper file ownership and permissions configured
- [ ] Can debug permission issues confidently

## 🚀 Next Steps

Security fundamentals mastered! You're now ready for advanced security patterns and production hardening. These practices will serve you well in any containerized environment.

**Remember**: Security is not optional - it's the foundation of professional containerization!

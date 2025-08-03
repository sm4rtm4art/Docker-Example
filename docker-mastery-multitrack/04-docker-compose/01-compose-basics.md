# Part A: Compose Basics - Your First Multi-Service App 🚀

Build your Task API + PostgreSQL stack and solve the orphan container problems that plague real development environments!

## 🎯 Learning Outcomes

- ✅ Create multi-service applications with Docker Compose
- ✅ Connect your Task API to a PostgreSQL database
- ✅ Understand service discovery and networking
- ✅ Solve orphan container and volume problems
- ✅ Implement proper health checks and dependencies

## 📚 Docker Compose Fundamentals

### What is Docker Compose?

Docker Compose orchestrates multiple containers as a single application stack:

```bash
# Instead of this mess:
docker network create myapp-network
docker volume create postgres-data
docker run -d --name postgres --network myapp-network -v postgres-data:/var/lib/postgresql/data postgres:16
docker run -d --name api --network myapp-network -p 8080:8080 task-api

# Use this simple command:
docker-compose up
```

### Compose File Structure

```yaml
version: "3.8"

services:          # Define your containers
  api:
    build: .
    ports:
      - "8080:8080"

  database:
    image: postgres:16
    environment:
      POSTGRES_DB: tasks

networks:          # Define networks (optional)
  frontend:
  backend:

volumes:           # Define named volumes (optional)
  postgres_data:
```

## 🏗️ Building Your Task Stack

### Step 1: Create the Compose File

Create `docker-compose.yml` in your project root:

```yaml
version: "3.8"

services:
  # Task API Service
  task-api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - app-network

  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db-init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskuser -d taskdb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### Step 2: Create Database Initialization

Create `db-init/01-init.sql`:

```sql
-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE
ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO tasks (title, description, completed) VALUES
('Learn Docker Compose', 'Master multi-container orchestration', false),
('Set up PostgreSQL', 'Configure database with proper volumes', true),
('Implement health checks', 'Add monitoring and dependency management', false);
```

### Step 3: Update Your Task API

Update your application to connect to PostgreSQL:

#### Java (Spring Boot)
```properties
# application.properties
spring.datasource.url=${DATABASE_URL:jdbc:postgresql://localhost:5432/taskdb}
spring.datasource.username=taskuser
spring.datasource.password=taskpass
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
```

#### Python (FastAPI)
```python
# database.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://taskuser:taskpass@localhost:5432/taskdb")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
```

#### Rust (sqlx)
```rust
// main.rs
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://taskuser:taskpass@localhost:5432/taskdb".to_string());

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await?;
```

## 🚀 Running Your Stack

### Basic Operations

```bash
# Start all services
docker-compose up

# Start in background (detached)
docker-compose up -d

# View logs
docker-compose logs
docker-compose logs task-api  # Specific service

# Stop all services
docker-compose down

# Stop and remove volumes (careful!)
docker-compose down --volumes
```

### Health Check Monitoring

```bash
# Check service status
docker-compose ps

# Follow logs for startup issues
docker-compose logs -f postgres
docker-compose logs -f task-api

# Test the stack
curl http://localhost:8080/health
curl http://localhost:8080/api/tasks
```

## 🧹 Solving Orphan Container Problems

### The Orphan Container Problem

**What are orphans?**
Containers that exist but aren't managed by the current compose file:

```bash
# You had this service
services:
  web:
    image: nginx

# Now you renamed it
services:
  frontend:  # Old 'web' container becomes orphan!
    image: nginx
```

### Orphan Solutions

#### 1. The Golden Rule: Use `--remove-orphans`

```bash
# Always use this flag
docker-compose down --remove-orphans

# Start with orphan removal
docker-compose up --remove-orphans
```

#### 2. Project Name Consistency

```bash
# Problem: Different directories create different projects
cd /path/to/project
docker-compose up  # Project name: "project"

cd /different/path/to/project  
docker-compose up  # Project name: "project" (different path)

# Solution: Explicit project naming
docker-compose -p task-management up
docker-compose -p task-management down --remove-orphans
```

#### 3. Development Cleanup Script

Create `cleanup.sh`:

```bash
#!/bin/bash
echo "🧹 Cleaning up Task Management stack..."

# Stop and remove containers
docker-compose -p task-management down --remove-orphans

# Remove unused volumes (be careful!)
echo "📦 Cleaning unused volumes..."
docker volume prune -f

# Remove unused networks
echo "🔗 Cleaning unused networks..."
docker network prune -f

# Remove unused images
echo "🖼️ Cleaning unused images..."
docker image prune -f

echo "✅ Cleanup complete!"
```

### Orphan Prevention Best Practices

```yaml
# 1. Use consistent service names
services:
  task-api:          # Don't change to 'api' or 'web'
    build: .

  postgres:          # Don't change to 'db' or 'database'
    image: postgres:16

# 2. Use project name in compose file
name: task-management  # Compose v2 feature

# 3. Document your service names
# README.md: Service names are stable, don't change them!
```

## 🔗 Service Discovery Magic

### How Services Find Each Other

Docker Compose creates automatic DNS for service communication:

```yaml
services:
  task-api:
    environment:
      # Use service name as hostname!
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
      #                                        ^^^^^^^^
      #                                    Service name = hostname
  postgres:
    image: postgres:16
```

### Testing Service Discovery

```bash
# Start your stack
docker-compose up -d

# Test internal connectivity
docker-compose exec task-api curl http://postgres:5432
docker-compose exec postgres ping task-api

# Test from outside (should fail)
curl http://postgres:5432  # ❌ Won't work
curl http://localhost:8080  # ✅ Works (port mapping)
```

## 🐛 Common Issues & Solutions

### Issue 1: "Database connection refused"

```bash
# Problem: API starts before database is ready
ERROR: connection to server at "postgres" (172.20.0.2), port 5432 failed
```

**Solution**: Use `depends_on` with health checks

```yaml
task-api:
  depends_on:
    postgres:
      condition: service_healthy  # Wait for health check to pass
```

### Issue 2: "Port already in use"

```bash
ERROR: for task-api  Cannot start service: port is already allocated
```

**Solutions**:

```bash
# 1. Find what's using the port
lsof -i :8080
netstat -tulpn | grep :8080

# 2. Use different port
ports:
  - "8081:8080"  # Host:Container

# 3. Stop conflicting services
docker-compose down --remove-orphans
```

### Issue 3: "Volume permission denied"

```bash
ERROR: permission denied in volume
```

**Solution**: Fix ownership in Dockerfile

```dockerfile
# Create volume directory with correct ownership
RUN mkdir -p /var/lib/postgresql/data && \
    chown postgres:postgres /var/lib/postgresql/data

USER postgres
```

## 🏋️ Hands-On Exercise: Build Your Stack

### Challenge: Create a Working Task Management System

1. **Set up the stack**:
   ```bash
   # Create compose file with API + PostgreSQL
   # Include health checks and proper dependencies
   # Use named volumes for data persistence
   ```

2. **Test functionality**:
   ```bash
   # Verify API health endpoint
   curl http://localhost:8080/health

   # Test database connection
   curl -X POST http://localhost:8080/api/tasks \
        -H "Content-Type: application/json" \
        -d '{"title":"Test Docker Compose","description":"Verify DB integration"}'

   # List tasks to verify persistence
   curl http://localhost:8080/api/tasks
   ```

3. **Test orphan cleanup**:
   ```bash
   # Start stack
   docker-compose up -d

   # Rename a service in compose file
   # Restart and check for orphans
   docker-compose up --remove-orphans
   ```

4. **Test data persistence**:
   ```bash
   # Stop stack
   docker-compose down

   # Restart (data should survive)
   docker-compose up -d
   curl http://localhost:8080/api/tasks  # Should show previous data
   ```

## ✅ Success Checklist

Before proceeding to networking:

- [ ] Task API connects to PostgreSQL successfully
- [ ] Health checks work for both services
- [ ] Data persists through container restarts
- [ ] Can clean up orphan containers with `--remove-orphans`
- [ ] Understand service discovery (service names as hostnames)
- [ ] Database initializes with schema and sample data

## 🔍 Understanding What We Built

```bash
# View the complete stack
docker-compose ps

# Check networks
docker network ls | grep task

# Check volumes  
docker volume ls | grep task

# View resource usage
docker-compose top
```

## 🚀 Next Steps

Mastered the basics? Time to level up with [Part B: Compose Networking](./02-compose-networking.md) where we'll add network isolation and load balancing to our stack!

---

**Remember**: The patterns you learned here work for ANY application stack - Java + MySQL, Python + Redis, Rust + MongoDB. The Docker Compose concepts are universal!

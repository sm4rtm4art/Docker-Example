# Part C: Compose Volumes & Data Management 📦

Master data persistence, backup strategies, and volume lifecycle management for production-ready applications!

## 🎯 Learning Outcomes

- ✅ Understand the difference between named volumes and bind mounts
- ✅ Implement database backup and restore strategies
- ✅ Design development vs production data workflows
- ✅ Master volume cleanup and orphan management
- ✅ Prepare data foundation for monitoring stack

## 📚 Volume Types & Use Cases

### Named Volumes vs Bind Mounts vs tmpfs

| Type             | Use Case          | Performance | Portability | Example                                  |
| ---------------- | ----------------- | ----------- | ----------- | ---------------------------------------- |
| **Named Volume** | Production data   | High        | High        | `postgres_data:/var/lib/postgresql/data` |
| **Bind Mount**   | Development files | Medium      | Low         | `./src:/app/src`                         |
| **tmpfs**        | Temporary data    | Highest     | High        | `/tmp` (memory-backed)                   |

### Volume Decision Matrix

```yaml
# ✅ GOOD: Named volumes for data
volumes:
  - postgres_data:/var/lib/postgresql/data  # Persistent database
  - app_logs:/var/log/myapp                # Application logs

# ✅ GOOD: Bind mounts for development
volumes:
  - ./src:/app/src:ro                      # Source code (read-only)
  - ./config:/app/config                   # Configuration files

# ⚠️ CAREFUL: Bind mounts for data
volumes:
  - ./data:/var/lib/postgresql/data        # Host-dependent, backup complexity

# ❌ BAD: No volumes for important data
# Data disappears when container is removed!
```

## 🏗️ Production Data Stack

### Complete Data-Persistent Compose File

```yaml
version: "3.8"

services:
  # Task API with logging
  task-api:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
      - LOG_LEVEL=info
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      # Application logs (named volume)
      - app_logs:/var/log/app
      # Configuration (bind mount for easy updates)
      - ./config:/app/config:ro
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # PostgreSQL with multiple data strategies
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      # Primary data (named volume - most important!)
      - postgres_data:/var/lib/postgresql/data

      # Initialization scripts (bind mount)
      - ./db-init:/docker-entrypoint-initdb.d:ro

      # Configuration (bind mount)
      - ./postgres.conf:/etc/postgresql/postgresql.conf:ro

      # Backup location (named volume)
      - postgres_backups:/backups

      # WAL logs for point-in-time recovery
      - postgres_wal:/var/lib/postgresql/wal
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskuser -d taskdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Backup service (runs periodically)
  postgres-backup:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      - postgres_backups:/backups
    networks:
      - backend
    command: >
      sh -c "
        while true; do
          echo 'Creating backup at $(date)'
          pg_dump -h postgres -U taskuser -d taskdb > /backups/backup_$(date +%Y%m%d_%H%M%S).sql

          # Keep only last 7 days of backups
          find /backups -name '*.sql' -mtime +7 -delete

          # Sleep for 24 hours
          sleep 86400
        done
      "
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  # Production data volumes
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /var/lib/docker-data/postgres # Customize path as needed

  postgres_backups:
    driver: local

  postgres_wal:
    driver: local

  app_logs:
    driver: local

networks:
  frontend:
  backend:
```

## 💾 Database Backup Strategies

### Manual Backup Commands

```bash
# Create immediate backup
docker-compose exec postgres pg_dump -U taskuser -d taskdb > backup_$(date +%Y%m%d).sql

# Restore from backup
docker-compose exec -T postgres psql -U taskuser -d taskdb < backup_20240101.sql

# Create compressed backup
docker-compose exec postgres pg_dump -U taskuser -d taskdb | gzip > backup_$(date +%Y%m%d).sql.gz

# Copy backup out of container
docker-compose exec postgres pg_dump -U taskuser -d taskdb > /backups/manual_backup.sql
docker cp postgres_container:/backups/manual_backup.sql ./backups/
```

### Automated Backup Script

Create `backup.sh`:

```bash
#!/bin/bash

# Backup configuration
BACKUP_DIR="./backups"
RETENTION_DAYS=30
COMPOSE_PROJECT="task-management"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🗄️ Starting backup at $(date)"

# Database backup
echo "📊 Backing up PostgreSQL database..."
docker-compose exec -T postgres pg_dump -U taskuser -d taskdb | gzip > "$BACKUP_DIR/postgres_$TIMESTAMP.sql.gz"

# Volume backup (for named volumes)
echo "📦 Backing up volumes..."
docker run --rm -v ${COMPOSE_PROJECT}_postgres_data:/source -v $(pwd)/$BACKUP_DIR:/backup alpine \
  tar czf /backup/postgres_volume_$TIMESTAMP.tar.gz -C /source .

# Application logs backup
docker run --rm -v ${COMPOSE_PROJECT}_app_logs:/source -v $(pwd)/$BACKUP_DIR:/backup alpine \
  tar czf /backup/app_logs_$TIMESTAMP.tar.gz -C /source .

# Cleanup old backups
echo "🧹 Cleaning up old backups (keeping $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "✅ Backup completed successfully!"
echo "📍 Backup files saved to: $BACKUP_DIR"
ls -la "$BACKUP_DIR" | tail -5
```

### Restore Script

Create `restore.sh`:

```bash
#!/bin/bash

BACKUP_FILE="$1"
BACKUP_DIR="./backups"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

echo "⚠️  WARNING: This will replace the current database!"
echo "📁 Restoring from: $BACKUP_FILE"
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Stopping services..."
    docker-compose stop task-api

    echo "🗄️ Restoring database..."
    zcat "$BACKUP_DIR/$BACKUP_FILE" | docker-compose exec -T postgres psql -U taskuser -d taskdb

    echo "🚀 Restarting services..."
    docker-compose start task-api

    echo "✅ Restore completed!"
else
    echo "❌ Restore cancelled"
fi
```

## 🔄 Development vs Production Workflows

### Development Setup

```yaml
# docker-compose.dev.yml
version: "3.8"

services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev # Development Dockerfile
    volumes:
      # Source code hot reload
      - ./src:/app/src:ro
      - ./config:/app/config
      # Development database (fast, disposable)
      - dev_data:/tmp/dev-data
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://dev:dev@postgres:5432/devdb
    command: ["npm", "run", "dev"] # Hot reload command

  postgres:
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: devdb
    volumes:
      # Use tmpfs for speed (data is temporary)
      - type: tmpfs
        target: /var/lib/postgresql/data
        tmpfs:
          size: 100M

volumes:
  dev_data:
```

### Production Setup

```yaml
# docker-compose.prod.yml
version: "3.8"

services:
  task-api:
    image: task-api:${VERSION:-latest}
    volumes:
      # Production logs and config only
      - app_logs:/var/log/app
      - ./prod-config:/app/config:ro
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://taskuser:${DB_PASSWORD}@postgres:5432/taskdb
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "0.5"

  postgres:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      # Persistent, backed-up storage
      - postgres_data:/var/lib/postgresql/data
      - postgres_backups:/backups
    secrets:
      - db_password

secrets:
  db_password:
    external: true

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/database-storage/postgres
```

### Environment Management

```bash
# Development workflow
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production workflow
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Testing workflow
docker-compose -f docker-compose.yml -f docker-compose.test.yml run --rm tests
```

## 🧹 Volume Cleanup Mastery

### The Volume Cleanup Problem

```bash
# Problem: Dangling volumes accumulate over time
docker volume ls
# Shows dozens of orphaned volumes from development

# Result: Disk space exhaustion
df -h | grep docker
# /var/lib/docker/volumes is full!
```

### Smart Cleanup Strategies

#### 1. Project-Specific Cleanup

```bash
#!/bin/bash
# cleanup-project.sh

PROJECT_NAME="task-management"

echo "🧹 Cleaning up $PROJECT_NAME volumes..."

# Stop and remove containers
docker-compose down --remove-orphans

# Remove project-specific volumes (careful!)
docker volume ls -q --filter name=${PROJECT_NAME} | xargs -r docker volume rm

# Remove only unused volumes for this project
docker volume prune --filter "label=com.docker.compose.project=$PROJECT_NAME" -f

echo "✅ Project cleanup complete!"
```

#### 2. Safe Development Cleanup

```bash
#!/bin/bash
# safe-cleanup.sh

echo "🔍 Analyzing Docker storage usage..."
docker system df

echo "📦 Removing unused volumes (keeping named volumes)..."
docker volume prune -f

echo "🖼️ Removing unused images..."
docker image prune -f

echo "🔗 Removing unused networks..."
docker network prune -f

echo "📊 Storage usage after cleanup:"
docker system df
```

#### 3. Nuclear Cleanup (Development Only!)

```bash
#!/bin/bash
# nuclear-cleanup.sh - USE WITH EXTREME CAUTION!

echo "⚠️  WARNING: This will remove ALL Docker data!"
echo "🚨 This includes ALL volumes, images, containers, and networks!"
read -p "Are you absolutely sure? Type 'YES' to continue: " confirm

if [ "$confirm" = "YES" ]; then
    echo "💥 Performing nuclear cleanup..."
    docker system prune -a --volumes -f
    echo "✅ All Docker data removed!"
else
    echo "❌ Cleanup cancelled (wise choice!)"
fi
```

### Volume Backup Before Cleanup

```bash
# Always backup important volumes before cleanup
VOLUMES_TO_BACKUP="postgres_data app_logs"

for volume in $VOLUMES_TO_BACKUP; do
    echo "📦 Backing up volume: $volume"
    docker run --rm -v $volume:/source -v $(pwd)/emergency-backup:/backup alpine \
        tar czf /backup/${volume}_emergency_$(date +%Y%m%d).tar.gz -C /source .
done

echo "🧹 Now safe to clean up..."
docker volume prune -f
```

## 🔍 Volume Monitoring & Debugging

### Volume Inspection Commands

```bash
# List all volumes with size information
docker system df -v

# Inspect specific volume
docker volume inspect postgres_data

# See which containers use a volume
docker ps -a --filter volume=postgres_data

# Check volume contents
docker run --rm -v postgres_data:/data alpine ls -la /data

# Monitor volume usage
docker run --rm -v postgres_data:/data alpine du -sh /data/*
```

### Volume Performance Testing

```bash
# Test volume write performance
docker run --rm -v postgres_data:/test alpine sh -c "
    dd if=/dev/zero of=/test/speedtest bs=1M count=100 2>&1 | grep -E '(copied|MB/s)'
    rm /test/speedtest
"

# Test volume read performance
docker run --rm -v postgres_data:/test alpine sh -c "
    dd if=/test/largefile of=/dev/null bs=1M 2>&1 | grep -E '(copied|MB/s)' || echo 'No test file found'
"
```

## 🏋️ Hands-On Exercise: Complete Data Strategy

### Challenge: Implement Production Data Management

1. **Set up persistent storage**:

   ```bash
   # Create production-ready compose with all volume types
   # Implement automated backups
   # Test backup and restore procedures
   ```

2. **Development workflow**:

   ```bash
   # Create development override with fast storage
   # Implement hot reload for your application
   # Test data reset capabilities
   ```

3. **Cleanup automation**:

   ```bash
   # Create project-specific cleanup scripts
   # Test volume backup before cleanup
   # Verify important data is preserved
   ```

4. **Disaster recovery test**:
   ```bash
   # Simulate data loss (remove all volumes)
   # Restore from backup
   # Verify application functionality
   ```

## ⚠️ Volume Best Practices

### DO ✅

```yaml
# Use named volumes for important data
volumes:
  - postgres_data:/var/lib/postgresql/data

# Set proper volume drivers for production
postgres_data:
  driver: local
  driver_opts:
    type: ext4
    device: /dev/disk/database-ssd

# Use read-only bind mounts for config
volumes:
  - ./config:/app/config:ro

# Implement backup strategies
# Regular automated backups + manual verification
```

### DON'T ❌

```yaml
# Don't use anonymous volumes for important data
volumes:
  - /var/lib/postgresql/data  # ❌ Data lost on container removal

# Don't bind mount system directories
volumes:
  - /:/host  # ❌ Security risk

# Don't use bind mounts for database data in production
volumes:
  - ./db-data:/var/lib/postgresql/data  # ❌ Performance and portability issues
```

## ✅ Volume Mastery Checklist

Congratulations! You've mastered Docker Compose volumes:

- [ ] Understand named volumes vs bind mounts vs tmpfs
- [ ] Implemented automated database backup system
- [ ] Created development vs production volume strategies
- [ ] Built safe volume cleanup procedures
- [ ] Can restore data from backups confidently
- [ ] Ready for monitoring stack data requirements

## 🎉 Module 04 Complete!

You've built a production-ready, multi-service application with:

- **Service orchestration** with health checks and dependencies
- **Network security** with frontend/backend isolation
- **Data persistence** with backup and restore capabilities
- **Cleanup strategies** to maintain clean environments

## 🚀 Next Module Preview

Ready for the monitoring stack? In **Module 08**, we'll add Prometheus and Grafana to create a complete observability platform:

```
Current Stack:          Module 08 Goal:
┌─────────────┐        ┌─────────────┐     ┌─────────────┐
│  Task API   │───────▶│  Task API   │────▶│ Prometheus  │
│             │        │ + Metrics   │     │             │
└─────────────┘        └─────────────┘     └─────────────┘
       │                       │                    │
       ▼                       ▼                    ▼
┌─────────────┐        ┌─────────────┐     ┌─────────────┐
│ PostgreSQL  │        │ PostgreSQL  │     │   Grafana   │
└─────────────┘        └─────────────┘     └─────────────┘
```

The network and volume foundations you built here will make adding monitoring services seamless!

---

**Remember**: These volume patterns are universal - they work for any stateful application, any database, any logging system. Master these concepts and apply them everywhere!

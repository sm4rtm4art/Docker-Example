# Part B: Compose Networking - Multi-Network Architecture 🔗

Master Docker network isolation, service-to-service communication, and prepare your stack for monitoring services!

## 🎯 Learning Outcomes

- ✅ Design multi-network architectures for security isolation
- ✅ Implement frontend/backend network separation
- ✅ Understand service discovery across networks
- ✅ Configure load balancing and port strategies
- ✅ Prepare network foundation for monitoring stack

## 🏗️ Network Architecture Patterns

### Single Network (Current State)

```yaml
# What we built in Part A
services:
  task-api:
    networks:
      - app-network
  postgres:
    networks:
      - app-network

networks:
  app-network:
```

**Problems with single network:**

- No isolation between database and external services
- Monitoring services can access database directly
- Security risk if container is compromised

### Multi-Network Architecture (Production Pattern)

```yaml
# Better: Network isolation
services:
  task-api:
    networks:
      - frontend # Public-facing
      - backend # Database access

  postgres:
    networks:
      - backend # Database only

  nginx:
    networks:
      - frontend # Load balancer

networks:
  frontend:
  backend:
```

## 🎯 Building Network Isolation

### Step 1: Multi-Network Compose File

Update your `docker-compose.yml`:

```yaml
version: "3.8"

services:
  # Nginx Load Balancer (Frontend)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - task-api
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  # Task API (Frontend + Backend)
  task-api:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - frontend # Receives requests from nginx
      - backend # Connects to database
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # PostgreSQL (Backend Only)
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db-init:/docker-entrypoint-initdb.d
    networks:
      - backend # Isolated from frontend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskuser -d taskdb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

volumes:
  postgres_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true # No external internet access
```

### Step 2: Nginx Configuration

Create `nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream task_api {
        server task-api:8080;
        # Future: Add multiple instances for load balancing
        # server task-api-2:8080;
        # server task-api-3:8080;
    }

    # Health check endpoint
    server {
        listen 80;
        server_name localhost;

        location /health {
            proxy_pass http://task_api/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /api/ {
            proxy_pass http://task_api/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Add CORS headers for development
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
        }

        # Serve static files (future frontend)
        location / {
            return 200 '{"message":"Task Management API","version":"1.0","endpoints":["/api/tasks","/health"]}';
            add_header Content-Type application/json;
        }
    }
}
```

## 🔍 Network Security Benefits

### Network Isolation Test

```bash
# Start the multi-network stack
docker-compose up -d

# Test what can reach what
echo "🔗 Testing network connectivity..."

# ✅ Nginx can reach API (frontend network)
docker-compose exec nginx curl -f http://task-api:8080/health

# ❌ Nginx CANNOT reach database (no backend network)
docker-compose exec nginx curl -f http://postgres:5432 || echo "❌ Blocked (good!)"

# ✅ API can reach database (backend network)
docker-compose exec task-api curl -f http://postgres:5432 || echo "❌ Database not responding (expected)"

# ✅ External access through nginx
curl http://localhost/health
curl http://localhost/api/tasks
```

### Security Advantages

1. **Database isolation**: PostgreSQL is only accessible from backend network
2. **Frontend separation**: Web traffic is isolated from internal services
3. **Monitoring preparation**: Can add monitoring network later
4. **Principle of least privilege**: Services only access what they need

## ⚡ Load Balancing & Scaling

### Horizontal Scaling Pattern

```yaml
# Scale your API horizontally
services:
  task-api-1:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
      - INSTANCE_ID=1
    networks:
      - frontend
      - backend

  task-api-2:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
      - INSTANCE_ID=2
    networks:
      - frontend
      - backend

  task-api-3:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
      - INSTANCE_ID=3
    networks:
      - frontend
      - backend
```

### Advanced Nginx Load Balancing

```nginx
upstream task_api {
    # Load balancing methods
    least_conn;  # Route to server with fewest connections
    # ip_hash;   # Sticky sessions based on client IP
    # random;    # Random distribution

    server task-api-1:8080 weight=3;  # Higher weight = more traffic
    server task-api-2:8080 weight=2;
    server task-api-3:8080 weight=1;

    # Health checks
    server task-api-1:8080 max_fails=3 fail_timeout=30s;
    server task-api-2:8080 max_fails=3 fail_timeout=30s;
}
```

### Auto-Scaling with Compose

```bash
# Scale services on demand
docker-compose up -d --scale task-api=3

# Nginx will automatically load balance across all instances
curl http://localhost/api/tasks  # Routes to different instances
```

## 🔍 Network Debugging

### Network Inspection Commands

```bash
# List all networks
docker network ls

# Inspect specific network
docker network inspect task-management_frontend
docker network inspect task-management_backend

# See which containers are on which networks
docker-compose exec task-api ip route
docker-compose exec postgres ip route

# Check DNS resolution
docker-compose exec task-api nslookup postgres
docker-compose exec nginx nslookup task-api
```

### Network Troubleshooting

```bash
# Test connectivity between services
docker-compose exec nginx ping task-api
docker-compose exec task-api ping postgres

# Check if ports are open
docker-compose exec task-api nc -zv postgres 5432

# View network traffic (advanced)
docker-compose exec task-api tcpdump -i eth0 port 5432
```

## 🔮 Preparing for Monitoring (Module 08 Preview)

### Future Monitoring Network

```yaml
# What we'll add in Module 08
networks:
  frontend: # Public traffic
  backend: # Database access
  monitoring: # Prometheus, Grafana
    internal: true

services:
  prometheus:
    networks:
      - monitoring
      - backend # To scrape API metrics

  grafana:
    networks:
      - monitoring
      - frontend # For dashboard access
```

### Metrics Endpoints Preparation

Add metrics endpoint to your Task API:

```yaml
# In your compose file, expose metrics port
task-api:
  ports:
    - "9090:9090" # Metrics port for Prometheus
  environment:
    - METRICS_PORT=9090
```

## 🐛 Common Network Issues

### Issue 1: "Service not reachable across networks"

```bash
# Problem: Service on wrong network
ERROR: Could not connect to database

# Debug: Check service networks
docker-compose exec task-api ip route
docker inspect task-management_task-api_1 | grep -A 10 NetworkSettings
```

**Solution**: Ensure services share appropriate networks

```yaml
# Both services must be on the same network to communicate
task-api:
  networks:
    - backend # ✅ Can reach postgres

postgres:
  networks:
    - backend # ✅ Can be reached by task-api
```

### Issue 2: "Nginx 502 Bad Gateway"

```bash
# Problem: Nginx can't reach upstream
nginx_1  | connect() failed (111: Connection refused) while connecting to upstream
```

**Solution**: Check upstream service health

```bash
# Verify API is healthy
docker-compose exec nginx curl http://task-api:8080/health

# Check nginx config
docker-compose exec nginx nginx -t
```

### Issue 3: "Database connection intermittent"

```bash
# Problem: Connection pooling across network
ERROR: connection to server closed unexpectedly
```

**Solution**: Adjust connection parameters

```yaml
task-api:
  environment:
    - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb?pool_timeout=30&connect_timeout=60
```

## 🏋️ Hands-On Exercise: Multi-Network Stack

### Challenge: Implement Network Security

1. **Convert to multi-network**:

   ```bash
   # Update your compose file with frontend/backend separation
   # Add nginx load balancer
   # Test network isolation
   ```

2. **Security validation**:

   ```bash
   # Verify nginx cannot reach database directly
   docker-compose exec nginx curl postgres:5432 && echo "❌ Security breach!" || echo "✅ Properly isolated"

   # Verify API can still reach database
   docker-compose exec task-api curl postgres:5432 || echo "Database connectivity works"
   ```

3. **Load balancing test**:

   ```bash
   # Scale your API
   docker-compose up -d --scale task-api=3

   # Test load distribution
   for i in {1..10}; do
     curl http://localhost/api/tasks | grep -o 'instance.*'
   done
   ```

4. **Network debugging**:
   ```bash
   # Trace a request path
   # Client → Nginx → Task API → PostgreSQL
   # Document which networks each hop uses
   ```

## 🔧 Advanced Docker Networking (Beyond Compose)

### Custom Bridge Networks

```bash
# Create custom bridge networks
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  custom-bridge

# Connect containers to custom networks
docker run -d --name db --network custom-bridge postgres:13
docker run -d --name app --network custom-bridge task-api
```

### Overlay Networks (Docker Swarm Preview)

```bash
# Overlay networks span multiple Docker hosts
docker network create --driver overlay \
  --subnet=10.0.0.0/24 \
  --attachable \
  multi-host-network

# Use in swarm mode for service discovery across hosts
docker service create --network multi-host-network nginx
```

### Network Drivers Comparison

| Driver      | Use Case                     | Scope | Example                  |
| ----------- | ---------------------------- | ----- | ------------------------ |
| **bridge**  | Single host containers       | Local | Default Docker networks  |
| **host**    | Network performance critical | Local | `--network host`         |
| **overlay** | Multi-host clustering        | Swarm | Kubernetes, Docker Swarm |
| **macvlan** | Legacy app integration       | Local | Physical network access  |
| **none**    | Network isolation            | Local | Security containers      |

### Advanced Network Configuration

```yaml
# docker-compose.yml with custom networks
networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
  backend:
    driver: bridge
    internal: true # No external access
    ipam:
      config:
        - subnet: 172.21.0.0/24
```

### Network Security Best Practices

- ✅ Use internal networks for backend services
- ✅ Limit container capabilities with `--cap-drop ALL`
- ✅ Implement network segmentation by function
- ✅ Monitor network traffic for anomalies
- ❌ Never use host networking in production
- ❌ Avoid exposing internal services directly

## ✅ Network Mastery Checklist

Before proceeding to volumes:

- [ ] Multi-network architecture implemented (frontend/backend)
- [ ] Nginx load balancer routing traffic correctly
- [ ] Database isolated from frontend network
- [ ] Can scale API services horizontally
- [ ] Understand service discovery across networks
- [ ] Network troubleshooting skills demonstrated

## 🚀 Next Steps

Network security mastered? Time to tackle data persistence with [Part C: Volumes & Data Management](./03-compose-volumes.md) where we'll handle database backups, development workflows, and volume cleanup strategies!

---

**Remember**: These network patterns scale to any architecture - microservices, monitoring stacks, CI/CD pipelines. Master the concepts here and apply them everywhere!

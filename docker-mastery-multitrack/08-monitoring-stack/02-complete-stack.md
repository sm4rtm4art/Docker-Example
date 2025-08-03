# Part B: Complete Stack - Grafana Dashboards & Full Observability 📊

Build the complete monitoring stack with Grafana dashboards, cAdvisor for container metrics, and production-ready observability!

## 🎯 Learning Outcomes

- ✅ Deploy complete monitoring stack with Grafana dashboards
- ✅ Monitor container resources with cAdvisor
- ✅ Create custom dashboards for your Task API
- ✅ Set up alerting rules for production monitoring
- ✅ Understand monitoring stack scaling and reliability patterns

## 🏗️ Complete Stack Architecture

### Full Production Monitoring

```yaml
┌─────────────────────────────────────────────────────────────────┐
│                    Complete Observability Stack                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │   Grafana   │  │ Prometheus  │  │  Task API   │  │  Nginx  │ │
│  │ Dashboards  │◄─│   Metrics   │◄─│ + Metrics   │◄─│   LB    │ │
│  │   :3000     │  │    :9090    │  │   :8080     │  │  :80    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
│         │                │                │              │      │
│         │                ▼                ▼              │      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │      │
│  │ AlertManager│  │   cAdvisor  │  │ PostgreSQL  │      │      │
│  │  Alerting   │  │ Container   │  │ Database    │      │      │
│  │   :9093     │  │ Metrics:8080│  │   :5432     │      │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │      │
│         │                │                │              │      │
│         └────────────────┼────────────────┼──────────────┘      │
│                          │                │                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │Node Exporter│  │Postgres Exp │  │  Volumes    │             │
│  │Host Metrics │  │DB Metrics   │  │   Data      │             │
│  │   :9100     │  │   :9187     │  │ Persistence │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Complete Docker Compose Stack

### Enhanced `docker-compose.monitoring.yml`

```yaml
version: "3.8"

services:
  # Frontend Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - task-api
    networks:
      - frontend
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=80"

  # Task API (from previous modules)
  task-api:
    build: .
    environment:
      - DATABASE_URL=postgresql://taskuser:taskpass@postgres:5432/taskdb
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - frontend
      - backend
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=8080"
      - "prometheus.path=/metrics"

  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskuser
      POSTGRES_PASSWORD: taskpass
      POSTGRES_DB: taskdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskuser -d taskdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  # PostgreSQL Metrics Exporter
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:v0.15.0
    environment:
      DATA_SOURCE_NAME: "postgresql://taskuser:taskpass@postgres:5432/taskdb?sslmode=disable"
    depends_on:
      - postgres
    networks:
      - backend
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9187"

  # Prometheus Metrics Collection
  prometheus:
    image: prom/prometheus:v2.45.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./alerts.yml:/etc/prometheus/alerts.yml:ro
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.console.libraries=/etc/prometheus/console_libraries"
      - "--web.console.templates=/etc/prometheus/consoles"
      - "--storage.tsdb.retention.time=15d"
      - "--web.enable-lifecycle"
      - "--alertmanager.url=http://alertmanager:9093"
    networks:
      - monitoring
      - backend
      - frontend
    depends_on:
      - task-api

  # Grafana Dashboards
  grafana:
    image: grafana/grafana:10.2.0
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    networks:
      - monitoring
      - frontend
    depends_on:
      - prometheus

  # Container Metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.47.0
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    networks:
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=8080"

  # Host Metrics
  node-exporter:
    image: prom/node-exporter:v1.6.1
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - "--path.procfs=/host/proc"
      - "--path.rootfs=/rootfs"
      - "--path.sysfs=/host/sys"
      - "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    networks:
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9100"

  # Alert Manager
  alertmanager:
    image: prom/alertmanager:v0.26.0
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
      - alertmanager_data:/alertmanager
    command:
      - "--config.file=/etc/alertmanager/alertmanager.yml"
      - "--storage.path=/alertmanager"
      - "--web.external-url=http://localhost:9093"
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
  postgres_data:

networks:
  frontend:
  backend:
  monitoring:
```

## 📊 Grafana Dashboard Configuration

### Dashboard Provisioning

Create `grafana/provisioning/dashboards/dashboard.yml`:

```yaml
apiVersion: 1

providers:
  - name: "default"
    orgId: 1
    folder: ""
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

Create `grafana/provisioning/datasources/prometheus.yml`:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

### Task API Dashboard

Create `grafana/dashboards/task-api-dashboard.json`:

```json
{
  "dashboard": {
    "id": null,
    "title": "Task API Monitoring",
    "tags": ["docker", "task-api"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"task-api\"}[5m]))",
            "legendFormat": "Requests/sec"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "unit": "reqps"
          }
        },
        "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 }
      },
      {
        "id": 2,
        "title": "Response Time (95th percentile)",
        "type": "stat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job=\"task-api\"}[5m])) by (le))",
            "legendFormat": "95th percentile"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "unit": "s"
          }
        },
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 }
      },
      {
        "id": 3,
        "title": "Active Tasks",
        "type": "stat",
        "targets": [
          {
            "expr": "tasks_active_count",
            "legendFormat": "Active Tasks"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            }
          }
        },
        "gridPos": { "h": 8, "w": 8, "x": 0, "y": 8 }
      },
      {
        "id": 4,
        "title": "Task Creation Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(tasks_created_total[5m]))",
            "legendFormat": "Tasks/sec"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "unit": "cps"
          }
        },
        "gridPos": { "h": 8, "w": 8, "x": 8, "y": 8 }
      },
      {
        "id": 5,
        "title": "Database Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active Connections"
          }
        ],
        "gridPos": { "h": 8, "w": 8, "x": 16, "y": 8 }
      },
      {
        "id": 6,
        "title": "HTTP Requests by Status Code",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"task-api\"}[5m])) by (status_code)",
            "legendFormat": "{{status_code}}"
          }
        ],
        "gridPos": { "h": 8, "w": 24, "x": 0, "y": 16 }
      },
      {
        "id": 7,
        "title": "Container Memory Usage",
        "type": "timeseries",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{name=~\".*task-api.*\"}",
            "legendFormat": "Memory Usage"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "bytes"
          }
        },
        "gridPos": { "h": 8, "w": 12, "x": 0, "y": 24 }
      },
      {
        "id": 8,
        "title": "Container CPU Usage",
        "type": "timeseries",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{name=~\".*task-api.*\"}[5m]) * 100",
            "legendFormat": "CPU Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent"
          }
        },
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 24 }
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "10s"
  }
}
```

## 🚨 Alerting Configuration

### Prometheus Alert Rules

Create `alerts.yml`:

```yaml
groups:
  - name: task-api-alerts
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_requests_total{job="task-api",status_code=~"5.."}[5m])) /
            sum(rate(http_requests_total{job="task-api"}[5m]))
          ) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Task API error rate is {{ $value | humanizePercentage }} for more than 2 minutes"

      # High response time
      - alert: HighResponseTime
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket{job="task-api"}[5m])) by (le)
          ) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s for more than 5 minutes"

      # Service down
      - alert: ServiceDown
        expr: up{job="task-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Task API service is down"
          description: "Task API has been down for more than 1 minute"

      # High memory usage
      - alert: HighMemoryUsage
        expr: |
          (
            container_memory_usage_bytes{name=~".*task-api.*"} /
            container_spec_memory_limit_bytes{name=~".*task-api.*"}
          ) > 0.90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Task API memory usage is {{ $value | humanizePercentage }} of limit"

  - name: infrastructure-alerts
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: |
          (
            avg by (instance) (
              rate(container_cpu_usage_seconds_total{name=~".*task-api.*"}[5m])
            ) * 100
          ) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "Container CPU usage is {{ $value }}% for more than 5 minutes"

      # Database connection issues
      - alert: DatabaseConnectionHigh
        expr: database_connections_active > 50
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High database connection count"
          description: "Database has {{ $value }} active connections"
```

### AlertManager Configuration

Create `alertmanager.yml`:

```yaml
global:
  smtp_smarthost: "localhost:587"
  smtp_from: "alertmanager@yourdomain.com"

route:
  group_by: ["alertname"]
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: "web.hook"

receivers:
  - name: "web.hook"
    webhook_configs:
      - url: "http://127.0.0.1:5001/"

  # Email notifications (configure SMTP)
  - name: "email-notifications"
    email_configs:
      - to: "admin@yourdomain.com"
        subject: "Alert: {{ .GroupLabels.alertname }}"
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

  # Slack notifications (configure webhook)
  - name: "slack-notifications"
    slack_configs:
      - api_url: "YOUR_SLACK_WEBHOOK_URL"
        channel: "#alerts"
        title: "Task API Alert"
        text: "{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}"
```

## 🚀 Deploying the Complete Stack

### Step 1: Prepare Configuration Files

```bash
# Create directory structure
mkdir -p grafana/provisioning/{dashboards,datasources}
mkdir -p grafana/dashboards

# Copy configuration files (created above)
# - prometheus.yml
# - alerts.yml
# - alertmanager.yml
# - grafana/provisioning/dashboards/dashboard.yml
# - grafana/provisioning/datasources/prometheus.yml
# - grafana/dashboards/task-api-dashboard.json
```

### Step 2: Deploy the Stack

```bash
# Start the complete monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Check all services are running
docker-compose -f docker-compose.monitoring.yml ps

# Expected services:
# nginx, task-api, postgres, postgres-exporter
# prometheus, grafana, cadvisor, node-exporter, alertmanager
```

### Step 3: Access the Services

```bash
# Task API
open http://localhost/api/tasks

# Prometheus
open http://localhost:9090

# Grafana (admin/admin)
open http://localhost:3000

# cAdvisor
open http://localhost:8080

# AlertManager
open http://localhost:9093
```

## 📊 Using Your Monitoring Stack

### Generate Load for Testing

```bash
# Install Apache Bench (or use curl in a loop)
# macOS: brew install httpd
# Ubuntu: sudo apt install apache2-utils

# Generate load
ab -n 1000 -c 10 http://localhost/api/tasks

# Or with curl
for i in {1..100}; do
  curl -X POST http://localhost/api/tasks \
    -H "Content-Type: application/json" \
    -d '{"title":"Load test","description":"Testing monitoring"}'
  curl http://localhost/api/tasks > /dev/null
  sleep 0.1
done
```

### Essential Grafana Queries

Navigate to Grafana → Explore and try these queries:

```promql
# Request rate over time
sum(rate(http_requests_total{job="task-api"}[5m])) by (status_code)

# Memory usage trend
container_memory_usage_bytes{name=~".*task-api.*"}

# Database query performance
pg_stat_activity_count

# Container CPU usage
rate(container_cpu_usage_seconds_total{name=~".*task-api.*"}[5m]) * 100

# Active connections to database
database_connections_active
```

### Creating Custom Dashboards

1. **Navigate to Grafana** → Dashboards → New Dashboard
2. **Add Panel** → Select Prometheus as data source
3. **Enter PromQL query**:
   ```promql
   sum(rate(tasks_created_total[5m])) by (status)
   ```
4. **Configure visualization** (Time series, Stat, Gauge, etc.)
5. **Set panel title and description**
6. **Save dashboard**

## 🔍 Troubleshooting the Stack

### Common Issues

#### 1. "Grafana shows no data"

```bash
# Check Prometheus data source
curl http://localhost:9090/api/v1/targets

# Verify Grafana can reach Prometheus
docker-compose exec grafana wget -qO- http://prometheus:9090/api/v1/status/config

# Check dashboard queries
# Go to Grafana → Explore → Query: up{job="task-api"}
```

#### 2. "cAdvisor not showing container metrics"

```bash
# Check cAdvisor permissions
docker-compose logs cadvisor

# Verify Docker socket access
ls -la /var/run/docker.sock

# Test direct access
curl http://localhost:8080/metrics | grep container_memory
```

#### 3. "AlertManager not firing alerts"

```bash
# Check alert rules are loaded
curl http://localhost:9090/api/v1/rules

# Verify alert conditions
# Go to Prometheus → Alerts → View active alerts

# Check AlertManager config
curl http://localhost:9093/api/v1/status
```

## ✅ Complete Stack Checklist

Congratulations on building a production monitoring stack!

- [ ] All services (9 containers) running successfully
- [ ] Grafana dashboard shows Task API metrics
- [ ] cAdvisor provides container resource metrics
- [ ] Prometheus collects metrics from all exporters
- [ ] AlertManager rules configured and testable
- [ ] Can generate load and see metrics update in real-time
- [ ] Understand how to create custom dashboards and alerts

## 🎉 Monitoring Mastery Achieved!

You've built a **world-class monitoring stack** that includes:

- **Application Metrics**: Request rates, response times, business KPIs
- **Infrastructure Metrics**: Container CPU, memory, network, disk
- **Database Metrics**: Connection counts, query performance
- **Alerting**: Proactive notifications for issues
- **Dashboards**: Beautiful, actionable visualizations

## 🚀 Next Steps

Ready for production best practices? Continue to [Part C: Production Patterns](./03-production-patterns.md) where we'll cover high availability, data retention, and scaling strategies!

---

**Remember**: This monitoring architecture scales to any application stack - microservices, serverless, edge computing. Master these patterns and apply them everywhere!

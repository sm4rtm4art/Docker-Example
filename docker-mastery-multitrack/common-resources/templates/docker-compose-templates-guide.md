# Docker Compose Templates 🐳

Reusable Docker Compose configurations for common patterns across all modules.

## 🎯 How to Use

These templates are designed to be combined with your main `docker-compose.yml` file:

```bash
# Base application
docker compose up  # V2 syntax (recommended)
# OR: docker-compose up  # V1 syntax (legacy)

# Add database
docker compose -f docker-compose.yml -f docker-compose.database.yml up

# Add monitoring  
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml up

# Full stack
docker compose \
  -f docker-compose.yml \
  -f docker-compose.database.yml \
  -f docker-compose.monitoring.yml \
  up
```

> Note: Use `docker compose` (V2). Legacy `docker-compose` (V1) is deprecated and may be missing on modern systems.

## 📁 Available Templates

### 🗄️ `docker-compose.database.yml`

- **PostgreSQL** with health checks
- **pgAdmin** for database management
- **Volume persistence** for data
- **Security patterns** (non-default passwords)

### 📊 `docker-compose.monitoring.yml`

- **Prometheus** for metrics collection
- **Grafana** for visualization dashboards
- **Service discovery** configuration
- **Volume persistence** for dashboards

### 🔧 `docker-compose.development.yml`

- **Hot reload** configurations
- **Debug ports** exposed
- **Development tools** included
- **Volume mounts** for live editing

### 🛡️ `docker-compose.production.yml`

- **Resource limits** applied
- **Health checks** configured
- **Security hardening** enabled
- **Logging** optimized

## 🎓 Learning Progression

**Module 02**: Use base application only
**Module 04**: Add database template
**Module 05**: Add development template
**Module 08**: Add monitoring template
**Module 07**: Add production template

## 💡 Benefits

- ✅ **Consistent patterns** across all language tracks
- ✅ **Reusable configurations** reduce duplication
- ✅ **Educational progression** from simple to complex
- ✅ **Production-ready** templates
- ✅ **Easy testing** of different combinations

Perfect for learning Docker composition patterns! 🚀

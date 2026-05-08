# Docker Compose Templates 🐳

Reusable Docker Compose configurations for common patterns across all modules.

## 🎯 How to Use

These templates are designed to be combined with your main `docker-compose.yml` file:

```bash
# Base application
docker compose up

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

> **Note**: Use `docker compose` (V2) for course commands. `docker-compose` (V1) is legacy compatibility and may be missing on modern systems.

## 📁 Available Templates

These are the templates currently included in this folder.

### 🗄️ `docker-compose.database.yml`

- **PostgreSQL** with health checks
- **pgAdmin** for database management
- **Volume persistence** for data
- **Local classroom defaults** clearly marked as dev-only

### 📊 `docker-compose.monitoring.yml`

- **Prometheus** for metrics collection
- **Grafana** for visualization dashboards
- **Service discovery** configuration
- **Volume persistence** for dashboards

Future development or production-specific templates should be added here only after the files exist and their scope is clearly labeled.

## 🎓 Learning Progression

**Module 02**: Use base application only
**Module 04**: Add database template
**Module 08**: Add monitoring template

## 💡 Benefits

- ✅ **Consistent patterns** across all language tracks
- ✅ **Reusable configurations** reduce duplication
- ✅ **Educational progression** from simple to complex
- ✅ **Teaching templates** with local classroom assumptions called out
- ✅ **Easy testing** of different combinations

Perfect for learning Docker composition patterns! 🚀

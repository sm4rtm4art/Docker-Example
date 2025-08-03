# Python Task API - Quick Start 🐍

Ready-to-run Python FastAPI template for Docker learning!

## 🚀 Quick Start

```bash
# Clone and run immediately
git clone <your-repo>
cd docker-mastery-multitrack/02-language-quickstart/python

# Start development environment
docker compose up  # V2 syntax (recommended)
# OR: docker-compose up  # V1 syntax (legacy)

# Test your API
curl http://localhost:8080/health
curl http://localhost:8080/docs  # Interactive API docs
```

## 📁 What's Included

- ✅ **FastAPI application** with full Task API
- ✅ **UV package manager** (modern) with pip fallback
- ✅ **Production Dockerfile** with security best practices
- ✅ **Development Dockerfile** with hot reload
- ✅ **Docker Compose** for local development
- ✅ **Health checks** and metrics endpoints
- ✅ **Non-root user** security patterns

## 📦 Package Management Strategy

**Primary**: `pyproject.toml` (UV - modern Python package manager)  
**Fallback**: `requirements.txt` (pip - traditional compatibility)

UV is faster and more reliable, but we include pip fallback for maximum compatibility!

## 🎯 Next Steps

1. **Module 03**: Optimize the Dockerfiles
2. **Module 04**: Add PostgreSQL database
3. **Module 05**: Set up IDE integration
4. **Module 08**: Add monitoring stack

Perfect for learning Docker with Python! 🐳

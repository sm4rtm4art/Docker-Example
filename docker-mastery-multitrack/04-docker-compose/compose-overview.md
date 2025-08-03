# Module 04: Docker Compose - Multi-Service Orchestration 🎼

Master multi-container applications with Docker Compose! Learn to orchestrate your Task API with PostgreSQL, solve orphan container problems, and build towards a complete monitoring stack.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Orchestrate multi-container applications with Docker Compose
- ✅ Design service networks and data persistence strategies
- ✅ Solve orphan container and volume cleanup problems
- ✅ Implement health checks and dependency management
- ✅ Debug common multi-service issues
- ✅ Build incrementally towards a monitoring stack

## 📚 Module Structure

### 🚀 Part A: Compose Basics (1 hour)
**Focus**: Services, networks, volumes fundamentals
- Task API + PostgreSQL integration
- Service discovery and networking
- Volume persistence patterns
- **Cleanup lesson**: Orphan container management

### 🔗 Part B: Compose Networking (1 hour)  
**Focus**: Multi-network isolation and communication
- Frontend vs backend network separation
- Service-to-service communication
- Port mapping strategies
- Load balancing basics

### 📦 Part C: Compose Volumes & Data (1 hour)
**Focus**: Data persistence and backup strategies
- Named volumes vs bind mounts
- Database backup and restore
- Development vs production data strategies
- **Cleanup lesson**: Volume lifecycle management

## 🎯 Real-World Focus

This module solves **actual problems** you'll encounter:
- ❌ "My containers won't talk to each other"
- ❌ "I have orphan containers everywhere"
- ❌ "My data disappeared when I restarted"
- ❌ "The database takes forever to start"
- ❌ "I can't clean up my development environment"

## 🚀 What We're Building

### Progressive Build: Task Management Stack

```
Stage 1: API + Database
┌─────────────┐     ┌─────────────┐
│  Task API   │────▶│ PostgreSQL  │
│   :8080     │     │   :5432     │
└─────────────┘     └─────────────┘

Stage 2: Add Networking
┌─────────────┐     ┌─────────────┐
│  Task API   │────▶│ PostgreSQL  │
│ (frontend)  │     │ (backend)   │
└─────────────┘     └─────────────┘

Stage 3: Add Monitoring (Module 08 preview)
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Task API   │────▶│ PostgreSQL  │────▶│ Prometheus  │
└─────────────┘     └─────────────┘     └─────────────┘
```

## 📋 Prerequisites

- Completed [Module 03: Dockerfile Essentials](../03-dockerfile-essentials/)
- Your containerized Task API from Module 03
- Docker Compose v2.x installed
- Basic understanding of databases (PostgreSQL)

## 🧹 Cleanup Strategy Integration

**Every lesson includes cleanup!**
- Part A: `docker-compose down --remove-orphans`
- Part B: Network isolation and cleanup
- Part C: Volume lifecycle management
- Bonus: Automated cleanup scripts

## ✅ Success Criteria

By the end of this module:
- [ ] Run a complete Task API + PostgreSQL stack
- [ ] Understand the difference between named volumes and bind mounts
- [ ] Confidently clean up orphan containers and volumes
- [ ] Debug common networking issues between services
- [ ] Ready to add monitoring services (Prometheus/Grafana)

---

**Next**: Start with [Part A: Compose Basics](./01-compose-basics.md) to build your first multi-service application!

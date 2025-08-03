# Docker Learning Curriculum 🐳

> **Master Docker fundamentals through multiple programming languages**

A comprehensive, production-ready Docker learning path that teaches Docker concepts first, then applies them across Java, Python, and Rust. Built for developers who want to understand Docker deeply, not just copy commands.

## 🎯 Philosophy: Docker First, Language Second

**Traditional approach**: "Learn Docker with Python"  
**Our approach**: **"Learn Docker, apply to YOUR language"**

- 🐳 **Docker concepts are universal** - master them once
- 🔄 **70% content reuse** across all language tracks
- 🛡️ **Security-first** from day one (always non-root)
- 🎯 **Real problem solving** (container cleanup, monitoring)
- 🚀 **Production patterns** throughout

## 📚 Learning Path

| Phase           | Duration  | Focus                                        | Outcome               |
| --------------- | --------- | -------------------------------------------- | --------------------- |
| **Foundation**  | 4.5 hours | Docker fundamentals + language quickstart    | Container confidence  |
| **Core Skills** | 8 hours   | Dockerfiles, Compose, development workflow   | Multi-service mastery |
| **Production**  | 7 hours   | Security, monitoring, operational excellence | Production deployment |
| **Advanced**    | 4 hours   | CI/CD, orchestration, alternatives           | Ecosystem expertise   |

**Total**: 18-24 hours of hands-on learning

## 🏗️ What You'll Build

### Core Project: Task Management API

- **Task API** in your language of choice (Java Spring Boot, Python FastAPI, Rust Actix)
- **PostgreSQL** database with persistent storage
- **Complete monitoring stack** (Prometheus + Grafana)
- **Production deployment** with security, health checks, and cleanup automation

### Advanced Projects:

- Multi-architecture Docker builds (ARM + x86)
- Container registry management (Docker Hub, ECR, GCR)
- CI/CD pipelines with GitHub Actions
- Migration from Docker to Podman

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/sm4rtm4art/Docker-Example.git
cd Docker-Example

# Choose your path
cd docker-mastery-multitrack

# Start with prerequisites
cd 00-prerequisites
```

### Language Track Selection

**Choose your language track**, but remember - the Docker concepts are universal:

- **Java**: Spring Boot + Maven (enterprise-ready)
- **Python**: FastAPI + UV (modern Python tooling)
- **Rust**: Actix-web + Cargo (performance-focused)

## 📋 Prerequisites

- **Docker Desktop** installed and running
- **Basic terminal/command line** experience
- **One programming language** (Java, Python, or Rust)
- **Git** for version control

No prior Docker experience required!

## 🎓 Learning Features

### 🔧 Hands-On Exercises

- Real debugging scenarios ("break then fix")
- Container cleanup challenges
- Security vulnerability exercises
- Performance optimization tasks

### 🛡️ Security-First Approach

- **Always non-root containers**
- **Read-only filesystems** where possible
- **Secrets management** best practices
- **Vulnerability scanning** integration

### 🧹 Cleanup Integration

- **Container lifecycle management** throughout
- **Volume and network cleanup** strategies
- **Development vs production** separation patterns
- **Monitoring and maintenance** automation

## 📖 Curriculum Structure

The complete curriculum is located in [`docker-mastery-multitrack/`](./docker-mastery-multitrack/) with detailed learning materials.

### Complete Learning Path:

📚 **[Docker Curriculum Guide](./docker-mastery-multitrack/docker-curriculum-guide.md)** - Full module breakdown and learning path

### Key Documents:

- **[Learning Objectives](./LEARNING_OBJECTIVES.md)** - Detailed skill outcomes
- **[Task API Specification](./TASK_API_SPECIFICATION.md)** - Technical project requirements
- **[Development Setup](./DEVELOPMENT_SETUP.md)** - Environment configuration
- **[Implementation Progress](./TASKLIST.md)** - Development roadmap

## 🔗 Additional Resources

### Helper Scripts

- [`scripts/`](./scripts/) - Cross-platform utilities (Windows + Unix)
- Docker cleanup automation
- Development environment setup
- Health check utilities

### Examples

- [`examples/`](./examples/) - Reference implementations
- Security-focused Dockerfiles
- Volume management patterns
- Container networking examples

## 🌟 Why This Curriculum?

### For **Developers**:

- Master Docker once, apply everywhere
- Build production-ready containerization skills
- Understand security and operational best practices

### For **Teams**:

- Consistent Docker knowledge across language stacks
- Shared security and operational patterns
- Reduced onboarding time for new technologies

### For **Organizations**:

- Standardized containerization approach
- Security-first development practices
- Production-ready deployment patterns

## 🤝 Contributing

This is an open educational resource. Contributions welcome!

- **Report issues** for unclear instructions
- **Suggest improvements** for better learning
- **Add language tracks** following our patterns
- **Share real-world scenarios** for exercises

## 📄 License

Educational content is available under [LICENSE](./LICENSE) for learning and teaching purposes.

---

> **"The best way to learn Docker is to master the concepts first, then apply them to solve real problems."**  
> Start your journey with [Prerequisites](./docker-mastery-multitrack/00-prerequisites/prerequisites-overview.md) ➡️

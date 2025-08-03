# Module 03: Dockerfile Essentials 🐳

Transform your applications into portable, secure containers! This module teaches you to write production-ready Dockerfiles using patterns that work across all programming languages.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Write secure Dockerfiles following industry best practices
- ✅ Choose appropriate base images for different scenarios
- ✅ Implement non-root user patterns for security
- ✅ Optimize builds with layer caching strategies
- ✅ Use multi-stage builds for production deployments
- ✅ Debug common containerization issues across languages

## 📚 Module Structure

### 🏗️ Part A: Dockerfile Fundamentals (1 hour)

**Focus**: Core instructions, security, base images

- FROM, WORKDIR, COPY, RUN, EXPOSE, USER, ENTRYPOINT
- Non-root users (security-first approach)
- Ubuntu vs Alpine base image selection
- Build context and .dockerignore

### ⚡ Part B: Multi-stage Optimization (1 hour)

**Focus**: Production builds, size optimization

- Build vs Runtime environments
- Dependency caching strategies
- Security benefits (no build tools in production)
- Distroless images for maximum security

### 🔧 Part C: Language Implementations (30 min each)

**Focus**: Apply patterns to your language

- Java: JAR artifacts, JVM optimization
- Python: Virtual environments, UV patterns
- Rust: Static binaries, compilation optimization

## 🎯 Docker-First Learning

> **Remember**: We're teaching Docker concepts that work everywhere. The languages are just different use cases for the same Docker patterns!

### Core Principles

1. **Security First**: Non-root by default
2. **Layer Optimization**: Cache what changes least
3. **Minimal Runtime**: Only what you need to run
4. **Production Ready**: Health checks, proper signals

## 🚀 Prerequisites

- Completed [Module 01: Docker Fundamentals](../01-docker-fundamentals/)
- Your language's Task API from [Module 02](../02-language-quickstart/)
- Docker Desktop running
- Basic command line familiarity

## 📋 Success Criteria

By the end of this module:

- [ ] Build secure containers for your Task API
- [ ] Demonstrate 50%+ size reduction with multi-stage builds
- [ ] Implement proper non-root user patterns
- [ ] Understand when to use Ubuntu vs Alpine vs Distroless
- [ ] Debug container permission and startup issues

---

**Next**: Start with [Part A: Dockerfile Fundamentals](./01-dockerfile-fundamentals.md)

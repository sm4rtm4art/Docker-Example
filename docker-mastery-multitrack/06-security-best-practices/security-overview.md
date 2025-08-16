# Module 06: Security Best Practices - Production-Ready Security 🛡️

Secure your containers from the ground up! Learn industry best practices, solve real security issues, and implement defense-in-depth strategies for production deployments.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Implement defense-in-depth security strategies
- ✅ Diagnose and fix common security vulnerabilities
- ✅ Use secrets management instead of environment variables
- ✅ Configure read-only containers and filesystems
- ✅ Implement security scanning and monitoring
- ✅ Debug permission and access issues confidently

## 📚 Module Focus: Real-World Security

This module addresses **actual security problems** you'll encounter:

- ❌ "My container is running as root"
- ❌ "Secrets are visible in docker inspect"
- ❌ "Container can write to system files"
- ❌ "How do I scan for vulnerabilities?"
- ❌ "Permission denied errors everywhere"

## 🔒 Security Layers

### 1. Container Security (Build Time)

- Non-root users (mandatory)
- Minimal base images
- Multi-stage builds (no build tools in production)
- Security scanning

### 2. Runtime Security

- Read-only root filesystems
- Resource limits
- Network isolation
- Secrets management

### 3. Host Security

- User namespace remapping
- SELinux/AppArmor
- Container runtime security

### 4. Monitoring Security

- Security event logging
- Vulnerability monitoring
- Access auditing

## 🎯 What We'll Secure

Using your Task API + PostgreSQL stack from Module 04:

```
Before Security:           After Security:
┌─────────────┐           ┌─────────────┐
│  Task API   │           │  Task API   │
│   (root)    │    ───▶   │ (non-root)  │
│ rw filesystem│           │ read-only   │
└─────────────┘           └─────────────┘
       │                         │
       ▼                         ▼
┌─────────────┐           ┌─────────────┐
│ PostgreSQL  │           │ PostgreSQL  │
│   (root)    │    ───▶   │ (postgres)  │
│ env secrets │           │ file secrets│
└─────────────┘           └─────────────┘
```

## 📋 Prerequisites

- Completed [Module 04: Docker Compose](../04-docker-compose/)
- Working Task API + PostgreSQL stack
- Understanding of Linux users and permissions
- Basic knowledge of network security concepts

## 🚨 Security-First Mindset

**Remember**: Security is not optional - it's the foundation of professional Docker usage!

Every pattern we learn here prevents real attacks:

- **Container escape** → Non-root users
- **Data theft** → Secrets management
- **System compromise** → Read-only filesystems
- **Privilege escalation** → Resource limits

## ✅ Success Criteria

By the end of this module:

- [ ] All containers run as non-root users
- [ ] Secrets are managed securely (no environment variables)
- [ ] Containers use read-only root filesystems where possible
- [ ] Vulnerability scanning is automated
- [ ] Can debug permission issues confidently
- [ ] Understand when root access IS necessary

## 📝 Knowledge Check

Before moving to production deployment, verify you can:

1. **Non-root containers**: All your containers run as non-root users (check with `docker exec container id`)
2. **Read-only filesystems**: Understand when and how to use `--read-only` flag
3. **Secrets management**: Never put secrets in Dockerfiles or environment variables
4. **Minimal images**: Choose appropriate base images (Alpine, distroless, or scratch)
5. **Security scanning**: Use `docker scout` or similar tools to check for vulnerabilities

**Quick Self-Test**: Rebuild your Task API container to run as a non-root user, scan it for vulnerabilities, and ensure it still works correctly. If successful, you're security-ready!

## 🆘 Having Issues?

**Permission denied errors?** **Container running as root?** **Security scan failures?**

➡️ Check our [**Docker Emergency Guide**](../common-resources/DOCKER_EMERGENCY_GUIDE.md) - especially the security and permissions troubleshooting sections.

**Need help with non-root containers?** The emergency guide has step-by-step fixes for user permission issues.

---

**Next**: Start with [Security Fundamentals](./01-security-fundamentals.md) to build your security foundation!

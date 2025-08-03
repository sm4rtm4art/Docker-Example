# Java Docker Onboarding: From Eclipse to Kubernetes 🚀

Welcome to your comprehensive journey from Java development to containerization and orchestration! This hands-on learning path is designed specifically for Java developers who want to master Docker, Docker Compose, and get a taste of Kubernetes.

## 🎯 Learning Objectives

By completing this onboarding, you will:

- ✅ Containerize Spring Boot applications with Docker
- ✅ Master multi-stage builds for optimized Java images
- ✅ Integrate Docker with Eclipse IDE and VS Code
- ✅ Orchestrate multi-container applications with Docker Compose
- ✅ Understand Linux distributions in containers (Alpine vs Ubuntu)
- ✅ Implement CI/CD pipelines with GitHub Actions and GitLab CI
- ✅ Set up comprehensive observability with Prometheus, Grafana, Fluent Bit, and OpenTelemetry
- ✅ Get hands-on introduction to Kubernetes

## 📋 Prerequisites

- **Java Development**: Proficiency in Java (we'll use Java 17)
- **IDE**: Eclipse IDE (VS Code instructions also provided)
- **Operating System**: Windows 10/11, macOS, or Linux
- **Hardware**: At least 8GB RAM, 20GB free disk space
- **Accounts**: GitHub account (GitLab examples also included)

## 🗺️ Learning Path

Each module builds upon the previous one. Complete them in order for the best learning experience:

| Module                                                                           | Topic                              | Duration  | Difficulty |
| -------------------------------------------------------------------------------- | ---------------------------------- | --------- | ---------- |
| [00-prerequisites](./00-prerequisites/prerequisites-setup.md)                    | System setup and tool installation | 30 min    | ⭐         |
| [01-java-in-eclipse](./01-java-in-eclipse/java-setup-guide.md)                   | Spring Boot REST API setup         | 1 hour    | ⭐         |
| [02-dockerfile-basics](./02-dockerfile-basics/dockerfile-fundamentals.md)        | First Docker container             | 1.5 hours | ⭐⭐       |
| [03-eclipse-docker-plugin](./03-eclipse-docker-plugin/ide-docker-integration.md) | IDE Docker integration             | 1 hour    | ⭐⭐       |
| [04-multistage-builds](./04-multistage-builds/multistage-optimization.md)        | Optimized Java images              | 1.5 hours | ⭐⭐⭐     |
| [05-docker-compose-db](./05-docker-compose-db/)                                  | Multi-container with MariaDB       | 2 hours   | ⭐⭐⭐     |
| [06-linux-in-container](./06-linux-in-container/)                                | Linux distro exploration           | 1 hour    | ⭐⭐       |
| [07-development-workflow](./07-development-workflow/)                            | Hot reload & debugging             | 1.5 hours | ⭐⭐⭐     |
| [08-production-ready](./08-production-ready/)                                    | Security & best practices          | 2 hours   | ⭐⭐⭐⭐   |
| [09-kubernetes-preview](./09-kubernetes-preview/)                                | K8s introduction                   | 2 hours   | ⭐⭐⭐⭐   |
| [10-cicd-pipelines](./10-cicd-pipelines/)                                        | GitHub Actions & GitLab CI         | 1.5 hours | ⭐⭐⭐     |
| [11-monitoring-stack](./11-monitoring-stack/)                                    | Complete Observability Stack       | 3 hours   | ⭐⭐⭐⭐   |

**Total estimated time**: 17-19 hours (can be spread over 2-3 weeks)

## 🛠️ Technology Stack

- **Language**: Java 17
- **Framework**: Spring Boot 3.x
- **Build Tool**: Maven
- **Database**: MariaDB
- **Container Runtime**: Docker & Docker Compose
- **Orchestration**: Kubernetes (Minikube for local)
- **CI/CD**: GitHub Actions, GitLab CI
- **Monitoring**: Prometheus, Grafana, Fluent Bit, OpenTelemetry, Jaeger
- **IDEs**: Eclipse, VS Code

## 📚 How to Use This Repository

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/java-docker-onboarding.git
   cd java-docker-onboarding
   ```

2. **Start with prerequisites**:

   ```bash
   cd 00-prerequisites
   cat prerequisites-setup.md
   ```

3. **Follow each module sequentially**:

   - Read the module's guide completely
   - Complete the hands-on exercises
   - Try the "Troubleshooting & Explore" challenges
   - Check your understanding with the verification steps

4. **Use the common resources**:
   - [Docker Cheat Sheet](./common-resources/docker-tips/cheat-sheet.md)
   - [Troubleshooting Guide](./common-resources/docker-tips/troubleshooting.md)
   - [Helper Scripts](./common-resources/scripts/)

## 🎓 Learning Tips

1. **Hands-on Practice**: Don't just read—type every command and understand what it does
2. **Experiment**: Break things on purpose to understand how they work
3. **Take Notes**: Document your learnings and gotchas
4. **Ask Questions**: Use the issues section for questions
5. **Go Beyond**: Each module has "Going Further" sections for additional learning

## 🚦 Quick Start Commands

After completing the prerequisites, here are some commands you'll master:

```bash
# Build a Docker image
docker build -t my-java-app .

# Run a container
docker run -p 8080:8080 my-java-app

# Start multi-container application
docker-compose up -d

# Check container logs
docker logs -f container-name

# Execute commands in container
docker exec -it container-name /bin/sh
```

## 📖 Additional Resources

- [Official Docker Documentation](https://docs.docker.com/)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)
- [Eclipse Docker Tooling](https://www.eclipse.org/community/eclipse_newsletter/2017/june/article3.php)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## 🤝 Contributing

Found an issue or want to improve the content? Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Ready to start your containerization journey? Head to [00-prerequisites](./00-prerequisites/prerequisites-setup.md) to begin! 🎉**

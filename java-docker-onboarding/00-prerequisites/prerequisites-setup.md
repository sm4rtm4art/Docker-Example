# Module 00: Prerequisites and System Setup 🛠️

Welcome to your containerization journey! This foundational module ensures your development environment is properly configured for success.

## 🎯 Learning Outcomes

By completing this module, you will be able to:

- ✅ Install and verify all required development tools
- ✅ Configure your system for container development
- ✅ Understand the purpose of each tool in the containerization workflow
- ✅ Troubleshoot common installation issues
- ✅ Execute basic commands to verify your setup

## 📚 What You'll Learn

1. **Tool Installation**: Java 17, Maven, Docker/Podman, Git, IDEs
2. **System Configuration**: Environment variables, PATH settings, permissions
3. **Verification**: Testing each tool works correctly
4. **Integration**: How these tools work together

## ⏱️ Time Investment

- **Reading**: 10 minutes
- **Hands-on Setup**: 15-20 minutes
- **Troubleshooting**: Variable (0-10 minutes)
- **Total**: ~30 minutes

## 📋 Required Software

### 1. Java Development Kit (JDK) 17

**Windows/macOS/Linux:**

```bash
# Verify Java installation
java -version
javac -version

# Should show: openjdk version "17.x.x" or similar
```

If not installed, download from:

- [Oracle JDK 17](https://www.oracle.com/java/technologies/downloads/#java17)
- [OpenJDK 17](https://adoptium.net/temurin/releases/?version=17)

### 2. Maven 3.8+

```bash
# Verify Maven installation
mvn -version

# Should show: Apache Maven 3.8.x or higher
```

Installation:

- **Windows**: Download from [Maven website](https://maven.apache.org/download.cgi)
- **macOS**: `brew install maven`
- **Linux**: `sudo apt install maven` or `sudo yum install maven`

### 3. Docker Desktop

Download and install Docker Desktop:

- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- [Docker Engine for Linux](https://docs.docker.com/engine/install/)

**Verify installation:**

```bash
docker --version
docker-compose --version
docker run hello-world
```

### 4. IDE Setup

#### Eclipse IDE (Primary)

1. Download [Eclipse IDE for Enterprise Java Developers](https://www.eclipse.org/downloads/packages/)
2. Install Spring Tools 4 (STS) from Eclipse Marketplace
3. Install Docker Tooling (we'll configure this in Module 03)

#### Visual Studio Code (Alternative)

1. Download [VS Code](https://code.visualstudio.com/)
2. Install extensions:
   ```
   - Java Extension Pack
   - Spring Boot Extension Pack
   - Docker
   - Remote - Containers
   ```

### 5. Git

```bash
# Verify Git installation
git --version
```

If not installed:

- **Windows**: [Git for Windows](https://gitforwindows.org/)
- **macOS**: `brew install git`
- **Linux**: `sudo apt install git`

### 6. Additional Tools

#### kubectl (for Kubernetes module)

```bash
# Install kubectl
# macOS
brew install kubectl

# Windows (using Chocolatey)
choco install kubernetes-cli

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Minikube (for local Kubernetes)

- [Minikube Installation Guide](https://minikube.sigs.k8s.io/docs/start/)

## 🔧 System Configuration

### 1. Docker Configuration

**Allocate Resources** (Docker Desktop Settings):

- **Memory**: Minimum 4GB, recommended 6GB
- **CPUs**: Minimum 2, recommended 4
- **Disk**: At least 20GB free space

### 2. Environment Variables

Add to your system PATH:

- `JAVA_HOME` pointing to JDK 17 installation
- `MAVEN_HOME` pointing to Maven installation
- Docker should be automatically added to PATH

**Windows (PowerShell):**

```powershell
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", "C:\Program Files\Apache\maven", "User")
```

**macOS/Linux (.bashrc or .zshrc):**

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export MAVEN_HOME=/usr/local/apache-maven
export PATH=$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin
```

### 3. Docker Hub Account

Create a free account at [Docker Hub](https://hub.docker.com/) for pushing images.

```bash
# Login to Docker Hub
docker login
```

## ✅ Verification Script

Create a file `verify-setup.sh`:

```bash
#!/bin/bash

echo "🔍 Checking prerequisites..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed: $(command -v $1)"
        $1 --version 2>&1 | head -n 1
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
    echo ""
}

check_command java
check_command javac
check_command mvn
check_command docker
check_command docker-compose
check_command git
check_command kubectl

# Check Docker daemon
if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is NOT running"
fi

echo ""
echo "📋 System Information:"
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Available Memory: $(free -h 2>/dev/null | grep Mem: | awk '{print $2}' || echo 'Check manually on this OS')"
echo "Docker Desktop Memory: Check in Docker Desktop settings"
```

Make it executable and run:

```bash
chmod +x verify-setup.sh
./verify-setup.sh
```

## 🚀 Quick Test

Let's verify everything works with a simple test:

```bash
# Create a test directory
mkdir test-setup && cd test-setup

# Create a simple Java file
cat > HelloDocker.java << 'EOF'
public class HelloDocker {
    public static void main(String[] args) {
        System.out.println("Hello from Java " +
            System.getProperty("java.version") +
            " ready for Docker!");
    }
}
EOF

# Compile and run
javac HelloDocker.java
java HelloDocker

# Create a simple Dockerfile
cat > Dockerfile << 'EOF'
FROM openjdk:17-alpine
COPY HelloDocker.class /app/
WORKDIR /app
CMD ["java", "HelloDocker"]
EOF

# Build and run Docker image
docker build -t hello-docker .
docker run --rm hello-docker

# Cleanup
cd .. && rm -rf test-setup
```

## 🎯 Troubleshooting & Explore

### Common Issues

1. **"Cannot connect to Docker daemon"**

   - Ensure Docker Desktop is running
   - On Linux, add user to docker group: `sudo usermod -aG docker $USER`
   - Log out and back in

2. **"JAVA_HOME not set"**

   - Verify path exists: `ls $JAVA_HOME`
   - Ensure it points to JDK, not JRE

3. **"Maven command not found"**

   - Check PATH includes Maven bin directory
   - Restart terminal after setting environment variables

4. **Docker Desktop won't start on Windows**
   - Enable virtualization in BIOS
   - Enable Hyper-V and WSL2
   - Check Windows version (requires Windows 10 Pro/Enterprise)

### Explore Further

1. **Check Docker resource usage:**

   ```bash
   docker system df
   docker stats --no-stream
   ```

2. **Explore Docker info:**

   ```bash
   docker info
   docker version --format '{{json .}}' | jq .
   ```

3. **Test Maven with a simple project:**
   ```bash
   mvn archetype:generate -DgroupId=com.test -DartifactId=test-app \
     -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
   cd test-app && mvn package
   ```

## 🏋️ Practice Exercises

### Exercise 1: Environment Variables Practice

Set up a custom environment variable and verify it works:

```bash
# Set a test variable
export MY_TEST_VAR="Docker Learning"

# Verify it's set
echo $MY_TEST_VAR

# Use it in a Docker command
docker run --rm -e TEST=$MY_TEST_VAR alpine sh -c 'echo "Test variable: $TEST"'
```

### Exercise 2: Docker vs Podman Comparison

If you have both installed, compare their commands:

```bash
# Docker version
docker --version
docker info | grep -E "Server Version|Storage Driver"

# Podman version (if installed)
podman --version
podman info | grep -E "version|graphDriverName"
```

### Exercise 3: Resource Check

Create a script to check all prerequisites:

```bash
# Create check-all.sh
cat > check-all.sh << 'EOF'
#!/bin/bash
echo "=== System Prerequisites Check ==="
echo ""
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Maven: $(mvn -version 2>&1 | head -n 1)"
echo "Docker: $(docker --version 2>&1)"
echo "Git: $(git --version 2>&1)"
echo ""
echo "Docker daemon: $(docker info > /dev/null 2>&1 && echo "Running" || echo "Not running")"
EOF

chmod +x check-all.sh
./check-all.sh
```

## 📝 Self-Assessment Questions

Before proceeding, ensure you can answer these questions:

1. **Why do we need Java 17 specifically?**

   - Spring Boot 3.x requires Java 17 as minimum version
   - LTS (Long Term Support) version with modern features

2. **What's the difference between Docker Desktop and Docker Engine?**

   - Desktop: GUI + Engine + additional tools (Kubernetes, extensions)
   - Engine: Core runtime only (typically for servers)

3. **Why might someone choose Podman over Docker?**

   - Security: Rootless by default
   - No daemon: More secure architecture
   - Enterprise: Better for regulated environments

4. **What does `docker run hello-world` actually test?**

   - Docker client can communicate with daemon
   - Daemon can pull images from Docker Hub
   - Daemon can create and run containers
   - Your system supports containerization

5. **Why do we add users to the docker group on Linux?**
   - Allows running Docker commands without sudo
   - Security trade-off: docker group = root equivalent

## 🎮 Hands-On Challenge

Complete this mini-challenge to test your understanding:

**Challenge**: Create a simple containerized "Hello Java" application without using any IDE.

```bash
# 1. Create a simple Java program
mkdir hello-container && cd hello-container

cat > HelloDocker.java << 'EOF'
public class HelloDocker {
    public static void main(String[] args) {
        System.out.println("Hello from Java " +
            System.getProperty("java.version") +
            " in a container!");
        System.out.println("Container OS: " +
            System.getProperty("os.name"));
    }
}
EOF

# 2. Compile it
javac HelloDocker.java

# 3. Create a simple Dockerfile
cat > Dockerfile << 'EOF'
FROM openjdk:17-alpine
COPY HelloDocker.class /
CMD ["java", "HelloDocker"]
EOF

# 4. Build and run
docker build -t hello-java .
docker run --rm hello-java

# 5. Clean up
cd .. && rm -rf hello-container
```

**Success Criteria**: You should see output showing Java version and "Linux" as the OS.

## 🔍 Understanding the Tools

### Tool Relationships

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Java     │────▶│    Maven    │────▶│   JAR/WAR   │
│  (Runtime)  │     │   (Build)   │     │  (Artifact) │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Docker    │────▶│ Dockerfile  │────▶│    Image    │
│  (Runtime)  │     │   (Build)   │     │  (Artifact) │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Why Each Tool Matters

- **Java 17**: Modern LTS version with container-aware features
- **Maven**: Dependency management and consistent builds
- **Docker**: Containerization platform
- **Git**: Version control for code and Dockerfiles
- **IDE**: Productivity and debugging tools

## ✅ Ready to Continue?

If all verifications pass, you're ready to move to [Module 01: Java in Eclipse](../01-java-in-eclipse/java-setup-guide.md)!

If you encounter issues, check the [Troubleshooting Guide](../common-resources/docker-tips/troubleshooting.md) or create an issue in the repository.

---

**Next Module:** [01-java-in-eclipse →](../01-java-in-eclipse/java-setup-guide.md)

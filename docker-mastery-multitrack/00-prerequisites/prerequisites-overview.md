# Module 00: Prerequisites and System Setup 🛠️

> **Welcome to Docker mastery!** This module ensures your development environment is ready for containerization across multiple programming languages.

## 🎯 Learning Objectives

By completing this module, you will be able to:

- ✅ Install and verify Docker on your operating system
- ✅ Choose and set up your preferred programming language track
- ✅ Configure essential development tools
- ✅ Understand the containerization workflow
- ✅ Troubleshoot common setup issues
- ✅ Execute verification commands to confirm readiness

## 📚 What You'll Learn

1. **Core Tools**: Docker/Podman, Git, code editor
2. **Language Track**: Choose Java, Python, or Rust and set up tooling
3. **System Configuration**: PATH, permissions, environment variables
4. **Verification**: Test that everything works together
5. **Cross-platform Setup**: Instructions for Windows, macOS, and Linux

## ⏱️ Time Investment

- **Reading & Planning**: 10 minutes
- **Core Tools Setup**: 15-20 minutes
- **Language-Specific Setup**: 10-15 minutes
- **Verification**: 5 minutes
- **Total**: ~30-45 minutes (one-time setup)

## 🌍 Operating System Support

This learning path works on:

- **Windows 10/11** (with WSL2 recommended)
- **macOS 10.14+**
- **Linux** (Ubuntu, Debian, CentOS, Fedora, Arch)

## 🐳 Core Requirements (All Students)

### 1. Docker Desktop / Docker Engine

**Why Docker?** The heart of this learning path - containerization technology.

#### Windows:

```powershell
# Option 1: Download Docker Desktop
# Visit: https://docs.docker.com/desktop/install/windows-install/

# Option 2: Using Chocolatey
choco install docker-desktop

# Verify installation
docker --version
docker run hello-world
```

#### macOS:

```bash
# Option 1: Download Docker Desktop
# Visit: https://docs.docker.com/desktop/install/mac-install/

# Option 2: Using Homebrew
brew install --cask docker

# Verify installation
docker --version
docker run hello-world
```

#### Linux:

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Log out and back in

# Verify installation
docker --version
docker run hello-world
```

### 2. Git Version Control

**Why Git?** Source code management and accessing example repositories.

```bash
# Verify installation
git --version

# If not installed:
# Windows: Download from https://git-scm.com/
# macOS: brew install git
# Linux: sudo apt install git (Ubuntu/Debian)
```

### 3. Code Editor

**Why?** Writing Dockerfiles and application code.

**Recommended**: [Visual Studio Code](https://code.visualstudio.com/) with Docker extension

**Alternatives**: IntelliJ IDEA, Eclipse, Vim, Sublime Text

## 🎯 Choose Your Language Track

Select **ONE** primary language for your learning journey. You can always explore others later!

### ☕ Java Track

**Perfect for**: Enterprise developers, Spring ecosystem enthusiasts

#### Required Tools:

```bash
# Java Development Kit 17+
java -version
javac -version

# Maven 3.8+
mvn -version

# IDE: IntelliJ IDEA or Eclipse (optional but recommended)
```

#### Installation:

```bash
# Windows (Chocolatey)
choco install openjdk17 maven

# macOS (Homebrew)
brew install openjdk@17 maven

# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install openjdk-17-jdk maven

# Verify
java -version    # Should show Java 17+
mvn -version     # Should show Maven 3.8+
```

### 🐍 Python Track

**Perfect for**: Data scientists, web developers, automation engineers

#### Required Tools:

```bash
# Python 3.11+
python3 --version

# UV (modern, fast package manager - Rust-powered!)
uv --version

# IDE: VS Code with Python extension (recommended)
```

#### Installation:

```bash
# Install UV (cross-platform)
curl -LsSf https://astral.sh/uv/install.sh | sh
# Or: pip install uv

# Windows (if curl not available)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Verify
python3 --version   # Should show Python 3.11+
uv --version        # Should show UV package manager
```

### 🦀 Rust Track

**Perfect for**: Systems programmers, performance enthusiasts

#### Required Tools:

```bash
# Rust toolchain (rustc, cargo)
rustc --version
cargo --version

# IDE: VS Code with Rust-analyzer extension
```

#### Installation:

```bash
# Install Rust (cross-platform)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Windows (alternative)
# Download from: https://rustup.rs/

# Verify
rustc --version     # Should show Rust 1.70+
cargo --version     # Should show Cargo package manager
```

## 🧪 Verification Steps

After installing your chosen tools, run these verification commands:

### Universal Verification:

```bash
# Docker is working
docker --version
docker run hello-world

# Git is working
git --version

# System resources
docker system info | grep -E "CPUs|Memory"
```

### Language-Specific Verification:

#### Java:

```bash
java -version
mvn -version
echo 'public class Hello { public static void main(String[] args) { System.out.println("Java ready!"); } }' > Hello.java
javac Hello.java && java Hello
rm Hello.java Hello.class
```

#### Python:

```bash
python3 --version
uv --version
echo 'print("Python ready!")' | python3
uv --help | head -5
```

#### Rust:

```bash
rustc --version
cargo --version
echo 'fn main() { println!("Rust ready!"); }' > hello.rs
rustc hello.rs && ./hello
rm hello.rs hello
```

## 🛠️ Development Environment Setup

### VS Code Extensions (Recommended)

Install these extensions for the best experience:

#### Universal:

- **Docker** (by Microsoft)
- **GitLens** (by GitKraken)
- **YAML** (by Red Hat)

#### Language-Specific:

**Java Track**:

- **Extension Pack for Java** (by Microsoft)
- **Spring Boot Extension Pack** (by VMware)

**Python Track**:

- **Python** (by Microsoft)
- **Pylance** (by Microsoft)

**Rust Track**:

- **rust-analyzer** (by The Rust Programming Language)
- **CodeLLDB** (by Vadim Chugunov)

### Alternative IDEs

#### Java Developers:

- **IntelliJ IDEA** (Community or Ultimate)
- **Eclipse IDE** with Docker plugin

#### Python Developers:

- **PyCharm** (Community or Professional)
- **Jupyter Notebook** for data science

#### Rust Developers:

- **CLion** (with Rust plugin)
- **Vim/Neovim** with LSP support

## 🔧 System Configuration

### Docker Configuration

```bash
# Verify Docker daemon is running
docker info

# Test with a simple container
docker run --rm alpine:latest echo "Docker is working!"

# Check available resources
docker system df
```

### Git Configuration (if needed)

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Language-Specific Configuration

#### Java:

```bash
# Verify JAVA_HOME (may be needed for some tools)
echo $JAVA_HOME

# If not set (Linux/macOS):
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# Add to ~/.bashrc or ~/.zshrc
```

#### Python:

```bash
# Create a test virtual environment with UV
uv venv test-env
source test-env/bin/activate  # Linux/macOS
# test-env\Scripts\activate.bat  # Windows
deactivate
rm -rf test-env
```

#### Rust:

```bash
# Update Rust to latest stable
rustup update

# Verify toolchain
rustup show
```

## 🚨 Troubleshooting

### Docker Issues

#### "Docker daemon not running" (Linux)

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

#### "Permission denied" (Linux)

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

#### Port conflicts

```bash
# Check if port 80 or 8080 is in use
netstat -tuln | grep :80
# or
ss -tuln | grep :80
```

### Language-Specific Issues

#### Java: "JAVA_HOME not set"

```bash
# Find Java installation
which java
ls -la $(which java)

# Set JAVA_HOME
export JAVA_HOME=/path/to/java/home
```

#### Python: "UV command not found"

```bash
# Add UV to PATH
export PATH="$HOME/.cargo/bin:$PATH"
# Or reinstall UV
pip install uv
```

#### Rust: "Cargo not found"

```bash
# Source Rust environment
source $HOME/.cargo/env
# Or add to shell profile
echo 'source $HOME/.cargo/env' >> ~/.bashrc
```

## 🎓 Knowledge Check

Before proceeding to Module 01, ensure you can:

1. **Run Docker containers**: `docker run hello-world`
2. **Check language tools**: Version commands for your chosen language
3. **Access code editor**: Open and edit files
4. **Use command line**: Navigate directories, run commands
5. **Understand your choice**: Know why you picked your language track

## 🚀 What's Next?

Congratulations! Your development environment is ready.

**Next Steps**:

1. **[Module 01: Docker Fundamentals](../01-docker-fundamentals/)** - Learn core Docker concepts (language-agnostic)
2. **[Module 02: Language Quickstart](../02-language-quickstart/)** - Your first containerized application in your chosen language

## 📚 Additional Resources

### Docker Learning:

- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Desktop User Manual](https://docs.docker.com/desktop/)

### Language-Specific:

- **Java**: [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker/)
- **Python**: [Python Docker Guide](https://docs.python.org/3/library/venv.html)
- **Rust**: [Rust Container Guide](https://doc.rust-lang.org/cargo/)

### Cross-Platform Development:

- [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/)
- [Docker on Windows](https://docs.docker.com/desktop/install/windows-install/)

---

**🎉 Ready to start your Docker journey?**

Head to [Module 01: Docker Fundamentals](../01-docker-fundamentals/) to begin learning containerization concepts that apply to all programming languages!

_"The best way to learn Docker is by using it. Let's start building!"_

# Part C: IDE Integration - Seamless Development Experience 🎨

Transform your IDE to work seamlessly with Docker! Make containerized development feel exactly like native development with VS Code, IntelliJ, and other popular editors.

## 🎯 Learning Outcomes

- ✅ Set up VS Code Remote Containers for native-feeling development
- ✅ Configure IntelliJ IDEA Docker integration effectively
- ✅ Create development container configurations (devcontainers)
- ✅ Manage terminal access and shell environments
- ✅ Separate development and production IDE configurations
- ✅ Optimize IDE performance with containerized development

## 🎨 The IDE Integration Philosophy

### The Goal: "Make Docker Invisible"

```
Bad Integration                     Great Integration
├── Switch between IDE and CLI     ├── Everything in the IDE
├── Manual container management    ├── Automatic container lifecycle
├── Complex debugging setup       ├── One-click debugging
├── File sync issues              ├── Seamless file access
└── Frustrating workflow          └── Native development feel
```

**Perfect integration**: Developers forget they're using containers!

## 🎯 VS Code: The Gold Standard

### Method 1: Dev Containers (Recommended)

**Step 1: Install VS Code Extensions**

```bash
# Install required extensions
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-python.python
code --install-extension ms-java.language-support-base-java
code --install-extension rust-lang.rust-analyzer
```

**Step 2: Create .devcontainer Configuration**

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Task API Development",
  "dockerComposeFile": ["../docker-compose.yml", "../docker-compose.dev.yml"],
  "service": "task-api",
  "workspaceFolder": "/app",

  // VS Code configuration
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.debugpy",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "editor.formatOnSave": true
      }
    }
  },

  // Container configuration
  "forwardPorts": [8080],
  "postCreateCommand": "pip install -r requirements.txt",
  "remoteUser": "devuser",

  // Mounts for persistence
  "mounts": [
    "source=${localWorkspaceFolder}/.vscode,target=/app/.vscode,type=bind",
    "source=task-api-extensions,target=/home/devuser/.vscode-server/extensions,type=volume"
  ]
}
```

**Step 3: Language-Specific Configurations**

**Python Track (.devcontainer/devcontainer.json)**:

```json
{
  "name": "Python Task API",
  "build": {
    "dockerfile": "../Dockerfile.dev",
    "context": ".."
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.debugpy",
        "ms-python.pylint",
        "ms-toolsai.jupyter"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.testing.pytestEnabled": true,
        "python.testing.pytestPath": "/usr/local/bin/pytest"
      }
    }
  },
  "forwardPorts": [8080, 5678],
  "postCreateCommand": "pip install -r requirements.txt && pip install -r requirements-dev.txt"
}
```

**Java Track (.devcontainer/devcontainer.json)**:

```json
{
  "name": "Java Task API",
  "build": {
    "dockerfile": "../Dockerfile.dev",
    "context": ".."
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "redhat.java",
        "ms-java.language-support-base-java",
        "vscjava.vscode-java-debug",
        "vscjava.vscode-maven"
      ],
      "settings": {
        "java.configuration.runtimes": [
          {
            "name": "JavaSE-21",
            "path": "/usr/local/openjdk-21"
          }
        ]
      }
    }
  },
  "forwardPorts": [8080, 5005],
  "postCreateCommand": "mvn clean compile"
}
```

**Rust Track (.devcontainer/devcontainer.json)**:

```json
{
  "name": "Rust Task API",
  "build": {
    "dockerfile": "../Dockerfile.dev",
    "context": ".."
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "rust-lang.rust-analyzer",
        "vadimcn.vscode-lldb",
        "serayuzgur.crates"
      ],
      "settings": {
        "rust-analyzer.cargo.buildScripts.enable": true,
        "rust-analyzer.checkOnSave.command": "clippy"
      }
    }
  },
  "forwardPorts": [8080],
  "postCreateCommand": "cargo build"
}
```

### Method 2: Remote-Containers Extension

**Step 1: Set Up Development Compose**

Ensure your `docker-compose.dev.yml` keeps containers running:

```yaml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app:cached
    # Keep container running for IDE attachment
    command: ["tail", "-f", "/dev/null"]
    stdin_open: true
    tty: true
```

**Step 2: Attach VS Code to Running Container**

```bash
# Start development environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# In VS Code:
# 1. Ctrl+Shift+P → "Remote-Containers: Attach to Running Container"
# 2. Select your task-api container
# 3. VS Code opens in container context!
```

## 🧠 IntelliJ IDEA: Enterprise Development

### Step 1: Enable Docker Plugin

1. **File → Settings → Plugins**
2. **Enable "Docker" plugin** (usually pre-installed)
3. **Restart IntelliJ IDEA**

### Step 2: Configure Docker Integration

**Add Docker Configuration**:

1. **File → Settings → Build, Execution, Deployment → Docker**
2. **Add → Docker**
3. **Connection**: Usually auto-detected
4. **Test Connection** to verify

### Step 3: Create Run Configuration

**For Java Projects**:

1. **Run → Edit Configurations**
2. **Add → Docker → Docker Compose**
3. **Compose files**: Select `docker-compose.yml` and `docker-compose.dev.yml`
4. **Service**: Select `task-api`
5. **Environment variables**: Add any needed vars

**Advanced Configuration**:

```yaml
# IntelliJ-specific docker-compose.intellij.yml
version: "3.8"
services:
  task-api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
      - "5005:5005" # Debug port
    volumes:
      - .:/app:cached
      - ~/.m2:/home/devuser/.m2:cached # Maven cache
    environment:
      - JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
    # Keep running for IDE attachment
    stdin_open: true
    tty: true
```

### Step 4: Configure Remote Debugging

1. **Run → Edit Configurations**
2. **Add → Remote JVM Debug**
3. **Host**: `localhost`
4. **Port**: `5005`
5. **Module classpath**: Select your project module

## 🛠️ Terminal and Shell Integration

### VS Code Integrated Terminal

**Configure shell access in devcontainer.json**:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "terminal.integrated.profiles.linux": {
          "bash": {
            "path": "/bin/bash",
            "args": []
          }
        }
      }
    }
  },
  "remoteUser": "devuser"
}
```

### Multi-Terminal Setup

Create useful terminal shortcuts:

**.devcontainer/setup.sh**:

```bash
#!/bin/bash
# Development environment setup script

echo "Setting up development environment..."

# Install additional tools
pip install black isort flake8 pytest

# Set up git (if needed)
git config --global user.name "Dev User"
git config --global user.email "dev@example.com"

# Create useful aliases
echo "alias ll='ls -la'" >> ~/.bashrc
echo "alias logs='docker-compose logs -f'" >> ~/.bashrc
echo "alias restart='docker-compose restart'" >> ~/.bashrc

echo "Development environment ready!"
```

**Reference in devcontainer.json**:

```json
{
  "postCreateCommand": "bash .devcontainer/setup.sh"
}
```

## 📁 Project Structure for IDE Integration

### Recommended Directory Layout

```
task-api/
├── .devcontainer/
│   ├── devcontainer.json          # VS Code dev container config
│   └── setup.sh                   # Post-create setup script
├── .vscode/
│   ├── launch.json                # Debug configurations
│   ├── tasks.json                 # Build tasks
│   └── settings.json              # Workspace settings
├── .idea/                         # IntelliJ configuration (auto-generated)
├── src/                           # Application source code
├── tests/                         # Test files
├── docker-compose.yml             # Production compose
├── docker-compose.dev.yml         # Development compose
├── Dockerfile                     # Production Dockerfile
├── Dockerfile.dev                 # Development Dockerfile
└── README.md                      # Project documentation
```

### VS Code Workspace Configuration

**.vscode/settings.json**:

```json
{
  "python.defaultInterpreterPath": "/usr/local/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/node_modules": true,
    "**/target": true
  },
  "docker.defaultRegistryPath": "your-registry.com"
}
```

**.vscode/tasks.json**:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Development Environment",
      "type": "shell",
      "command": "docker-compose",
      "args": [
        "-f",
        "docker-compose.yml",
        "-f",
        "docker-compose.dev.yml",
        "up",
        "-d"
      ],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Stop Development Environment",
      "type": "shell",
      "command": "docker-compose",
      "args": ["down"],
      "group": "build"
    },
    {
      "label": "View Logs",
      "type": "shell",
      "command": "docker-compose",
      "args": ["logs", "-f", "task-api"],
      "group": "test"
    }
  ]
}
```

## 🚀 Performance Optimization for IDE Integration

### Volume Mount Optimizations

```yaml
# Optimized for IDE performance
services:
  task-api:
    volumes:
      # Source code - frequent changes
      - ./src:/app/src:cached

      # Configuration - rare changes
      - ./requirements.txt:/app/requirements.txt:ro
      - ./package.json:/app/package.json:ro

      # Dependencies - avoid mounting
      - /app/node_modules
      - /app/.venv

      # IDE configuration
      - ./.vscode:/app/.vscode:cached
```

### Memory and CPU Allocation

```yaml
# Development resource limits
services:
  task-api:
    deploy:
      resources:
        limits:
          memory: 2G # Generous for development
          cpus: "2.0" # Multiple cores for IDE
        reservations:
          memory: 512M
          cpus: "0.5"
```

## 🔄 Development vs Production Separation

### Configuration Strategy

**Development-specific features**:

```yaml
# docker-compose.dev.yml
version: "3.8"
services:
  task-api:
    environment:
      - DEBUG=true
      - LOG_LEVEL=DEBUG
      - RELOAD=true
    volumes:
      - .:/app:cached
    ports:
      - "5678:5678" # Debug port
```

**Production exclusions**:

```yaml
# docker-compose.yml (production)
version: "3.8"
services:
  task-api:
    environment:
      - DEBUG=false
      - LOG_LEVEL=INFO
    # No volumes for security
    # No debug ports
```

### IDE Environment Switching

**.vscode/launch.json** (Multi-environment):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug in Container (Development)",
      "type": "python",
      "request": "attach",
      "connect": {
        "host": "localhost",
        "port": 5678
      },
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}/src",
          "remoteRoot": "/app/src"
        }
      ]
    },
    {
      "name": "Local Development",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder}/src/main.py",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

## ✅ Hands-On Exercise: Complete IDE Setup

### Challenge: Set Up Your Perfect Development Environment

**Choose your IDE path:**

**Option A: VS Code Dev Containers**

1. Create `.devcontainer/devcontainer.json` for your language
2. Configure extensions and settings
3. Set up debugging configuration
4. Test hot reload and debugging

**Option B: IntelliJ IDEA Integration**

1. Configure Docker plugin
2. Create Docker Compose run configuration
3. Set up remote debugging
4. Create useful run tasks

### Success Criteria

- [ ] IDE opens and works inside/with containers
- [ ] Code completion and syntax highlighting work
- [ ] Debugging works with breakpoints
- [ ] Terminal access is seamless
- [ ] File changes are reflected instantly
- [ ] No performance issues or lag

### Verification Steps

```bash
# Test IDE integration
1. Open project in your IDE
2. Set a breakpoint in your code
3. Start debug configuration
4. Make an API call to trigger breakpoint
5. Verify you can inspect variables and step through code
6. Make a code change and verify hot reload works
7. Use integrated terminal to run Docker commands
```

## 🎉 What You've Achieved

🎨 **IDE mastery!** You've transformed your development environment into a seamless, productive powerhouse! Containers are now completely invisible - you have all the benefits of containerization with the familiar, native IDE experience you love!

## 🏆 Module 05 Complete - You're Now a Docker Development Expert!

**What you've mastered in this module**:

- ⚡ **Sub-3-second feedback loops** with hot reload
- 🐛 **Professional debugging** in any containerized language
- 🎨 **Seamless IDE integration** that feels completely native

**Your development workflow transformation**:

```
Before Module 05              After Module 05
├── 60+ second rebuilds   →   ├── 3-second hot reload
├── Painful debugging    →   ├── One-click debugging
├── Context switching    →   ├── Native IDE experience
├── Docker frustration   →   ├── Docker invisibility
└── Productivity drain   →   └── Productivity boost!
```

🚀 **You've eliminated every friction point that makes developers avoid Docker!**

**Next**: Continue to [Module 07: Production Excellence](../07-production-ready/) to learn production-grade patterns, or test your current implementation with [End-to-End Testing](../testing/)!

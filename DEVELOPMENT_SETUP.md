# Development Setup Guide 🛠️

> **Setting up the perfect development environment for contributing to Docker Mastery**

This guide helps contributors set up a development environment that maintains the high-quality standards students expect from this learning path.

## 🎯 Why Development Standards Matter

As an **educational project**, every file students see becomes a learning example:

- **Code quality** teaches best practices
- **Security practices** demonstrate real-world standards
- **Consistency** makes content easier to follow
- **Professional standards** prepare students for industry work

## 🚀 Quick Setup

### 1. Prerequisites

```bash
# Ensure you have Python 3.8+ and pip
python3 --version
pip --version

# Install pre-commit
pip install pre-commit

# For Rust examples (if contributing to Rust track)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# For Java examples (if contributing to Java track)
# Install OpenJDK 17+ and Maven 3.8+

# For Docker linting
# Install Docker Desktop or Docker Engine
```

### 2. Repository Setup

```bash
# Clone the repository
git clone <repository-url>
cd docker-mastery-multitrack

# Install pre-commit hooks
pre-commit install

# Install additional hook types
pre-commit install --hook-type pre-push

# Test the setup
pre-commit run --all-files
```

### 3. Initial Secrets Baseline

```bash
# Generate initial secrets baseline (first time only)
detect-secrets scan --baseline .secrets.baseline

# If you get secrets detected, review them carefully!
# Only add to baseline if they're false positives
detect-secrets audit .secrets.baseline
```

## 🔍 What Pre-commit Checks

### Security & Safety ✅

- **🔐 Secret detection** - No API keys, passwords, or private keys
- **📁 File size limits** - No accidentally committed large files
- **⚠️ Merge conflicts** - No leftover conflict markers
- **🔗 Symlink validation** - No broken symbolic links

### Code Quality ✅

- **🐍 Python**: Black formatting, isort imports, Ruff linting
- **🦀 Rust**: rustfmt formatting, clippy linting
- **☕ Java**: Pretty formatting with consistent style
- **🐚 Shell scripts**: ShellCheck linting, shfmt formatting
- **🐳 Dockerfiles**: Hadolint for best practices

### Documentation ✅

- **📝 Markdown**: Consistent formatting and style
- **📋 YAML**: Valid syntax and structure
- **📖 README structure**: Educational template compliance
- **🔢 Module numbering**: Consistent XX-name format

### Docker Best Practices ✅

- **👤 Non-root users**: Enforce security practices
- **🛡️ Security patterns**: Check for common vulnerabilities
- **📦 Compose validation**: Valid docker-compose syntax

## 🛠️ Development Workflow

### Making Changes

```bash
# Create a feature branch
git checkout -b feature/new-module

# Make your changes
# ...

# Pre-commit runs automatically on commit
git add .
git commit -m "Add new module: XYZ"

# If pre-commit fails, fix issues and try again
# Pre-commit will auto-fix many issues
git add .
git commit -m "Add new module: XYZ"

# Push your changes
git push origin feature/new-module
```

### Manual Pre-commit Runs

```bash
# Run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run black --all-files
pre-commit run hadolint-docker --all-files

# Run on specific files
pre-commit run --files path/to/file.py

# Skip pre-commit (emergency only!)
git commit -m "Emergency fix" --no-verify
```

### Common Fixes

#### Markdown Issues

```bash
# Auto-fix most markdown issues
markdownlint --fix **/*.md

# Check specific rules
markdownlint --rules MD013,MD024 README.md
```

#### Docker Issues

```bash
# Check Dockerfile with hadolint
hadolint Dockerfile

# Common fixes:
# - Add USER instruction
# - Pin base image versions
# - Combine RUN commands
# - Add HEALTHCHECK
```

#### Python Issues

```bash
# Format with black
black .

# Sort imports
isort .

# Fix linting issues
ruff check --fix .
```

#### Rust Issues

```bash
# Format code
cargo fmt

# Check for issues
cargo clippy --all-targets --all-features
```

## 🎓 Educational Content Standards

### README Structure

Every module README should include:

```markdown
# Module XX: Title

> **Brief description**

## 🎯 Learning Objectives

- Specific, measurable goals

## ⏱️ Time Investment

- Breakdown of time needed

## 🏃‍♂️ Hands-On Exercise N

- Practical, progressive exercises

## 🎓 Knowledge Check

- Test understanding

## 🚀 Going Further

- Advanced topics
```

### Dockerfile Standards

Every Dockerfile should:

- Use non-root user (`USER` instruction)
- Include health checks where appropriate
- Follow security best practices
- Be well-commented for educational value
- Use multi-stage builds when beneficial

### Code Example Standards

- **Idiomatic**: Use language best practices
- **Secure**: Follow security guidelines
- **Commented**: Explain non-obvious parts
- **Complete**: Actually runnable examples
- **Progressive**: Build complexity gradually

## 🔧 Troubleshooting

### Pre-commit Issues

#### "command not found: pre-commit"

```bash
# Install pre-commit
pip install pre-commit

# Or with homebrew (macOS)
brew install pre-commit
```

#### "No module named 'detect_secrets'"

```bash
# Install detect-secrets
pip install detect-secrets
```

#### "hadolint: command not found"

Docker not installed or not in PATH:

```bash
# Install Docker Desktop
# Or install hadolint separately
brew install hadolint  # macOS
```

#### "cargo: command not found"

Rust not installed:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Secrets Detection Issues

#### False Positives

If detect-secrets flags something that isn't actually a secret:

```bash
# Review the detection
detect-secrets audit .secrets.baseline

# Mark as false positive in the interactive audit
# Commit the updated baseline
git add .secrets.baseline
```

#### Real Secrets Detected

If you accidentally committed a real secret:

```bash
# Remove the secret from the file
# Then run
git add .
git commit -m "Remove secret"

# For sensitive cases, consider rewriting git history
# or rotating the compromised secret
```

## 📚 Resources

### Pre-commit

- [Pre-commit Documentation](https://pre-commit.com/)
- [Supported Hooks](https://pre-commit.com/hooks.html)

### Code Quality Tools

- [Black](https://black.readthedocs.io/) - Python formatting
- [Ruff](https://docs.astral.sh/ruff/) - Python linting
- [Hadolint](https://github.com/hadolint/hadolint) - Dockerfile linting
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis

### Security

- [Detect Secrets](https://github.com/Yelp/detect-secrets) - Secret detection
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)

---

**Remember**: Every commit is a teaching moment. Let's make sure students learn the right way from the start! 🎓

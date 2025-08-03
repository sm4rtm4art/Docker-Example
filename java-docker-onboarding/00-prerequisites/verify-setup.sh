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
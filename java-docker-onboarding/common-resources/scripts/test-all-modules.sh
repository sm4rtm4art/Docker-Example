#!/bin/bash

# Test All Modules - Validation Script
# This script validates that all modules work as expected

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TIMEOUT=30
CONTAINER_ENGINE=${CONTAINER_ENGINE:-docker}

echo -e "${BLUE}🧪 Java Docker Onboarding - Full Test Suite${NC}"
echo -e "${BLUE}Container Engine: ${CONTAINER_ENGINE}${NC}"
echo ""

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        exit 1
    fi
}

# Function to wait for service
wait_for_service() {
    local url=$1
    local service_name=$2
    local timeout=$3
    
    echo -e "${YELLOW}⏳ Waiting for $service_name to be ready...${NC}"
    
    for i in $(seq 1 $timeout); do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service_name is ready${NC}"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}❌ $service_name failed to start within ${timeout}s${NC}"
    return 1
}

# Function to cleanup
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up test containers...${NC}"
    $CONTAINER_ENGINE stop test-app-ubuntu test-app-alpine test-compose-stack 2>/dev/null || true
    $CONTAINER_ENGINE rm test-app-ubuntu test-app-alpine test-compose-stack 2>/dev/null || true
    $CONTAINER_ENGINE-compose -f ../05-docker-compose-db/docker-compose.yml down -v 2>/dev/null || true
}

# Trap to cleanup on exit
trap cleanup EXIT

echo -e "${BLUE}📋 Module 00: Prerequisites Test${NC}"
echo -e "${YELLOW}Testing required tools...${NC}"

# Test Java
java -version 2>&1 | grep -q "17\." && print_status "Java 17 found" || (echo -e "${RED}❌ Java 17 not found${NC}" && exit 1)

# Test Maven
mvn -version 2>&1 | grep -q "Apache Maven" && print_status "Maven found" || (echo -e "${RED}❌ Maven not found${NC}" && exit 1)

# Test Container Engine
$CONTAINER_ENGINE --version > /dev/null && print_status "$CONTAINER_ENGINE found" || (echo -e "${RED}❌ $CONTAINER_ENGINE not found${NC}" && exit 1)

# Test Container Engine daemon
$CONTAINER_ENGINE info > /dev/null 2>&1 && print_status "$CONTAINER_ENGINE daemon running" || (echo -e "${RED}❌ $CONTAINER_ENGINE daemon not running${NC}" && exit 1)

echo ""

echo -e "${BLUE}📋 Module 01: Java Application Test${NC}"
cd ../01-java-in-eclipse
echo -e "${YELLOW}Building Spring Boot application...${NC}"
mvn clean package -DskipTests -q
print_status "Spring Boot JAR built"

echo ""

echo -e "${BLUE}📋 Module 02: Docker Build Test${NC}"
cd ../02-dockerfile-basics

echo -e "${YELLOW}Building Ubuntu-based image...${NC}"
$CONTAINER_ENGINE build -t test-app:ubuntu . > /dev/null
print_status "Ubuntu image built"

echo -e "${YELLOW}Building Alpine-based image...${NC}"
$CONTAINER_ENGINE build -f Dockerfile.alpine -t test-app:alpine . > /dev/null
print_status "Alpine image built"

echo -e "${YELLOW}Testing Ubuntu container...${NC}"
$CONTAINER_ENGINE run -d -p 8080:8080 --name test-app-ubuntu test-app:ubuntu > /dev/null
wait_for_service "http://localhost:8080/actuator/health" "Ubuntu app" $TIMEOUT
curl -sf http://localhost:8080/api/tasks > /dev/null
print_status "Ubuntu container working"

echo -e "${YELLOW}Testing Alpine container...${NC}"
$CONTAINER_ENGINE stop test-app-ubuntu > /dev/null
$CONTAINER_ENGINE run -d -p 8080:8080 --name test-app-alpine test-app:alpine > /dev/null
wait_for_service "http://localhost:8080/actuator/health" "Alpine app" $TIMEOUT
curl -sf http://localhost:8080/api/tasks > /dev/null
print_status "Alpine container working"

$CONTAINER_ENGINE stop test-app-alpine > /dev/null

echo ""

echo -e "${BLUE}📋 Module 04: Multi-stage Build Test${NC}"
if [ -f "../04-multistage-builds/Dockerfile" ]; then
    cd ../04-multistage-builds
    echo -e "${YELLOW}Testing multi-stage build...${NC}"
    $CONTAINER_ENGINE build -t test-app:multistage . > /dev/null
    print_status "Multi-stage build completed"
    
    # Compare image sizes
    ubuntu_size=$($CONTAINER_ENGINE images test-app:ubuntu --format "{{.Size}}")
    multistage_size=$($CONTAINER_ENGINE images test-app:multistage --format "{{.Size}}")
    echo -e "${GREEN}📊 Ubuntu image: $ubuntu_size, Multi-stage: $multistage_size${NC}"
else
    echo -e "${YELLOW}⏭️  Module 04 not found, skipping...${NC}"
fi

echo ""

echo -e "${BLUE}📋 Module 05: Docker Compose Test${NC}"
if [ -f "../05-docker-compose-db/docker-compose.yml" ]; then
    cd ../05-docker-compose-db
    echo -e "${YELLOW}Testing Docker Compose stack...${NC}"
    
    # Use docker-compose for Docker, podman-compose for Podman
    if [ "$CONTAINER_ENGINE" = "podman" ]; then
        if command -v podman-compose &> /dev/null; then
            COMPOSE_CMD="podman-compose"
        else
            echo -e "${YELLOW}⚠️  podman-compose not found, skipping compose test${NC}"
            COMPOSE_CMD=""
        fi
    else
        COMPOSE_CMD="docker-compose"
    fi
    
    if [ -n "$COMPOSE_CMD" ]; then
        $COMPOSE_CMD up -d > /dev/null 2>&1
        wait_for_service "http://localhost:8080/actuator/health" "Compose app" $TIMEOUT
        curl -sf http://localhost:8080/api/tasks > /dev/null
        print_status "Docker Compose stack working"
        $COMPOSE_CMD down -v > /dev/null 2>&1
    fi
else
    echo -e "${YELLOW}⏭️  Module 05 not found, skipping...${NC}"
fi

echo ""

echo -e "${BLUE}📋 Security Test${NC}"
echo -e "${YELLOW}Testing non-root user in containers...${NC}"
ubuntu_user=$($CONTAINER_ENGINE run --rm test-app:ubuntu whoami)
alpine_user=$($CONTAINER_ENGINE run --rm test-app:alpine whoami)

if [ "$ubuntu_user" != "root" ]; then
    print_status "Ubuntu container runs as non-root ($ubuntu_user)"
else
    echo -e "${RED}❌ Ubuntu container runs as root${NC}"
    exit 1
fi

if [ "$alpine_user" != "root" ]; then
    print_status "Alpine container runs as non-root ($alpine_user)"
else
    echo -e "${RED}❌ Alpine container runs as root${NC}"
    exit 1
fi

echo ""

echo -e "${BLUE}📋 Performance Test${NC}"
echo -e "${YELLOW}Testing container startup times...${NC}"

# Test startup time
start_time=$(date +%s)
$CONTAINER_ENGINE run --rm test-app:ubuntu echo "Container started" > /dev/null
end_time=$(date +%s)
startup_time=$((end_time - start_time))

if [ $startup_time -lt 10 ]; then
    print_status "Container startup time: ${startup_time}s (Good)"
else
    echo -e "${YELLOW}⚠️  Container startup time: ${startup_time}s (Could be improved)${NC}"
fi

echo ""

echo -e "${BLUE}📋 Image Analysis${NC}"
echo -e "${YELLOW}Analyzing image properties...${NC}"

# Check image sizes
echo -e "${GREEN}📊 Image Sizes:${NC}"
$CONTAINER_ENGINE images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep test-app || true

# Check for security vulnerabilities (if available)
if $CONTAINER_ENGINE scan --version > /dev/null 2>&1; then
    echo -e "${YELLOW}Running security scan...${NC}"
    $CONTAINER_ENGINE scan test-app:ubuntu > /dev/null 2>&1 && print_status "Security scan completed" || echo -e "${YELLOW}⚠️  Security scan had warnings${NC}"
fi

echo ""

echo -e "${GREEN}🎉 All Tests Completed Successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Test Summary:${NC}"
echo -e "✅ Prerequisites validated"
echo -e "✅ Java application builds"
echo -e "✅ Docker images build successfully"
echo -e "✅ Containers run and respond"
echo -e "✅ Security: Non-root users"
echo -e "✅ Performance: Reasonable startup times"
echo ""
echo -e "${GREEN}🚀 Your Java Docker environment is ready for learning!${NC}"

# Cleanup
cleanup
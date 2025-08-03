#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Docker Demo Build Script${NC}"
echo ""

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 successful${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
        exit 1
    fi
}

# Build JAR
echo -e "${BLUE}📦 Building Spring Boot JAR...${NC}"
mvn clean package -DskipTests
check_status "Maven build"
echo ""

# Build Ubuntu-based image
echo -e "${BLUE}🐳 Building Ubuntu-based Docker image...${NC}"
docker build -t docker-demo:ubuntu .
check_status "Ubuntu image build"
echo ""

# Build Alpine-based image
echo -e "${BLUE}🏔️  Building Alpine-based Docker image...${NC}"
docker build -f Dockerfile.alpine -t docker-demo:alpine .
check_status "Alpine image build"
echo ""

# Show image sizes
echo -e "${BLUE}📊 Image sizes:${NC}"
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(REPOSITORY|docker-demo)"
echo ""

# Stop any running containers
echo -e "${BLUE}🛑 Stopping existing containers...${NC}"
docker stop demo-ubuntu demo-alpine 2>/dev/null || true
docker rm demo-ubuntu demo-alpine 2>/dev/null || true
echo ""

# Run containers
echo -e "${BLUE}▶️  Starting containers...${NC}"
docker run -d -p 8080:8080 --name demo-ubuntu docker-demo:ubuntu
check_status "Ubuntu container start"

docker run -d -p 8081:8080 --name demo-alpine docker-demo:alpine
check_status "Alpine container start"
echo ""

# Wait for applications to start
echo -e "${BLUE}⏳ Waiting for applications to start...${NC}"
sleep 5

# Test endpoints
echo -e "${BLUE}🧪 Testing endpoints...${NC}"
echo -e "Ubuntu (port 8080):"
curl -s http://localhost:8080/ | jq '.message' || echo "Failed to connect"
echo ""
echo -e "Alpine (port 8081):"
curl -s http://localhost:8081/ | jq '.message' || echo "Failed to connect"
echo ""

# Show container status
echo -e "${BLUE}📋 Container status:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|demo-)"
echo ""

echo -e "${GREEN}✅ Build and deployment complete!${NC}"
echo ""
echo "Next steps:"
echo "- View Ubuntu logs: docker logs -f demo-ubuntu"
echo "- View Alpine logs: docker logs -f demo-alpine"
echo "- Stop containers: docker stop demo-ubuntu demo-alpine"
echo "- Remove containers: docker rm demo-ubuntu demo-alpine"
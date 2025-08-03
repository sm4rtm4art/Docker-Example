#!/bin/bash

# Multi-stage Build Comparison Script
# This script demonstrates the differences between various build approaches

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️ Multi-stage Build Demonstration${NC}"
echo -e "${BLUE}This script will build and compare different Docker optimization strategies${NC}"
echo ""

# Check if JAR exists
if [ ! -f "target/docker-demo-0.0.1-SNAPSHOT.jar" ]; then
    echo -e "${YELLOW}📦 Building Spring Boot JAR first...${NC}"
    mvn clean package -DskipTests -q
    echo -e "${GREEN}✅ JAR built successfully${NC}"
    echo ""
fi

# Function to build with timing
build_with_timing() {
    local dockerfile=$1
    local tag=$2
    local description=$3
    
    echo -e "${BLUE}Building $description...${NC}"
    start_time=$(date +%s)
    
    if docker build -f "$dockerfile" -t "$tag" . > /dev/null 2>&1; then
        end_time=$(date +%s)
        build_time=$((end_time - start_time))
        echo -e "${GREEN}✅ Built $tag in ${build_time}s${NC}"
    else
        echo -e "${RED}❌ Failed to build $tag${NC}"
        return 1
    fi
}

# Function to get image size
get_image_size() {
    docker images --format "{{.Size}}" "$1" 2>/dev/null
}

# Build all versions
echo -e "${BLUE}📋 Building all Docker image variants...${NC}"
echo ""

# Build single-stage (the bad example)
build_with_timing "Dockerfile.single-stage" "demo:single" "Single-stage (Traditional)"

# Build multi-stage 
build_with_timing "Dockerfile.multistage" "demo:multi" "Multi-stage (Optimized)"

# Build layered
build_with_timing "Dockerfile.layered" "demo:layered" "Layered JAR (Advanced)"

# Build distroless
build_with_timing "Dockerfile.distroless" "demo:distroless" "Distroless (Ultra-secure)"

echo ""
echo -e "${BLUE}📊 Image Size Comparison:${NC}"
echo ""

# Display comparison table
printf "%-20s %-12s %-15s %s\n" "APPROACH" "SIZE" "SECURITY" "NOTES"
printf "%-20s %-12s %-15s %s\n" "--------" "----" "--------" "-----"

single_size=$(get_image_size "demo:single")
multi_size=$(get_image_size "demo:multi")
layered_size=$(get_image_size "demo:layered")
distroless_size=$(get_image_size "demo:distroless")

printf "%-20s %-12s %-15s %s\n" "Single-stage" "$single_size" "Poor" "❌ Contains build tools"
printf "%-20s %-12s %-15s %s\n" "Multi-stage" "$multi_size" "Good" "✅ Separated build/runtime"
printf "%-20s %-12s %-15s %s\n" "Layered" "$layered_size" "Good" "🚀 Optimal caching"
printf "%-20s %-12s %-15s %s\n" "Distroless" "$distroless_size" "Excellent" "🔒 No shell/packages"

echo ""

# Test functionality
echo -e "${BLUE}🧪 Testing image functionality...${NC}"
echo ""

# Test multi-stage image
echo -e "${YELLOW}Testing multi-stage image...${NC}"
container_id=$(docker run -d -p 8080:8080 demo:multi)
sleep 8

if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Multi-stage image working correctly${NC}"
else
    echo -e "${RED}❌ Multi-stage image not responding${NC}"
fi

docker stop "$container_id" > /dev/null 2>&1
docker rm "$container_id" > /dev/null 2>&1

# Test distroless image
echo -e "${YELLOW}Testing distroless image...${NC}"
container_id=$(docker run -d -p 8081:8080 demo:distroless)
sleep 8

if curl -sf http://localhost:8081/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Distroless image working correctly${NC}"
else
    echo -e "${RED}❌ Distroless image not responding${NC}"
fi

docker stop "$container_id" > /dev/null 2>&1
docker rm "$container_id" > /dev/null 2>&1

echo ""

# Security comparison
echo -e "${BLUE}🔒 Security Analysis:${NC}"
echo ""

echo -e "${YELLOW}Checking for build tools in images...${NC}"

echo -n "Single-stage has Maven: "
if docker run --rm demo:single which mvn > /dev/null 2>&1; then
    echo -e "${RED}YES (Security Risk!)${NC}"
else
    echo -e "${GREEN}NO${NC}"
fi

echo -n "Multi-stage has Maven: "
if docker run --rm demo:multi which mvn > /dev/null 2>&1; then
    echo -e "${RED}YES (Security Risk!)${NC}"
else
    echo -e "${GREEN}NO (Good!)${NC}"
fi

echo -n "Distroless has shell: "
if docker run --rm demo:distroless /bin/sh -c "echo test" > /dev/null 2>&1; then
    echo -e "${RED}YES${NC}"
else
    echo -e "${GREEN}NO (Maximum Security!)${NC}"
fi

echo ""

# Layer analysis
echo -e "${BLUE}📋 Layer Analysis:${NC}"
echo ""

echo -e "${YELLOW}Multi-stage layers:${NC}"
docker history demo:multi --format "table {{.CreatedBy}}\t{{.Size}}" | head -5

echo ""
echo -e "${YELLOW}Distroless layers:${NC}"
docker history demo:distroless --format "table {{.CreatedBy}}\t{{.Size}}" | head -5

echo ""

# Recommendations
echo -e "${BLUE}💡 Recommendations:${NC}"
echo ""
echo -e "${GREEN}✅ For Development:${NC} Use multi-stage with health checks"
echo -e "${GREEN}✅ For Production:${NC} Use layered for fast updates"
echo -e "${GREEN}✅ For High Security:${NC} Use distroless with external monitoring"
echo -e "${GREEN}✅ For CI/CD:${NC} Use layer-optimized for build speed"

echo ""
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo "1. Try rebuilding after making a small code change to see caching in action"
echo "2. Experiment with different base images"
echo "3. Measure actual performance differences in your environment"
echo "4. Consider your security requirements when choosing approach"

echo ""
echo -e "${GREEN}✨ Multi-stage build demonstration complete!${NC}"

# Cleanup option
echo ""
read -p "Clean up all demo images? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🧹 Cleaning up demo images...${NC}"
    docker rmi demo:single demo:multi demo:layered demo:distroless > /dev/null 2>&1 || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
fi
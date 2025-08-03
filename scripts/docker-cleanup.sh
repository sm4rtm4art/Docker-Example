#!/bin/bash
# Docker Cleanup Script - Removes orphan containers, unused volumes, and networks
# Use with caution in production!

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Cleanup Script${NC}"
echo "======================"

# Function to check if docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Docker is not running or not installed${NC}"
        exit 1
    fi
}

# Function to show current usage
show_usage() {
    echo -e "\n${YELLOW}Current Docker Usage:${NC}"
    docker system df
}

# Function to clean orphan containers
clean_orphans() {
    echo -e "\n${YELLOW}Cleaning orphan containers...${NC}"
    
    # Show exited containers
    EXITED_CONTAINERS=$(docker ps -a -q --filter "status=exited")
    if [ -n "$EXITED_CONTAINERS" ]; then
        echo "Found exited containers:"
        docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"
        
        read -p "Remove these containers? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rm $EXITED_CONTAINERS
            echo -e "${GREEN}Removed exited containers${NC}"
        fi
    else
        echo "No exited containers found"
    fi
}

# Function to clean unused volumes
clean_volumes() {
    echo -e "\n${YELLOW}Cleaning unused volumes...${NC}"
    
    UNUSED_VOLUMES=$(docker volume ls -q --filter "dangling=true")
    if [ -n "$UNUSED_VOLUMES" ]; then
        echo "Found unused volumes:"
        docker volume ls --filter "dangling=true"
        
        read -p "Remove these volumes? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker volume prune -f
            echo -e "${GREEN}Removed unused volumes${NC}"
        fi
    else
        echo "No unused volumes found"
    fi
}

# Function to clean unused networks
clean_networks() {
    echo -e "\n${YELLOW}Cleaning unused networks...${NC}"
    
    # Get custom networks (not default ones)
    UNUSED_NETWORKS=$(docker network ls -q --filter "driver=bridge" | while read net; do
        if [ "$(docker network inspect $net -f '{{len .Containers}}')" == "0" ] && 
           [ "$(docker network inspect $net -f '{{.Name}}')" != "bridge" ] &&
           [ "$(docker network inspect $net -f '{{.Name}}')" != "host" ] &&
           [ "$(docker network inspect $net -f '{{.Name}}')" != "none" ]; then
            echo $net
        fi
    done)
    
    if [ -n "$UNUSED_NETWORKS" ]; then
        echo "Found unused networks:"
        echo "$UNUSED_NETWORKS" | while read net; do
            docker network inspect $net -f '{{.Name}}'
        done
        
        read -p "Remove these networks? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker network prune -f
            echo -e "${GREEN}Removed unused networks${NC}"
        fi
    else
        echo "No unused networks found"
    fi
}

# Function to clean docker-compose orphans
clean_compose_orphans() {
    echo -e "\n${YELLOW}Cleaning docker-compose orphans...${NC}"
    
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        read -p "Remove orphan containers for this docker-compose project? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down --remove-orphans
            echo -e "${GREEN}Removed docker-compose orphans${NC}"
        fi
    else
        echo "No docker-compose file found in current directory"
    fi
}

# Function for aggressive cleanup
aggressive_cleanup() {
    echo -e "\n${RED}WARNING: Aggressive cleanup will remove:${NC}"
    echo "- All stopped containers"
    echo "- All unused images"
    echo "- All unused volumes"
    echo "- All unused networks"
    echo "- All build cache"
    
    read -p "Are you SURE you want to proceed? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -a --volumes -f
        echo -e "${GREEN}Aggressive cleanup completed${NC}"
    fi
}

# Main menu
main() {
    check_docker
    
    echo -e "\nWhat would you like to clean?"
    echo "1) Orphan containers only"
    echo "2) Unused volumes only"
    echo "3) Unused networks only"
    echo "4) Docker-compose orphans"
    echo "5) Standard cleanup (containers, volumes, networks)"
    echo "6) AGGRESSIVE cleanup (removes everything unused)"
    echo "7) Show current usage only"
    echo "0) Exit"
    
    read -p "Select option: " choice
    
    case $choice in
        1) clean_orphans ;;
        2) clean_volumes ;;
        3) clean_networks ;;
        4) clean_compose_orphans ;;
        5) 
            clean_orphans
            clean_volumes
            clean_networks
            ;;
        6) aggressive_cleanup ;;
        7) show_usage ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    echo -e "\n${YELLOW}Final Docker Usage:${NC}"
    docker system df
}

# Run main function
main

# For automated cleanup (non-interactive), you can use:
# docker system prune -f
# docker volume prune -f
# docker network prune -f
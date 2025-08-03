#!/bin/bash
# Example Learning Module Script - Using Utilities
# =============================================================================
# Demonstrates how to use the utility functions in educational scripts

# Source utilities (this pattern works from any module directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# Module-Specific Functions
# =============================================================================
setup_learning_environment() {
    log_step 1 "Setting up learning environment"

    # Check prerequisites
    log_substep "Checking Docker installation"
    if ! check_docker; then
        log_error "Docker is required for this module"
        exit 1
    fi

    # Check port availability
    log_substep "Checking port availability"
    if ! check_port_available 8080; then
        log_warning "Port 8080 is in use"

        if interactive_choice "What would you like to do?" \
           "Use a different port (8081)" \
           "Stop the service using port 8080" \
           "Exit and fix manually"; then
            case $? in
                0) export APP_PORT=8081 ;;
                1)
                    log_info "Please stop the service using port 8080 and try again"
                    exit 1
                    ;;
                2) exit 0 ;;
            esac
        fi
    else
        export APP_PORT=8080
    fi

    log_success "Environment ready - using port $APP_PORT"
}

build_example_image() {
    log_step 2 "Building example Docker image"

    show_command_explanation \
        "docker build -t learning-example ." \
        "Build an image tagged 'learning-example' from current directory"

    if docker build -t learning-example .; then
        log_success "Image built successfully"
    else
        log_error "Failed to build image"
        return 1
    fi

    show_learning_tip "Docker builds images in layers. Each instruction in the Dockerfile creates a new layer. Layers are cached, so rebuilds are faster when only later instructions change."
}

run_example_container() {
    log_step 3 "Running example container"

    show_command_explanation \
        "docker run -d -p $APP_PORT:8080 --name learning-app learning-example" \
        "Run container in background (-d) with port mapping and a friendly name"

    if docker run -d -p "$APP_PORT:8080" --name learning-app learning-example; then
        log_success "Container started successfully"
    else
        log_error "Failed to start container"
        return 1
    fi

    # Wait for application to be ready
    if wait_for_url "http://localhost:$APP_PORT/health" 30; then
        log_success "Application is ready!"

        show_learning_tip "Always implement health checks in your applications. This makes it easier to know when your container is ready to serve traffic."
    else
        log_error "Application failed to start properly"
        log_info "Checking container logs..."
        docker logs learning-app
        return 1
    fi
}

demonstrate_docker_concepts() {
    log_step 4 "Demonstrating Docker concepts"

    log_substep "Container inspection"
    show_command_explanation \
        "docker inspect learning-app" \
        "Show detailed information about the container"

    pause_for_learning "Press Enter to see container details..."
    docker inspect learning-app | head -20

    log_substep "Container logs"
    show_command_explanation \
        "docker logs learning-app" \
        "Show application logs from the container"

    pause_for_learning "Press Enter to see application logs..."
    docker logs learning-app

    log_substep "Container processes"
    show_command_explanation \
        "docker exec learning-app ps aux" \
        "Show running processes inside the container"

    pause_for_learning "Press Enter to see container processes..."
    docker exec learning-app ps aux

    show_learning_tip "Containers share the host kernel but have isolated process spaces. The processes you see here are running in the container's namespace."
}

interactive_exploration() {
    log_step 5 "Interactive exploration"

    echo -e "\n${YELLOW}Time for hands-on exploration!${NC}"
    echo "You can now:"
    echo -e "  ${GREEN}•${NC} Visit http://localhost:$APP_PORT in your browser"
    echo -e "  ${GREEN}•${NC} Execute commands in the container: ${CYAN}docker exec -it learning-app sh${NC}"
    echo -e "  ${GREEN}•${NC} View real-time logs: ${CYAN}docker logs -f learning-app${NC}"
    echo -e "  ${GREEN}•${NC} Monitor resource usage: ${CYAN}docker stats learning-app${NC}"

    pause_for_learning "Explore the application, then press Enter to continue..."
}

cleanup_demo() {
    log_step 6 "Cleaning up"

    log_substep "Stopping container"
    if docker stop learning-app; then
        log_success "Container stopped"
    fi

    log_substep "Removing container"
    if docker rm learning-app; then
        log_success "Container removed"
    fi

    echo -ne "\n${YELLOW}Remove the example image too? (y/N): ${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_substep "Removing image"
        if docker rmi learning-example; then
            log_success "Image removed"
        fi
    fi

    show_learning_tip "In development, you'll often keep images but remove containers. In production, you'll typically use orchestration tools to manage the lifecycle."
}

# =============================================================================
# Main Module Flow
# =============================================================================
main() {
    # Module introduction
    echo -e "\n${DOCKER_EMOJI} ${BOLD}Docker Learning Module: Container Basics${NC}"
    echo -e "${BLUE}This module demonstrates Docker fundamentals through hands-on practice${NC}"

    # Estimated time
    log_info "Estimated time: 15-20 minutes"

    pause_for_learning "Ready to start? Press Enter to begin..."

    # Execute learning steps
    setup_learning_environment
    build_example_image
    run_example_container
    demonstrate_docker_concepts
    interactive_exploration
    cleanup_demo

    # Module completion
    log_success "Module completed successfully!"

    echo -e "\n${GREEN}${BOLD}What you learned:${NC}"
    echo -e "  ${GREEN}•${NC} How to build Docker images"
    echo -e "  ${GREEN}•${NC} How to run containers with port mapping"
    echo -e "  ${GREEN}•${NC} How to inspect running containers"
    echo -e "  ${GREEN}•${NC} How to view logs and execute commands"
    echo -e "  ${GREEN}•${NC} How to clean up resources"

    show_learning_tip "Practice these commands with your own applications. The best way to learn Docker is by using it regularly!"

    # Mark module as complete
    # mark_module_complete "$(dirname "$0")"
}

# Handle help and version flags
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac

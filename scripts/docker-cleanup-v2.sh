#!/bin/bash
# Docker Cleanup Script - Enhanced Version Using Utilities
# =============================================================================
# Clean, organized cleanup using our utility functions

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# Main Cleanup Functions
# =============================================================================
cleanup_orphans() {
    log_step 1 "Cleaning orphan containers"

    # Show what we're about to clean
    local exited_containers
    exited_containers=$(docker ps -a -q --filter "status=exited" 2>/dev/null || true)

    if [[ -n "$exited_containers" ]]; then
        log_info "Found stopped containers:"
        docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"

        echo -ne "\n${YELLOW}Remove these containers? (y/N): ${NC}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            docker_cleanup_containers
        else
            log_info "Skipped container cleanup"
        fi
    else
        log_success "No stopped containers found"
    fi
}

cleanup_volumes() {
    log_step 2 "Cleaning unused volumes"

    local unused_volumes
    unused_volumes=$(docker volume ls -q --filter "dangling=true" 2>/dev/null || true)

    if [[ -n "$unused_volumes" ]]; then
        log_info "Found unused volumes:"
        docker volume ls --filter "dangling=true"

        echo -ne "\n${YELLOW}Remove these volumes? (y/N): ${NC}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            docker_cleanup_volumes
        else
            log_info "Skipped volume cleanup"
        fi
    else
        log_success "No unused volumes found"
    fi
}

cleanup_networks() {
    log_step 3 "Cleaning unused networks"

    echo -ne "\n${YELLOW}Clean unused networks? (y/N): ${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        docker_cleanup_networks
    else
        log_info "Skipped network cleanup"
    fi
}

cleanup_images() {
    log_step 4 "Cleaning unused images"

    echo -ne "\n${YELLOW}Remove unused images? (y/N): ${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        docker_cleanup_images
    else
        log_info "Skipped image cleanup"
    fi
}

show_usage() {
    log_info "Current Docker disk usage:"
    docker system df
}

aggressive_cleanup() {
    log_warning "AGGRESSIVE CLEANUP will remove:"
    echo "  • All stopped containers"
    echo "  • All unused images"
    echo "  • All unused volumes"
    echo "  • All unused networks"
    echo "  • All build cache"

    echo -ne "\n${RED}Are you ABSOLUTELY SURE? (type 'YES' to confirm): ${NC}"
    read -r confirmation

    if [[ "$confirmation" == "YES" ]]; then
        log_info "Performing aggressive cleanup..."
        docker system prune -a --volumes -f
        log_success "Aggressive cleanup completed"
    else
        log_info "Cancelled aggressive cleanup"
    fi
}

# =============================================================================
# Interactive Menu
# =============================================================================
show_menu() {
    echo -e "\n${BLUE}${BOLD}Docker Cleanup Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Clean stopped containers only"
    echo -e "  ${GREEN}2)${NC} Clean unused volumes only"
    echo -e "  ${GREEN}3)${NC} Clean unused networks only"
    echo -e "  ${GREEN}4)${NC} Clean unused images only"
    echo -e "  ${GREEN}5)${NC} Standard cleanup (containers + volumes + networks)"
    echo -e "  ${GREEN}6)${NC} Full cleanup (+ unused images)"
    echo -e "  ${RED}7)${NC} AGGRESSIVE cleanup (everything unused)"
    echo -e "  ${BLUE}8)${NC} Show disk usage only"
    echo -e "  ${BLUE}9)${NC} Help"
    echo -e "  ${GRAY}0)${NC} Exit"
}

run_interactive() {
    while true; do
        show_menu
        echo -ne "\n${YELLOW}Select option: ${NC}"
        read -r choice

        case $choice in
            1) cleanup_orphans ;;
            2) cleanup_volumes ;;
            3) cleanup_networks ;;
            4) cleanup_images ;;
            5)
                cleanup_orphans
                cleanup_volumes
                cleanup_networks
                ;;
            6)
                cleanup_orphans
                cleanup_volumes
                cleanup_networks
                cleanup_images
                ;;
            7) aggressive_cleanup ;;
            8) show_usage ;;
            9) show_help ;;
            0)
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option: $choice"
                ;;
        esac

        echo -e "\n${CYAN}Final disk usage:${NC}"
        docker system df

        pause_for_learning "Press Enter to return to menu..."
    done
}

# =============================================================================
# Help and Usage
# =============================================================================
show_help() {
    show_version
    echo -e "\nUsage: $0 [OPTIONS]"
    echo -e "\nOptions:"
    echo -e "  -i, --interactive    Interactive menu (default)"
    echo -e "  -c, --containers     Clean containers only"
    echo -e "  -v, --volumes        Clean volumes only"
    echo -e "  -n, --networks       Clean networks only"
    echo -e "  -I, --images         Clean images only"
    echo -e "  -s, --standard       Standard cleanup (containers, volumes, networks)"
    echo -e "  -f, --full           Full cleanup (+ images)"
    echo -e "  -a, --aggressive     Aggressive cleanup (everything)"
    echo -e "  -u, --usage          Show disk usage only"
    echo -e "  -h, --help           Show this help"
    echo -e "\nExamples:"
    echo -e "  $0                   # Interactive mode"
    echo -e "  $0 --standard        # Quick standard cleanup"
    echo -e "  $0 --usage           # Check disk usage"
}

show_version() {
    echo -e "${DOCKER_EMOJI} Docker Cleanup Tool v2.0"
    echo -e "Enhanced with cross-platform utilities"
}

# =============================================================================
# Main Execution
# =============================================================================
main() {
    # Check prerequisites
    if ! check_docker; then
        exit 1
    fi

    log_info "Docker cleanup tool started"

    # Show current usage
    show_usage

    # Parse command line arguments
    case "${1:-}" in
        -c|--containers)
            cleanup_orphans
            ;;
        -v|--volumes)
            cleanup_volumes
            ;;
        -n|--networks)
            cleanup_networks
            ;;
        -I|--images)
            cleanup_images
            ;;
        -s|--standard)
            cleanup_orphans
            cleanup_volumes
            cleanup_networks
            ;;
        -f|--full)
            cleanup_orphans
            cleanup_volumes
            cleanup_networks
            cleanup_images
            ;;
        -a|--aggressive)
            aggressive_cleanup
            ;;
        -u|--usage)
            show_usage
            ;;
        -h|--help)
            show_help
            ;;
        ""|--interactive|-i)
            run_interactive
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac

    log_success "Cleanup completed!"
}

# Run main function
main "$@"

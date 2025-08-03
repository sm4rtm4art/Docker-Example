#!/bin/bash
# Docker Learning Path - Utility Functions (Unix/macOS/Linux)
# =============================================================================
# Common functions and colors for all bash scripts

set -euo pipefail

# =============================================================================
# Color Definitions
# =============================================================================
if [[ -t 1 ]]; then  # Only use colors if output is to terminal
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export PURPLE='\033[0;35m'
    export CYAN='\033[0;36m'
    export WHITE='\033[1;37m'
    export BOLD='\033[1m'
    export NC='\033[0m' # No Color
else
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export PURPLE=''
    export CYAN=''
    export WHITE=''
    export BOLD=''
    export NC=''
fi

# =============================================================================
# Docker Learning Path Branding
# =============================================================================
DOCKER_EMOJI="🐳"
SUCCESS_EMOJI="✅"
ERROR_EMOJI="❌"
WARNING_EMOJI="⚠️"
INFO_EMOJI="ℹ️"
ROCKET_EMOJI="🚀"

# =============================================================================
# Logging Functions
# =============================================================================
log_header() {
    echo -e "\n${BLUE}${BOLD}${DOCKER_EMOJI} Docker Learning Path${NC}"
    echo -e "${BLUE}${BOLD}======================${NC}"
}

log_success() {
    echo -e "${GREEN}${SUCCESS_EMOJI} $1${NC}"
}

log_error() {
    echo -e "${RED}${ERROR_EMOJI} $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}${WARNING_EMOJI} $1${NC}"
}

log_info() {
    echo -e "${CYAN}${INFO_EMOJI} $1${NC}"
}

log_step() {
    echo -e "\n${BLUE}${BOLD}Step $1: $2${NC}"
}

log_substep() {
    echo -e "  ${PURPLE}• $1${NC}"
}

log_command() {
    echo -e "  ${YELLOW}$ $1${NC}"
}

# =============================================================================
# Docker Utility Functions
# =============================================================================
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        log_info "Please install Docker Desktop from https://docker.com"
        return 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker is not running"
        log_info "Please start Docker Desktop"
        return 1
    fi

    log_success "Docker is running"
}

check_docker_compose() {
    if docker compose version &> /dev/null; then
        log_success "Docker Compose (V2) is available"
        return 0
    elif docker-compose --version &> /dev/null; then
        log_warning "Using legacy docker-compose (V1)"
        log_info "Consider upgrading to Docker Compose V2"
        return 0
    else
        log_error "Docker Compose is not available"
        return 1
    fi
}

docker_cleanup_containers() {
    local containers
    containers=$(docker ps -aq --filter "status=exited" 2>/dev/null || true)

    if [[ -n "$containers" ]]; then
        log_info "Cleaning up stopped containers..."
        echo "$containers" | xargs docker rm
        log_success "Removed stopped containers"
    else
        log_info "No stopped containers to clean up"
    fi
}

docker_cleanup_images() {
    log_info "Cleaning up unused images..."
    docker image prune -f
    log_success "Cleaned up unused images"
}

docker_cleanup_volumes() {
    log_info "Cleaning up unused volumes..."
    docker volume prune -f
    log_success "Cleaned up unused volumes"
}

docker_cleanup_networks() {
    log_info "Cleaning up unused networks..."
    docker network prune -f
    log_success "Cleaned up unused networks"
}

# =============================================================================
# System Utility Functions
# =============================================================================
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

check_port_available() {
    local port=$1
    if command -v netstat &> /dev/null; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            return 1  # Port is in use
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 1  # Port is in use
        fi
    fi
    return 0  # Port is available
}

wait_for_url() {
    local url=$1
    local timeout=${2:-30}
    local counter=0

    log_info "Waiting for $url to respond..."

    while [[ $counter -lt $timeout ]]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            log_success "$url is responding"
            return 0
        fi

        sleep 1
        ((counter++))

        if [[ $((counter % 5)) -eq 0 ]]; then
            log_info "Still waiting... ($counter/$timeout seconds)"
        fi
    done

    log_error "Timeout waiting for $url"
    return 1
}

# =============================================================================
# Educational Utility Functions
# =============================================================================
pause_for_learning() {
    local message=${1:-"Press Enter to continue..."}
    echo -e "\n${YELLOW}${INFO_EMOJI} $message${NC}"
    read -r
}

show_learning_tip() {
    echo -e "\n${CYAN}${BOLD}💡 Learning Tip:${NC}"
    echo -e "${CYAN}$1${NC}\n"
}

show_command_explanation() {
    local command=$1
    local explanation=$2
    log_command "$command"
    echo -e "  ${CYAN}→ $explanation${NC}"
}

interactive_choice() {
    local prompt=$1
    shift
    local options=("$@")

    echo -e "\n${YELLOW}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo -e "  ${BLUE}$((i + 1)). ${options[i]}${NC}"
    done

    while true; do
        echo -ne "\n${YELLOW}Enter your choice (1-${#options[@]}): ${NC}"
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#options[@]}" ]]; then
            return $((choice - 1))
        else
            log_error "Invalid choice. Please enter a number between 1 and ${#options[@]}"
        fi
    done
}

# =============================================================================
# Module Management Functions
# =============================================================================
get_module_name() {
    local module_dir=$1
    basename "$module_dir" | sed 's/^[0-9][0-9]-//'
}

check_module_completion() {
    local module_dir=$1
    local completion_file="$module_dir/.completed"

    if [[ -f "$completion_file" ]]; then
        log_success "Module $(get_module_name "$module_dir") completed"
        return 0
    else
        log_info "Module $(get_module_name "$module_dir") not yet completed"
        return 1
    fi
}

mark_module_complete() {
    local module_dir=$1
    local completion_file="$module_dir/.completed"

    echo "Completed on $(date)" > "$completion_file"
    log_success "Marked module $(get_module_name "$module_dir") as complete!"
}

# =============================================================================
# Error Handling
# =============================================================================
handle_error() {
    local exit_code=$?
    local line_number=$1

    log_error "An error occurred in script at line $line_number (exit code: $exit_code)"

    if [[ $exit_code -ne 0 ]]; then
        case $exit_code in
            1)
                log_info "General error - check the command that failed"
                ;;
            125)
                log_info "Docker daemon error - is Docker running?"
                ;;
            126)
                log_info "Command not executable - check permissions"
                ;;
            127)
                log_info "Command not found - check if tool is installed"
                ;;
            *)
                log_info "Unexpected error code: $exit_code"
                ;;
        esac
    fi

    exit $exit_code
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# =============================================================================
# Initialization
# =============================================================================
log_header

# =============================================================================
# Version and Help
# =============================================================================
show_version() {
    echo -e "${DOCKER_EMOJI} Docker Learning Path Utilities v1.0"
    echo -e "Cross-platform Docker education toolkit"
}

show_help() {
    show_version
    echo -e "\nCommon functions for Docker learning scripts:"
    echo -e "  ${GREEN}Logging:${NC} log_success, log_error, log_warning, log_info"
    echo -e "  ${GREEN}Docker:${NC} check_docker, docker_cleanup_*, wait_for_url"
    echo -e "  ${GREEN}Learning:${NC} pause_for_learning, show_learning_tip"
    echo -e "  ${GREEN}Interactive:${NC} interactive_choice"
    echo -e "\nSource this file in other scripts: source \"\$(dirname \"\$0\")/utils.sh\""
}

# Only run if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        -h|--help)
            show_help
            ;;
        -v|--version)
            show_version
            ;;
        *)
            log_info "Docker Learning Path utilities loaded"
            log_info "Use --help for usage information"
            ;;
    esac
fi

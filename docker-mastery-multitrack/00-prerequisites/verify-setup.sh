#!/bin/bash
# Multi-Language Docker Learning Path - Setup Verification
# =============================================================================
# Verifies that all required tools are properly installed

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/utils.sh"

# =============================================================================
# Verification Functions
# =============================================================================

verify_core_tools() {
    log_step 1 "Verifying core tools"

    # Docker
    log_substep "Checking Docker installation"
    if check_docker; then
        local docker_version
        docker_version=$(docker --version | cut -d' ' -f3 | tr -d ',')
        log_success "Docker $docker_version is installed and running"
    else
        log_error "Docker is not properly installed or running"
        log_info "Please install Docker Desktop: https://docker.com"
        return 1
    fi

    # Docker Compose
    log_substep "Checking Docker Compose"
    check_docker_compose

    # Git
    log_substep "Checking Git installation"
    if command -v git &> /dev/null; then
        local git_version
        git_version=$(git --version | cut -d' ' -f3)
        log_success "Git $git_version is installed"
    else
        log_error "Git is not installed"
        log_info "Please install Git: https://git-scm.com"
        return 1
    fi

    return 0
}

detect_language_preference() {
    echo -e "\n${BLUE}${BOLD}Language Track Selection${NC}"
    echo -e "Which programming language would you like to use for this learning path?"

    local options=("Java (Spring Boot ecosystem)"
                   "Python (FastAPI with UV)"
                   "Rust (Actix-web)"
                   "I'll decide later")

    interactive_choice "Choose your language track:" "${options[@]}"
    local choice=$?

    case $choice in
        0) echo "java" ;;
        1) echo "python" ;;
        2) echo "rust" ;;
        3) echo "undecided" ;;
    esac
}

verify_java_tools() {
    log_step 2 "Verifying Java development tools"

    # Java JDK
    log_substep "Checking Java JDK"
    if command -v java &> /dev/null && command -v javac &> /dev/null; then
        local java_version
        java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)

        # Check if Java 17+
        local major_version
        major_version=$(echo "$java_version" | cut -d'.' -f1)
        if [[ "$major_version" -ge 17 ]]; then
            log_success "Java $java_version (JDK) is installed"
        else
            log_warning "Java $java_version found, but Java 17+ is recommended"
        fi
    else
        log_error "Java JDK is not installed"
        log_info "Install Java 17+: https://adoptium.net/temurin/releases/?version=17"
        return 1
    fi

    # Maven
    log_substep "Checking Maven"
    if command -v mvn &> /dev/null; then
        local maven_version
        maven_version=$(mvn -version | head -n1 | cut -d' ' -f3)
        log_success "Maven $maven_version is installed"
    else
        log_error "Maven is not installed"
        log_info "Install Maven: https://maven.apache.org/install.html"
        return 1
    fi

    # Test compilation
    log_substep "Testing Java compilation"
    local test_dir="/tmp/java-test-$$"
    mkdir -p "$test_dir"

    cat > "$test_dir/HelloDocker.java" << 'EOF'
public class HelloDocker {
    public static void main(String[] args) {
        System.out.println("Java is ready for Docker learning!");
    }
}
EOF

    if (cd "$test_dir" && javac HelloDocker.java && java HelloDocker); then
        log_success "Java compilation and execution test passed"
    else
        log_error "Java compilation test failed"
        return 1
    fi

    rm -rf "$test_dir"
    return 0
}

verify_python_tools() {
    log_step 2 "Verifying Python development tools"

    # Python
    log_substep "Checking Python installation"
    if command -v python3 &> /dev/null; then
        local python_version
        python_version=$(python3 --version | cut -d' ' -f2)

        # Check if Python 3.11+
        local major minor
        major=$(echo "$python_version" | cut -d'.' -f1)
        minor=$(echo "$python_version" | cut -d'.' -f2)

        if [[ "$major" -eq 3 && "$minor" -ge 11 ]]; then
            log_success "Python $python_version is installed"
        else
            log_warning "Python $python_version found, but Python 3.11+ is recommended"
        fi
    else
        log_error "Python 3 is not installed"
        log_info "Install Python 3.11+: https://python.org"
        return 1
    fi

    # UV package manager
    log_substep "Checking UV package manager"
    if command -v uv &> /dev/null; then
        local uv_version
        uv_version=$(uv --version | cut -d' ' -f2)
        log_success "UV $uv_version is installed"
    else
        log_error "UV package manager is not installed"
        log_info "Install UV: curl -LsSf https://astral.sh/uv/install.sh | sh"
        return 1
    fi

    # Test Python execution
    log_substep "Testing Python execution"
    if python3 -c "print('Python is ready for Docker learning!')"; then
        log_success "Python execution test passed"
    else
        log_error "Python execution test failed"
        return 1
    fi

    return 0
}

verify_rust_tools() {
    log_step 2 "Verifying Rust development tools"

    # Rust compiler
    log_substep "Checking Rust compiler"
    if command -v rustc &> /dev/null; then
        local rust_version
        rust_version=$(rustc --version | cut -d' ' -f2)
        log_success "Rust $rust_version is installed"
    else
        log_error "Rust compiler is not installed"
        log_info "Install Rust: https://rustup.rs/"
        return 1
    fi

    # Cargo package manager
    log_substep "Checking Cargo package manager"
    if command -v cargo &> /dev/null; then
        local cargo_version
        cargo_version=$(cargo --version | cut -d' ' -f2)
        log_success "Cargo $cargo_version is installed"
    else
        log_error "Cargo is not installed (should come with Rust)"
        return 1
    fi

    # Test compilation
    log_substep "Testing Rust compilation"
    local test_dir="/tmp/rust-test-$$"
    mkdir -p "$test_dir"

    cat > "$test_dir/main.rs" << 'EOF'
fn main() {
    println!("Rust is ready for Docker learning!");
}
EOF

    if (cd "$test_dir" && rustc main.rs && ./main); then
        log_success "Rust compilation and execution test passed"
    else
        log_error "Rust compilation test failed"
        return 1
    fi

    rm -rf "$test_dir"
    return 0
}

verify_system_resources() {
    log_step 3 "Checking system resources"

    # Available disk space
    log_substep "Checking disk space"
    local available_space
    if command -v df &> /dev/null; then
        available_space=$(df -h . | awk 'NR==2 {print $4}')
        log_info "Available disk space: $available_space"

        # Check if we have at least 10GB
        local space_gb
        space_gb=$(df . | awk 'NR==2 {print int($4/1024/1024)}')
        if [[ "$space_gb" -ge 10 ]]; then
            log_success "Sufficient disk space available (${space_gb}GB)"
        else
            log_warning "Low disk space (${space_gb}GB). 10GB+ recommended for Docker learning"
        fi
    fi

    # Memory
    log_substep "Checking available memory"
    if command -v free &> /dev/null; then
        local total_mem
        total_mem=$(free -h | awk 'NR==2{print $2}')
        log_info "Total system memory: $total_mem"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        local total_mem
        total_mem=$(system_profiler SPMemoryDataType | grep "Size:" | head -1 | awk '{print $2 $3}')
        log_info "Total system memory: $total_mem"
    fi

    # Docker resources
    log_substep "Checking Docker resource limits"
    if docker system info &> /dev/null; then
        local docker_info
        docker_info=$(docker system info 2>/dev/null)

        if [[ -n "$docker_info" ]]; then
            local cpus memory
            cpus=$(echo "$docker_info" | grep -i "CPUs:" | awk '{print $2}')
            memory=$(echo "$docker_info" | grep -i "Total Memory:" | awk '{print $3 $4}')

            if [[ -n "$cpus" ]]; then
                log_info "Docker CPUs available: $cpus"
            fi
            if [[ -n "$memory" ]]; then
                log_info "Docker memory available: $memory"
            fi
        fi
    fi
}

run_integration_test() {
    log_step 4 "Running integration test"

    log_substep "Testing Docker with a simple container"
    if docker run --rm alpine:latest echo "Docker integration test passed!"; then
        log_success "Docker integration test completed"
    else
        log_error "Docker integration test failed"
        return 1
    fi

    log_substep "Testing Docker image operations"
    if docker images alpine:latest &> /dev/null; then
        log_success "Docker image operations working"
    else
        log_warning "Docker image operations may have issues"
    fi
}

create_completion_marker() {
    local language=$1
    local completion_file="$SCRIPT_DIR/.setup-complete"

    cat > "$completion_file" << EOF
# Setup completion marker
SETUP_DATE=$(date)
LANGUAGE_TRACK=$language
PLATFORM=$(detect_os)
DOCKER_VERSION=$(docker --version 2>/dev/null || echo "Not found")
EOF

    log_success "Setup completion marker created"
}

# =============================================================================
# Main Verification Flow
# =============================================================================
main() {
    # Introduction
    echo -e "\n${DOCKER_EMOJI} ${BOLD}Docker Learning Path - Setup Verification${NC}"
    echo -e "${BLUE}This script will verify that your development environment is ready${NC}"

    pause_for_learning "Press Enter to begin verification..."

    # Core tools verification
    if ! verify_core_tools; then
        log_error "Core tools verification failed"
        log_info "Please install missing tools and run this script again"
        exit 1
    fi

    # Language selection and verification
    local language_choice
    language_choice=$(detect_language_preference)

    case "$language_choice" in
        java)
            if verify_java_tools; then
                log_success "Java track verification completed"
            else
                log_error "Java tools verification failed"
                exit 1
            fi
            ;;
        python)
            if verify_python_tools; then
                log_success "Python track verification completed"
            else
                log_error "Python tools verification failed"
                exit 1
            fi
            ;;
        rust)
            if verify_rust_tools; then
                log_success "Rust track verification completed"
            else
                log_error "Rust tools verification failed"
                exit 1
            fi
            ;;
        undecided)
            log_info "No specific language tools verified"
            log_info "You can run this script again later to verify language-specific tools"
            language_choice="none"
            ;;
    esac

    # System resources
    verify_system_resources

    # Integration test
    if ! run_integration_test; then
        log_error "Integration test failed"
        exit 1
    fi

    # Create completion marker
    create_completion_marker "$language_choice"

    # Success summary
    echo -e "\n${GREEN}${BOLD}🎉 Setup Verification Complete!${NC}"
    echo -e "\n${GREEN}Your development environment is ready for Docker learning!${NC}"

    if [[ "$language_choice" != "none" ]]; then
        echo -e "${GREEN}Language track: ${BOLD}$language_choice${NC}"
    fi

    show_learning_tip "You're now ready to start Module 01: Docker Fundamentals. This module teaches core Docker concepts that apply to all programming languages."

    echo -e "\n${BLUE}Next steps:${NC}"
    echo -e "  1. ${CYAN}cd ../01-docker-fundamentals${NC}"
    echo -e "  2. ${CYAN}Read the README.md file${NC}"
    echo -e "  3. ${CYAN}Complete the hands-on exercises${NC}"

    log_success "Happy learning! 🚀"
}

# Handle command line arguments
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

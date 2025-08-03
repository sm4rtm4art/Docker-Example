#!/bin/bash
# Cross-Platform Docker Cleanup Launcher
# =============================================================================
# Detects platform and runs appropriate cleanup script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Simple OS detection
detect_platform() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unix"  # Default to unix-like
    fi
}

main() {
    local platform
    platform=$(detect_platform)

    echo "🐳 Docker Cleanup Tool"
    echo "Platform detected: $platform"
    echo ""

    case "$platform" in
        windows)
            if command -v pwsh &> /dev/null; then
                echo "Using PowerShell Core..."
                pwsh -File "$SCRIPT_DIR/docker-cleanup.ps1" "$@"
            elif command -v powershell &> /dev/null; then
                echo "Using Windows PowerShell..."
                powershell -File "$SCRIPT_DIR/docker-cleanup.ps1" "$@"
            else
                echo "⚠️  PowerShell not found, falling back to bash..."
                bash "$SCRIPT_DIR/docker-cleanup-v2.sh" "$@"
            fi
            ;;
        *)
            echo "Using bash script..."
            bash "$SCRIPT_DIR/docker-cleanup-v2.sh" "$@"
            ;;
    esac
}

main "$@"

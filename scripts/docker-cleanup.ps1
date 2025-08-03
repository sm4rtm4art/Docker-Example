# Docker Cleanup Script - PowerShell Version
# =============================================================================
# Cross-platform Docker cleanup using PowerShell utilities

#Requires -Version 5.1

param(
    [switch]$Interactive,
    [switch]$Containers,
    [switch]$Volumes,
    [switch]$Networks,
    [switch]$Images,
    [switch]$Standard,
    [switch]$Full,
    [switch]$Aggressive,
    [switch]$Usage,
    [switch]$Help
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils.ps1"

# =============================================================================
# Main Cleanup Functions
# =============================================================================
function Invoke-ContainerCleanup {
    Write-Step 1 "Cleaning orphan containers"

    try {
        $exitedContainers = docker ps -a -q --filter "status=exited" 2>$null

        if ($exitedContainers) {
            Write-Info "Found stopped containers:"
            docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"

            $response = Read-Host "`nRemove these containers? (y/N)"

            if ($response -match '^[Yy]$') {
                Remove-StoppedContainers
            }
            else {
                Write-Info "Skipped container cleanup"
            }
        }
        else {
            Write-Success "No stopped containers found"
        }
    }
    catch {
        Write-Error "Error during container cleanup: $($_.Exception.Message)"
    }
}

function Invoke-VolumeCleanup {
    Write-Step 2 "Cleaning unused volumes"

    try {
        $unusedVolumes = docker volume ls -q --filter "dangling=true" 2>$null

        if ($unusedVolumes) {
            Write-Info "Found unused volumes:"
            docker volume ls --filter "dangling=true"

            $response = Read-Host "`nRemove these volumes? (y/N)"

            if ($response -match '^[Yy]$') {
                Remove-UnusedVolumes
            }
            else {
                Write-Info "Skipped volume cleanup"
            }
        }
        else {
            Write-Success "No unused volumes found"
        }
    }
    catch {
        Write-Error "Error during volume cleanup: $($_.Exception.Message)"
    }
}

function Invoke-NetworkCleanup {
    Write-Step 3 "Cleaning unused networks"

    try {
        $response = Read-Host "`nClean unused networks? (y/N)"

        if ($response -match '^[Yy]$') {
            Remove-UnusedNetworks
        }
        else {
            Write-Info "Skipped network cleanup"
        }
    }
    catch {
        Write-Error "Error during network cleanup: $($_.Exception.Message)"
    }
}

function Invoke-ImageCleanup {
    Write-Step 4 "Cleaning unused images"

    try {
        $response = Read-Host "`nRemove unused images? (y/N)"

        if ($response -match '^[Yy]$') {
            Remove-UnusedImages
        }
        else {
            Write-Info "Skipped image cleanup"
        }
    }
    catch {
        Write-Error "Error during image cleanup: $($_.Exception.Message)"
    }
}

function Show-DockerUsage {
    Write-Info "Current Docker disk usage:"
    docker system df
}

function Invoke-AggressiveCleanup {
    Write-Warning "AGGRESSIVE CLEANUP will remove:"
    Write-Host "  • All stopped containers"
    Write-Host "  • All unused images"
    Write-Host "  • All unused volumes"
    Write-Host "  • All unused networks"
    Write-Host "  • All build cache"

    $confirmation = Read-Host "`nAre you ABSOLUTELY SURE? (type 'YES' to confirm)"

    if ($confirmation -eq "YES") {
        Write-Info "Performing aggressive cleanup..."
        docker system prune -a --volumes -f
        Write-Success "Aggressive cleanup completed"
    }
    else {
        Write-Info "Cancelled aggressive cleanup"
    }
}

# =============================================================================
# Interactive Menu
# =============================================================================
function Show-Menu {
    Write-Host ""
    Write-Host "Docker Cleanup Options:" -ForegroundColor Blue
    Write-Host "  1) Clean stopped containers only" -ForegroundColor Green
    Write-Host "  2) Clean unused volumes only" -ForegroundColor Green
    Write-Host "  3) Clean unused networks only" -ForegroundColor Green
    Write-Host "  4) Clean unused images only" -ForegroundColor Green
    Write-Host "  5) Standard cleanup (containers + volumes + networks)" -ForegroundColor Green
    Write-Host "  6) Full cleanup (+ unused images)" -ForegroundColor Green
    Write-Host "  7) AGGRESSIVE cleanup (everything unused)" -ForegroundColor Red
    Write-Host "  8) Show disk usage only" -ForegroundColor Blue
    Write-Host "  9) Help" -ForegroundColor Blue
    Write-Host "  0) Exit" -ForegroundColor Gray
}

function Start-InteractiveMode {
    while ($true) {
        Show-Menu
        $choice = Read-Host "`nSelect option"

        switch ($choice) {
            1 { Invoke-ContainerCleanup }
            2 { Invoke-VolumeCleanup }
            3 { Invoke-NetworkCleanup }
            4 { Invoke-ImageCleanup }
            5 {
                Invoke-ContainerCleanup
                Invoke-VolumeCleanup
                Invoke-NetworkCleanup
            }
            6 {
                Invoke-ContainerCleanup
                Invoke-VolumeCleanup
                Invoke-NetworkCleanup
                Invoke-ImageCleanup
            }
            7 { Invoke-AggressiveCleanup }
            8 { Show-DockerUsage }
            9 { Show-Help }
            0 {
                Write-Info "Goodbye!"
                return
            }
            default {
                Write-Error "Invalid option: $choice"
            }
        }

        Write-Host ""
        Write-Host "Final disk usage:" -ForegroundColor Cyan
        docker system df

        Wait-ForLearning "Press Enter to return to menu..."
    }
}

# =============================================================================
# Help and Usage
# =============================================================================
function Show-Help {
    Show-Version
    Write-Host ""
    Write-Host "Usage: .\docker-cleanup.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Interactive     Interactive menu (default)"
    Write-Host "  -Containers      Clean containers only"
    Write-Host "  -Volumes         Clean volumes only"
    Write-Host "  -Networks        Clean networks only"
    Write-Host "  -Images          Clean images only"
    Write-Host "  -Standard        Standard cleanup (containers, volumes, networks)"
    Write-Host "  -Full            Full cleanup (+ images)"
    Write-Host "  -Aggressive      Aggressive cleanup (everything)"
    Write-Host "  -Usage           Show disk usage only"
    Write-Host "  -Help            Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\docker-cleanup.ps1              # Interactive mode"
    Write-Host "  .\docker-cleanup.ps1 -Standard    # Quick standard cleanup"
    Write-Host "  .\docker-cleanup.ps1 -Usage       # Check disk usage"
}

function Show-Version {
    Write-Host "$Script:DOCKER_EMOJI Docker Cleanup Tool v2.0 (PowerShell)"
    Write-Host "Cross-platform Docker cleanup utility"
}

# =============================================================================
# Main Execution
# =============================================================================
function Main {
    # Check prerequisites
    if (-not (Test-Docker)) {
        exit 1
    }

    Write-Info "Docker cleanup tool started"

    # Show current usage
    Show-DockerUsage

    # Handle command line arguments
    if ($Containers) {
        Invoke-ContainerCleanup
    }
    elseif ($Volumes) {
        Invoke-VolumeCleanup
    }
    elseif ($Networks) {
        Invoke-NetworkCleanup
    }
    elseif ($Images) {
        Invoke-ImageCleanup
    }
    elseif ($Standard) {
        Invoke-ContainerCleanup
        Invoke-VolumeCleanup
        Invoke-NetworkCleanup
    }
    elseif ($Full) {
        Invoke-ContainerCleanup
        Invoke-VolumeCleanup
        Invoke-NetworkCleanup
        Invoke-ImageCleanup
    }
    elseif ($Aggressive) {
        Invoke-AggressiveCleanup
    }
    elseif ($Usage) {
        Show-DockerUsage
    }
    elseif ($Help) {
        Show-Help
    }
    else {
        # Default to interactive mode
        Start-InteractiveMode
    }

    Write-Success "Cleanup completed!"
}

# Run main function
Main

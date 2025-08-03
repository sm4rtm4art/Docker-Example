# Docker Learning Path - Utility Functions (Windows PowerShell)
# =============================================================================
# Common functions and colors for all PowerShell scripts
# Equivalent to utils.sh for cross-platform compatibility

#Requires -Version 5.1

# =============================================================================
# Error Handling
# =============================================================================
$ErrorActionPreference = "Stop"

# =============================================================================
# Color Definitions
# =============================================================================
if ($Host.UI.RawUI.ForegroundColor) {
    $Script:Colors = @{
        Red     = "Red"
        Green   = "Green"
        Yellow  = "Yellow"
        Blue    = "Blue"
        Magenta = "Magenta"
        Cyan    = "Cyan"
        White   = "White"
        Gray    = "Gray"
    }
} else {
    # Fallback for consoles without color support
    $Script:Colors = @{
        Red     = "White"
        Green   = "White"
        Yellow  = "White"
        Blue    = "White"
        Magenta = "White"
        Cyan    = "White"
        White   = "White"
        Gray    = "White"
    }
}

# =============================================================================
# Docker Learning Path Branding
# =============================================================================
$Script:DOCKER_EMOJI = "🐳"
$Script:SUCCESS_EMOJI = "✅"
$Script:ERROR_EMOJI = "❌"
$Script:WARNING_EMOJI = "⚠️"
$Script:INFO_EMOJI = "ℹ️"
$Script:ROCKET_EMOJI = "🚀"

# =============================================================================
# Logging Functions
# =============================================================================
function Write-Header {
    Write-Host ""
    Write-Host "$Script:DOCKER_EMOJI Docker Learning Path" -ForegroundColor $Script:Colors.Blue
    Write-Host "======================" -ForegroundColor $Script:Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "$Script:SUCCESS_EMOJI $Message" -ForegroundColor $Script:Colors.Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "$Script:ERROR_EMOJI $Message" -ForegroundColor $Script:Colors.Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$Script:WARNING_EMOJI $Message" -ForegroundColor $Script:Colors.Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "$Script:INFO_EMOJI $Message" -ForegroundColor $Script:Colors.Cyan
}

function Write-Step {
    param([int]$StepNumber, [string]$Description)
    Write-Host ""
    Write-Host "Step $StepNumber: $Description" -ForegroundColor $Script:Colors.Blue
}

function Write-SubStep {
    param([string]$Description)
    Write-Host "  • $Description" -ForegroundColor $Script:Colors.Magenta
}

function Write-Command {
    param([string]$Command)
    Write-Host "  PS> $Command" -ForegroundColor $Script:Colors.Yellow
}

# =============================================================================
# Docker Utility Functions
# =============================================================================
function Test-Docker {
    try {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Error "Docker is not installed or not in PATH"
            Write-Info "Please install Docker Desktop from https://docker.com"
            return $false
        }

        $null = docker info 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker is not running"
            Write-Info "Please start Docker Desktop"
            return $false
        }

        Write-Success "Docker is running"
        return $true
    }
    catch {
        Write-Error "Error checking Docker: $($_.Exception.Message)"
        return $false
    }
}

function Test-DockerCompose {
    try {
        $null = docker compose version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker Compose (V2) is available"
            return $true
        }

        $null = docker-compose --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Warning "Using legacy docker-compose (V1)"
            Write-Info "Consider upgrading to Docker Compose V2"
            return $true
        }

        Write-Error "Docker Compose is not available"
        return $false
    }
    catch {
        Write-Error "Error checking Docker Compose: $($_.Exception.Message)"
        return $false
    }
}

function Remove-StoppedContainers {
    try {
        $containers = docker ps -aq --filter "status=exited" 2>$null

        if ($containers) {
            Write-Info "Cleaning up stopped containers..."
            docker rm $containers
            Write-Success "Removed stopped containers"
        }
        else {
            Write-Info "No stopped containers to clean up"
        }
    }
    catch {
        Write-Warning "Could not clean up containers: $($_.Exception.Message)"
    }
}

function Remove-UnusedImages {
    try {
        Write-Info "Cleaning up unused images..."
        docker image prune -f
        Write-Success "Cleaned up unused images"
    }
    catch {
        Write-Warning "Could not clean up images: $($_.Exception.Message)"
    }
}

function Remove-UnusedVolumes {
    try {
        Write-Info "Cleaning up unused volumes..."
        docker volume prune -f
        Write-Success "Cleaned up unused volumes"
    }
    catch {
        Write-Warning "Could not clean up volumes: $($_.Exception.Message)"
    }
}

function Remove-UnusedNetworks {
    try {
        Write-Info "Cleaning up unused networks..."
        docker network prune -f
        Write-Success "Cleaned up unused networks"
    }
    catch {
        Write-Warning "Could not clean up networks: $($_.Exception.Message)"
    }
}

# =============================================================================
# System Utility Functions
# =============================================================================
function Get-OperatingSystem {
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        return "windows"
    }
    elseif ($IsLinux) {
        return "linux"
    }
    elseif ($IsMacOS) {
        return "macos"
    }
    else {
        return "unknown"
    }
}

function Test-PortAvailable {
    param([int]$Port)

    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($connection) {
            return $false  # Port is in use
        }
        return $true  # Port is available
    }
    catch {
        # On older PowerShell or non-Windows, try netstat
        try {
            $netstat = netstat -an | Select-String ":$Port "
            return -not $netstat
        }
        catch {
            Write-Warning "Could not check port $Port availability"
            return $true  # Assume available
        }
    }
}

function Wait-ForUrl {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 30
    )

    Write-Info "Waiting for $Url to respond..."

    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 1 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Success "$Url is responding"
                return $true
            }
        }
        catch {
            # Continue waiting
        }

        Start-Sleep -Seconds 1

        if (($i + 1) % 5 -eq 0) {
            Write-Info "Still waiting... ($($i + 1)/$TimeoutSeconds seconds)"
        }
    }

    Write-Error "Timeout waiting for $Url"
    return $false
}

# =============================================================================
# Educational Utility Functions
# =============================================================================
function Wait-ForLearning {
    param([string]$Message = "Press Enter to continue...")

    Write-Host ""
    Write-Host "$Script:INFO_EMOJI $Message" -ForegroundColor $Script:Colors.Yellow
    Read-Host
}

function Show-LearningTip {
    param([string]$Tip)

    Write-Host ""
    Write-Host "💡 Learning Tip:" -ForegroundColor $Script:Colors.Cyan
    Write-Host "$Tip" -ForegroundColor $Script:Colors.Cyan
    Write-Host ""
}

function Show-CommandExplanation {
    param([string]$Command, [string]$Explanation)

    Write-Command $Command
    Write-Host "  → $Explanation" -ForegroundColor $Script:Colors.Cyan
}

function Get-InteractiveChoice {
    param(
        [string]$Prompt,
        [string[]]$Options
    )

    Write-Host ""
    Write-Host $Prompt -ForegroundColor $Script:Colors.Yellow

    for ($i = 0; $i -lt $Options.Length; $i++) {
        Write-Host "  $($i + 1). $($Options[$i])" -ForegroundColor $Script:Colors.Blue
    }

    do {
        Write-Host ""
        $choice = Read-Host "Enter your choice (1-$($Options.Length))"

        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Length) {
            return ([int]$choice - 1)
        }
        else {
            Write-Error "Invalid choice. Please enter a number between 1 and $($Options.Length)"
        }
    } while ($true)
}

# =============================================================================
# Module Management Functions
# =============================================================================
function Get-ModuleName {
    param([string]$ModuleDir)

    $basename = Split-Path $ModuleDir -Leaf
    return $basename -replace '^[0-9][0-9]-', ''
}

function Test-ModuleCompletion {
    param([string]$ModuleDir)

    $completionFile = Join-Path $ModuleDir ".completed"

    if (Test-Path $completionFile) {
        Write-Success "Module $(Get-ModuleName $ModuleDir) completed"
        return $true
    }
    else {
        Write-Info "Module $(Get-ModuleName $ModuleDir) not yet completed"
        return $false
    }
}

function Set-ModuleComplete {
    param([string]$ModuleDir)

    $completionFile = Join-Path $ModuleDir ".completed"

    "Completed on $(Get-Date)" | Out-File -FilePath $completionFile -Encoding UTF8
    Write-Success "Marked module $(Get-ModuleName $ModuleDir) as complete!"
}

# =============================================================================
# Version and Help
# =============================================================================
function Show-Version {
    Write-Host "$Script:DOCKER_EMOJI Docker Learning Path Utilities v1.0"
    Write-Host "Cross-platform Docker education toolkit (PowerShell)"
}

function Show-Help {
    Show-Version
    Write-Host ""
    Write-Host "Common functions for Docker learning scripts:"
    Write-Host "  Logging: Write-Success, Write-Error, Write-Warning, Write-Info" -ForegroundColor $Script:Colors.Green
    Write-Host "  Docker: Test-Docker, Remove-*, Wait-ForUrl" -ForegroundColor $Script:Colors.Green
    Write-Host "  Learning: Wait-ForLearning, Show-LearningTip" -ForegroundColor $Script:Colors.Green
    Write-Host "  Interactive: Get-InteractiveChoice" -ForegroundColor $Script:Colors.Green
    Write-Host ""
    Write-Host "Import this module: . `"`$(Split-Path `$MyInvocation.MyCommand.Path)/utils.ps1`""
}

# =============================================================================
# Initialization
# =============================================================================
Write-Header

# =============================================================================
# Main execution (only if run directly, not when dot-sourced)
# =============================================================================
if ($MyInvocation.InvocationName -ne ".") {
    param(
        [switch]$Help,
        [switch]$Version
    )

    if ($Help) {
        Show-Help
    }
    elseif ($Version) {
        Show-Version
    }
    else {
        Write-Info "Docker Learning Path utilities loaded"
        Write-Info "Use -Help for usage information"
    }
}

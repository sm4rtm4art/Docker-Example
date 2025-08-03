# Multi-Language Docker Learning Path - Setup Verification (PowerShell)
# =============================================================================
# Verifies that all required tools are properly installed

#Requires -Version 5.1

param(
    [switch]$Help,
    [switch]$Version
)

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\..\scripts\utils.ps1"

# =============================================================================
# Verification Functions
# =============================================================================

function Test-CoreTools {
    Write-Step 1 "Verifying core tools"

    # Docker
    Write-SubStep "Checking Docker installation"
    if (Test-Docker) {
        try {
            $dockerVersion = (docker --version).Split(' ')[2].TrimEnd(',')
            Write-Success "Docker $dockerVersion is installed and running"
        }
        catch {
            Write-Warning "Could not determine Docker version"
        }
    }
    else {
        Write-Error "Docker is not properly installed or running"
        Write-Info "Please install Docker Desktop: https://docker.com"
        return $false
    }

    # Docker Compose
    Write-SubStep "Checking Docker Compose"
    Test-DockerCompose | Out-Null

    # Git
    Write-SubStep "Checking Git installation"
    try {
        $gitVersion = (git --version).Split(' ')[2]
        Write-Success "Git $gitVersion is installed"
    }
    catch {
        Write-Error "Git is not installed"
        Write-Info "Please install Git: https://git-scm.com"
        return $false
    }

    return $true
}

function Get-LanguagePreference {
    Write-Host ""
    Write-Host "Language Track Selection" -ForegroundColor Blue
    Write-Host "Which programming language would you like to use for this learning path?"

    $options = @(
        "Java (Spring Boot ecosystem)",
        "Python (FastAPI with UV)",
        "Rust (Actix-web)",
        "I'll decide later"
    )

    $choice = Get-InteractiveChoice "Choose your language track:" $options

    switch ($choice) {
        0 { return "java" }
        1 { return "python" }
        2 { return "rust" }
        3 { return "undecided" }
    }
}

function Test-JavaTools {
    Write-Step 2 "Verifying Java development tools"

    # Java JDK
    Write-SubStep "Checking Java JDK"
    try {
        $javaOutput = java -version 2>&1
        $javaVersion = ($javaOutput[0] -split '"')[1]

        # Check if Java 17+
        $majorVersion = [int]($javaVersion -split '\.')[0]
        if ($majorVersion -ge 17) {
            Write-Success "Java $javaVersion (JDK) is installed"
        }
        else {
            Write-Warning "Java $javaVersion found, but Java 17+ is recommended"
        }

        # Test javac
        javac -version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Java compiler (javac) not found. JDK required, not just JRE."
            return $false
        }
    }
    catch {
        Write-Error "Java JDK is not installed"
        Write-Info "Install Java 17+: https://adoptium.net/temurin/releases/?version=17"
        return $false
    }

    # Maven
    Write-SubStep "Checking Maven"
    try {
        $mavenVersion = (mvn -version)[0].Split(' ')[2]
        Write-Success "Maven $mavenVersion is installed"
    }
    catch {
        Write-Error "Maven is not installed"
        Write-Info "Install Maven: https://maven.apache.org/install.html"
        return $false
    }

    # Test compilation
    Write-SubStep "Testing Java compilation"
    $testDir = Join-Path $env:TEMP "java-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null

    $javaCode = @"
public class HelloDocker {
    public static void main(String[] args) {
        System.out.println("Java is ready for Docker learning!");
    }
}
"@

    $javaFile = Join-Path $testDir "HelloDocker.java"
    $javaCode | Out-File -FilePath $javaFile -Encoding UTF8

    try {
        Push-Location $testDir
        javac HelloDocker.java
        $output = java HelloDocker

        if ($output -match "Java is ready") {
            Write-Success "Java compilation and execution test passed"
            $result = $true
        }
        else {
            Write-Error "Java compilation test failed"
            $result = $false
        }
    }
    catch {
        Write-Error "Java compilation test failed: $($_.Exception.Message)"
        $result = $false
    }
    finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    return $result
}

function Test-PythonTools {
    Write-Step 2 "Verifying Python development tools"

    # Python
    Write-SubStep "Checking Python installation"
    try {
        $pythonVersion = (python --version 2>&1).Split(' ')[1]

        # Check if Python 3.11+
        $versionParts = $pythonVersion.Split('.')
        $major = [int]$versionParts[0]
        $minor = [int]$versionParts[1]

        if ($major -eq 3 -and $minor -ge 11) {
            Write-Success "Python $pythonVersion is installed"
        }
        else {
            Write-Warning "Python $pythonVersion found, but Python 3.11+ is recommended"
        }
    }
    catch {
        # Try python3 command
        try {
            $pythonVersion = (python3 --version).Split(' ')[1]
            Write-Success "Python $pythonVersion is installed"
        }
        catch {
            Write-Error "Python 3 is not installed"
            Write-Info "Install Python 3.11+: https://python.org"
            return $false
        }
    }

    # UV package manager
    Write-SubStep "Checking UV package manager"
    try {
        $uvVersion = (uv --version).Split(' ')[1]
        Write-Success "UV $uvVersion is installed"
    }
    catch {
        Write-Error "UV package manager is not installed"
        Write-Info "Install UV: powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`""
        return $false
    }

    # Test Python execution
    Write-SubStep "Testing Python execution"
    try {
        $output = python -c "print('Python is ready for Docker learning!')"
        if ($output -match "Python is ready") {
            Write-Success "Python execution test passed"
        }
        else {
            Write-Error "Python execution test failed"
            return $false
        }
    }
    catch {
        Write-Error "Python execution test failed: $($_.Exception.Message)"
        return $false
    }

    return $true
}

function Test-RustTools {
    Write-Step 2 "Verifying Rust development tools"

    # Rust compiler
    Write-SubStep "Checking Rust compiler"
    try {
        $rustVersion = (rustc --version).Split(' ')[1]
        Write-Success "Rust $rustVersion is installed"
    }
    catch {
        Write-Error "Rust compiler is not installed"
        Write-Info "Install Rust: https://rustup.rs/"
        return $false
    }

    # Cargo package manager
    Write-SubStep "Checking Cargo package manager"
    try {
        $cargoVersion = (cargo --version).Split(' ')[1]
        Write-Success "Cargo $cargoVersion is installed"
    }
    catch {
        Write-Error "Cargo is not installed (should come with Rust)"
        return $false
    }

    # Test compilation
    Write-SubStep "Testing Rust compilation"
    $testDir = Join-Path $env:TEMP "rust-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null

    $rustCode = @"
fn main() {
    println!("Rust is ready for Docker learning!");
}
"@

    $rustFile = Join-Path $testDir "main.rs"
    $rustCode | Out-File -FilePath $rustFile -Encoding UTF8

    try {
        Push-Location $testDir
        rustc main.rs
        $executable = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { ".\main.exe" } else { "./main" }
        $output = & $executable

        if ($output -match "Rust is ready") {
            Write-Success "Rust compilation and execution test passed"
            $result = $true
        }
        else {
            Write-Error "Rust compilation test failed"
            $result = $false
        }
    }
    catch {
        Write-Error "Rust compilation test failed: $($_.Exception.Message)"
        $result = $false
    }
    finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    return $result
}

function Test-SystemResources {
    Write-Step 3 "Checking system resources"

    # Available disk space
    Write-SubStep "Checking disk space"
    try {
        $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | Where-Object { $_.DeviceID -eq "C:" }
        if ($drive) {
            $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 1)
            Write-Info "Available disk space: ${freeSpaceGB}GB"

            if ($freeSpaceGB -ge 10) {
                Write-Success "Sufficient disk space available (${freeSpaceGB}GB)"
            }
            else {
                Write-Warning "Low disk space (${freeSpaceGB}GB). 10GB+ recommended for Docker learning"
            }
        }
    }
    catch {
        Write-Warning "Could not check disk space"
    }

    # Memory
    Write-SubStep "Checking available memory"
    try {
        $totalMemory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory
        $totalMemoryGB = [math]::Round($totalMemory / 1GB, 1)
        Write-Info "Total system memory: ${totalMemoryGB}GB"
    }
    catch {
        Write-Warning "Could not check system memory"
    }

    # Docker resources
    Write-SubStep "Checking Docker resource limits"
    try {
        $dockerInfo = docker system info 2>$null
        if ($dockerInfo) {
            $cpuLine = $dockerInfo | Where-Object { $_ -match "CPUs:" }
            $memoryLine = $dockerInfo | Where-Object { $_ -match "Total Memory:" }

            if ($cpuLine) {
                $cpus = ($cpuLine -split ":")[1].Trim()
                Write-Info "Docker CPUs available: $cpus"
            }
            if ($memoryLine) {
                $memory = ($memoryLine -split ":")[1].Trim()
                Write-Info "Docker memory available: $memory"
            }
        }
    }
    catch {
        Write-Warning "Could not get Docker resource information"
    }
}

function Test-Integration {
    Write-Step 4 "Running integration test"

    Write-SubStep "Testing Docker with a simple container"
    try {
        $output = docker run --rm alpine:latest echo "Docker integration test passed!"
        if ($output -match "Docker integration test passed") {
            Write-Success "Docker integration test completed"
        }
        else {
            Write-Error "Docker integration test failed"
            return $false
        }
    }
    catch {
        Write-Error "Docker integration test failed: $($_.Exception.Message)"
        return $false
    }

    Write-SubStep "Testing Docker image operations"
    try {
        docker images alpine:latest | Out-Null
        Write-Success "Docker image operations working"
    }
    catch {
        Write-Warning "Docker image operations may have issues"
    }

    return $true
}

function New-CompletionMarker {
    param([string]$Language)

    $completionFile = Join-Path $ScriptDir ".setup-complete"

    $content = @"
# Setup completion marker
SETUP_DATE=$(Get-Date)
LANGUAGE_TRACK=$Language
PLATFORM=$(Get-OperatingSystem)
DOCKER_VERSION=$(docker --version 2>`$null)
"@

    $content | Out-File -FilePath $completionFile -Encoding UTF8
    Write-Success "Setup completion marker created"
}

# =============================================================================
# Main Verification Flow
# =============================================================================
function Main {
    # Introduction
    Write-Host ""
    Write-Host "$Script:DOCKER_EMOJI Docker Learning Path - Setup Verification" -ForegroundColor Blue
    Write-Host "This script will verify that your development environment is ready" -ForegroundColor Blue

    Wait-ForLearning "Press Enter to begin verification..."

    # Core tools verification
    if (-not (Test-CoreTools)) {
        Write-Error "Core tools verification failed"
        Write-Info "Please install missing tools and run this script again"
        exit 1
    }

    # Language selection and verification
    $languageChoice = Get-LanguagePreference

    switch ($languageChoice) {
        "java" {
            if (Test-JavaTools) {
                Write-Success "Java track verification completed"
            }
            else {
                Write-Error "Java tools verification failed"
                exit 1
            }
        }
        "python" {
            if (Test-PythonTools) {
                Write-Success "Python track verification completed"
            }
            else {
                Write-Error "Python tools verification failed"
                exit 1
            }
        }
        "rust" {
            if (Test-RustTools) {
                Write-Success "Rust track verification completed"
            }
            else {
                Write-Error "Rust tools verification failed"
                exit 1
            }
        }
        "undecided" {
            Write-Info "No specific language tools verified"
            Write-Info "You can run this script again later to verify language-specific tools"
            $languageChoice = "none"
        }
    }

    # System resources
    Test-SystemResources

    # Integration test
    if (-not (Test-Integration)) {
        Write-Error "Integration test failed"
        exit 1
    }

    # Create completion marker
    New-CompletionMarker $languageChoice

    # Success summary
    Write-Host ""
    Write-Host "🎉 Setup Verification Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your development environment is ready for Docker learning!" -ForegroundColor Green

    if ($languageChoice -ne "none") {
        Write-Host "Language track: $languageChoice" -ForegroundColor Green
    }

    Show-LearningTip "You're now ready to start Module 01: Docker Fundamentals. This module teaches core Docker concepts that apply to all programming languages."

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Blue
    Write-Host "  1. cd ..\01-docker-fundamentals" -ForegroundColor Cyan
    Write-Host "  2. Read the README.md file" -ForegroundColor Cyan
    Write-Host "  3. Complete the hands-on exercises" -ForegroundColor Cyan

    Write-Success "Happy learning! 🚀"
}

# Handle command line arguments
if ($Help) {
    Show-Help
    exit 0
}
elseif ($Version) {
    Show-Version
    exit 0
}
else {
    Main
}

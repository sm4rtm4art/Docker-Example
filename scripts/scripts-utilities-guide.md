# Docker Learning Path - Scripts & Utilities 🛠️

> **Cross-platform utility functions and scripts for Docker education**

This directory contains reusable utilities and scripts that provide a consistent, professional experience across all modules in the Docker learning path.

## 🌍 Cross-Platform Design

Our scripts work on **Windows**, **macOS**, and **Linux** by providing equivalent functionality in both bash and PowerShell:

```
scripts/
├── utils.sh              # Bash utilities (Unix/macOS/Linux)
├── utils.ps1             # PowerShell utilities (Windows)
├── docker-cleanup.sh     # Original cleanup script
├── docker-cleanup-v2.sh  # Enhanced bash cleanup (uses utils.sh)
├── docker-cleanup.ps1    # PowerShell cleanup (uses utils.ps1)
├── run-cleanup.sh        # Cross-platform launcher
└── example-module-script.sh  # Template for educational scripts
```

## 🎯 Why This Matters for Docker Education

**Docker's promise**: "Build once, run anywhere"  
**Our promise**: "Learn once, apply anywhere"

Students using different operating systems should have identical learning experiences. These utilities ensure that:

- ✅ **Colors and formatting** work consistently
- ✅ **Error handling** is standardized
- ✅ **Interactive features** behave the same way
- ✅ **Educational flow** is preserved across platforms

## 🚀 Quick Start

### For Script Authors (Creating New Educational Scripts)

#### Bash Version:

```bash
#!/bin/bash
# Your educational script

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Now you can use:
log_success "Docker is working!"
log_error "Something went wrong"
check_docker
pause_for_learning "Ready to continue?"
```

#### PowerShell Version:

```powershell
# Your educational script

# Import utilities
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\utils.ps1"

# Now you can use:
Write-Success "Docker is working!"
Write-Error "Something went wrong"
Test-Docker
Wait-ForLearning "Ready to continue?"
```

### For Students (Using the Scripts)

#### Cross-Platform Cleanup:

```bash
# Auto-detects your platform and uses appropriate script
./scripts/run-cleanup.sh

# Or use platform-specific versions:
./scripts/docker-cleanup-v2.sh     # Bash (Unix/macOS/Linux)
./scripts/docker-cleanup.ps1       # PowerShell (Windows)
```

## 📚 Available Utility Functions

### 🎨 Logging & Display

| Bash                       | PowerShell                   | Purpose               |
| -------------------------- | ---------------------------- | --------------------- |
| `log_success "message"`    | `Write-Success "message"`    | Green success message |
| `log_error "message"`      | `Write-Error "message"`      | Red error message     |
| `log_warning "message"`    | `Write-Warning "message"`    | Yellow warning        |
| `log_info "message"`       | `Write-Info "message"`       | Cyan info message     |
| `log_step 1 "description"` | `Write-Step 1 "description"` | Blue step header      |
| `log_substep "item"`       | `Write-SubStep "item"`       | Purple bullet point   |

### 🐳 Docker Utilities

| Bash                        | PowerShell                 | Purpose                     |
| --------------------------- | -------------------------- | --------------------------- |
| `check_docker`              | `Test-Docker`              | Verify Docker is running    |
| `check_docker_compose`      | `Test-DockerCompose`       | Verify Compose is available |
| `docker_cleanup_containers` | `Remove-StoppedContainers` | Clean stopped containers    |
| `docker_cleanup_images`     | `Remove-UnusedImages`      | Clean unused images         |
| `wait_for_url "http://..."` | `Wait-ForUrl "http://..."` | Wait for service to respond |

### 🎓 Educational Features

| Bash                           | PowerShell                   | Purpose                   |
| ------------------------------ | ---------------------------- | ------------------------- |
| `pause_for_learning "message"` | `Wait-ForLearning "message"` | Interactive pause         |
| `show_learning_tip "tip"`      | `Show-LearningTip "tip"`     | Highlight learning points |
| `show_command_explanation`     | `Show-CommandExplanation`    | Explain commands          |
| `interactive_choice`           | `Get-InteractiveChoice`      | Multiple choice prompts   |

### 🔧 System Utilities

| Bash                        | PowerShell                | Purpose            |
| --------------------------- | ------------------------- | ------------------ |
| `detect_os`                 | `Get-OperatingSystem`     | Platform detection |
| `check_port_available 8080` | `Test-PortAvailable 8080` | Port availability  |
| `mark_module_complete`      | `Set-ModuleComplete`      | Track progress     |

## 🎨 Color Scheme

Our consistent color scheme helps students focus:

- 🟢 **Green**: Success, completion, "good" examples
- 🔴 **Red**: Errors, failures, "bad" examples
- 🟡 **Yellow**: Warnings, important notes, prompts
- 🔵 **Blue**: Headers, steps, structure
- 🟣 **Purple**: Sub-items, details
- 🔷 **Cyan**: Information, tips, explanations

## 📝 Script Templates

### Educational Module Script Template

See [`example-module-script.sh`](./example-module-script.sh) for a complete template showing:

- ✅ Proper utility sourcing
- ✅ Prerequisites checking
- ✅ Interactive learning flow
- ✅ Error handling
- ✅ Progress tracking
- ✅ Educational best practices

### Utility Script Pattern

```bash
#!/bin/bash
# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Your main function
main() {
    log_step 1 "Doing something educational"

    if check_docker; then
        log_success "Docker is ready!"
        # Do Docker stuff
    else
        log_error "Docker not available"
        exit 1
    fi

    pause_for_learning "Press Enter to continue..."

    show_learning_tip "This is how you teach effectively with consistent UX!"
}

# Run main function
main "$@"
```

## 🧪 Testing Your Scripts

### Manual Testing

```bash
# Test utilities directly
./scripts/utils.sh --help
./scripts/utils.sh --version

# Test cleanup functionality
./scripts/docker-cleanup-v2.sh --help
./scripts/docker-cleanup.ps1 -Help
```

### Pre-commit Integration

Our pre-commit hooks automatically check:

- ✅ Script syntax and formatting
- ✅ Executable permissions
- ✅ Cross-platform compatibility
- ✅ Educational content standards

## 🔄 Contributing New Utilities

When adding new utility functions:

1. **Add to both platforms**: Implement in both `utils.sh` and `utils.ps1`
2. **Follow naming conventions**:
   - Bash: `snake_case`
   - PowerShell: `Verb-Noun` (PascalCase)
3. **Add error handling**: Use the built-in error handling patterns
4. **Document the function**: Update this README with new functions
5. **Test cross-platform**: Verify it works on Windows and Unix-like systems

### Example: Adding a New Function

```bash
# In utils.sh
check_network_connectivity() {
    local host=${1:-"google.com"}
    if ping -c 1 "$host" &> /dev/null; then
        log_success "Network connectivity verified"
        return 0
    else
        log_error "No network connectivity to $host"
        return 1
    fi
}
```

```powershell
# In utils.ps1
function Test-NetworkConnectivity {
    param([string]$Host = "google.com")

    try {
        $result = Test-Connection -ComputerName $Host -Count 1 -Quiet
        if ($result) {
            Write-Success "Network connectivity verified"
            return $true
        } else {
            Write-Error "No network connectivity to $Host"
            return $false
        }
    }
    catch {
        Write-Error "Network test failed: $($_.Exception.Message)"
        return $false
    }
}
```

## 🎯 Best Practices

### For Educational Scripts:

1. **Start with prerequisites** - Always check Docker availability
2. **Use consistent messaging** - Leverage the logging functions
3. **Provide learning context** - Use tips and explanations
4. **Allow for exploration** - Include interactive pauses
5. **Clean up after yourself** - Remove test containers/images
6. **Handle errors gracefully** - Guide students through problems

### For Utility Functions:

1. **Be cross-platform** - Test on Windows and Unix-like systems
2. **Handle errors** - Return meaningful exit codes
3. **Provide feedback** - Use the logging functions consistently
4. **Be educational** - Functions should teach, not just execute
5. **Stay focused** - Each function should do one thing well

---

**Remember**: These utilities aren't just about code organization - they're about creating a **consistent, professional learning experience** that helps students focus on Docker concepts rather than platform differences! 🎓🐳

# Read-only setup check. No package installation or permission changes.
$ErrorActionPreference = 'Stop'
foreach ($tool in @('docker', 'git', 'python', 'curl.exe')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Missing required tool: $tool"
    }
}
python -c "import sys; sys.exit(0 if sys.version_info >= (3, 12) else 'Python 3.12+ required')"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
docker version
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
docker compose version
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$composeHelp = docker compose up --help
if ($LASTEXITCODE -ne 0 -or ($composeHelp -join "`n") -notmatch '--wait') { throw 'Compose up --wait required' }
$containerOs = docker info --format '{{.OSType}}'
if ($LASTEXITCODE -ne 0 -or $containerOs -ne 'linux') { throw 'Linux containers are required' }
Write-Output 'PASS: required tools, Compose wait support and Linux daemon available.'

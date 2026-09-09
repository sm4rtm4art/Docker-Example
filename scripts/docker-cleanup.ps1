# Compatibility wrapper; see python scripts/cleanup.py --help.
$ErrorActionPreference = 'Stop'
python (Join-Path $PSScriptRoot 'cleanup.py') @args
exit $LASTEXITCODE

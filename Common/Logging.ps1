param(
    [string]$LogRoot = "C:\ServerUpgradeLogs"
)

if (-not (Test-Path $LogRoot)) {
    New-Item -ItemType Directory -Path $LogRoot | Out-Null
}

$scriptName = (Split-Path -Leaf $MyInvocation.MyCommand.Path)
$timestamp  = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$logFile    = Join-Path $LogRoot "$($scriptName)_$timestamp.log"

function Write-Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
    )
    $line = "{0} [{1}] {2}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $logFile -Value $line

    switch ($Level) {
        "INFO"  { Write-Host $line -ForegroundColor Gray }
        "WARN"  { Write-Host $line -ForegroundColor Yellow }
        "ERROR" { Write-Host $line -ForegroundColor Red }
    }
}

Write-Log "Logging initialized for $scriptName"

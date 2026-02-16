. "C:\ServerUpgradeToolkit\Common\Logging.ps1"

Write-Log "=== PRE-UPGRADE COMPATIBILITY SCAN STARTED ==="

Write-Log "OS info:"
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber | Out-String | Write-Log

# Reboot pending check
$rebootKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
if (Test-Path $rebootKey) { 
    Write-Log "Reboot pending detected." "WARN" 
} else { 
    Write-Log "No reboot pending." 
}

# AV / EDR / Webroot detection
Write-Log "Checking for AV/EDR services including Webroot..."
Get-Service | Where-Object {
    $_.Name -match "WRSVC|WRCore|WRkrn|Webroot|Symantec|McAfee|Trend|CarbonBlack|CrowdStrike|Sophos"
} | Select-Object Name, Status, DisplayName | Out-String | Write-Log

# Installed roles
Write-Log "Installed roles:"
Get-WindowsFeature | Where-Object {$_.Installed} | Select-Object DisplayName, Name | Out-String | Write-Log

# RDS roles
Write-Log "Checking for RDS roles..."
$rdsRoles = Get-WindowsFeature *RDS* | Where-Object {$_.Installed}
if ($rdsRoles) {
    $rdsRoles | Select-Object DisplayName, Name | Out-String | Write-Log
} else {
    Write-Log "No RDS roles detected."
}

# SQL services
Write-Log "Checking for SQL services..."
$sqlService = Get-Service *SQL* -ErrorAction SilentlyContinue
if ($sqlService) {
    $sqlService | Select-Object Name, Status, DisplayName | Out-String | Write-Log
} else {
    Write-Log "No SQL services detected."
}

Write-Log "=== PRE-UPGRADE COMPATIBILITY SCAN COMPLETE ==="

. "C:\ServerUpgradeToolkit\Common\Logging.ps1"

Write-Log "=== DRIVER COMPATIBILITY SCAN STARTED ==="

# Service-level detection
Write-Log "Checking for known AV/EDR/filter services including Webroot..."
Get-Service | Where-Object {
    $_.Name -match "WRSVC|WRCore|WRkrn|Webroot|Symantec|McAfee|Trend|CarbonBlack|CrowdStrike|Sophos|Veeam|Acronis"
} | Select-Object Name, Status, DisplayName | Out-String | Write-Log

# Filter drivers
Write-Log "Enumerating file system filter drivers..."
fltmc filters | Out-String | Write-Log

Write-Log "Checking specifically for Webroot filter drivers (WRkrn)..."
fltmc filters | Where-Object { $_ -match "WRkrn" } | Out-String | Write-Log

# Kernel drivers
Write-Log "Enumerating running kernel drivers..."
Get-CimInstance Win32_SystemDriver | Where-Object {
    $_.State -eq "Running" -and $_.ServiceType -like "*Kernel*"
} | Select-Object Name, DisplayName, PathName | Out-String | Write-Log

Write-Log "=== DRIVER COMPATIBILITY SCAN COMPLETE ==="

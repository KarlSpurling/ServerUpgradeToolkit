. "C:\ServerUpgradeToolkit\Common\Logging.ps1"

Write-Log "=== DRIVER COMPATIBILITY SCAN STARTED ==="

Write-Log "Checking for known filter drivers (AV, backup, EDR)..."
Get-Service | Where-Object {
    $_.Name -match "WR|Symantec|McAfee|Trend|CarbonBlack|CrowdStrike|Sophos|Veeam|Acronis"
} | Select Name, Status, DisplayName | Out-String | Write-Log

Write-Log "Enumerating file system filter drivers..."
fltmc filters | Out-String | Write-Log

Write-Log "Enumerating running kernel drivers..."
Get-WmiObject Win32_SystemDriver | Where-Object { $_.State -eq "Running" -and $_.ServiceType -like "*Kernel*" } |
    Select Name, DisplayName, PathName | Out-String | Write-Log

Write-Log "=== DRIVER COMPATIBILITY SCAN COMPLETE ==="

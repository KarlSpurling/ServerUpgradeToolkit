. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== ROLLBACK PREP HELPER STARTED ==="

Write-Log "Reminder: Take a Hyper-V snapshot or VM backup now (manual step)."

Write-Log "Checking for latest pre-flight backup..."
$latest = Get-ChildItem C:\ -Directory | Where-Object { $_.Name -like "PreFlightBackup_*" } | Sort-Object Name | Select-Object -Last 1
if ($latest) {
    Write-Log "Latest pre-flight backup: $($latest.FullName)"
} else {
    Write-Log "No pre-flight backup found. Run PreFlightBackup.ps1 first." "WARN"
}

$rollbackRoot = "C:\RollbackDiag_{0}" -f (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
New-Item -ItemType Directory -Path $rollbackRoot | Out-Null

Write-Log "Exporting rollback diagnostics to $rollbackRoot..."
Get-EventLog -LogName System -Newest 500 | Export-Clixml "$rollbackRoot\SystemEvents.xml"
Get-EventLog -LogName Application -Newest 500 | Export-Clixml "$rollbackRoot\ApplicationEvents.xml"

Write-Log "ROLLBACK PREP COMPLETE."
Send-UpgradeMail -Subject "Rollback Prep Complete ($env:COMPUTERNAME)" -Body "Rollback diagnostics at $rollbackRoot."

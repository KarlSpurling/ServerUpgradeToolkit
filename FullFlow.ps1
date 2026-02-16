. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== FULL UPGRADE FLOW STARTED ==="

$server = $env:COMPUTERNAME
$backupRoot = ""

# Webroot detection
Write-Log "Checking for Webroot before upgrade..."
if (Get-Service WRSVC -ErrorAction SilentlyContinue) {
    Write-Log "WARNING: Webroot detected. Remove Webroot before performing OS upgrade." "WARN"
}

try {
    Write-Log "Running Pre-Flight Backup..."
    & "C:\ServerUpgradeToolkit\1_PreFlightBackup\PreFlightBackup.ps1"

    $latest = Get-ChildItem C:\ -Directory | Where-Object { $_.Name -like "PreFlightBackup_*" } | Sort-Object Name | Select-Object -Last 1
    if (-not $latest) { throw "No pre-flight backup folder found after PreFlightBackup.ps1." }
    $backupRoot = $latest.FullName
    Write-Log "Using backup folder: $backupRoot"

    Write-Log "PAUSE: Perform the in-place OS upgrade now."
    Write-Host "Perform the OS upgrade now (setup.exe). Press ENTER when the upgrade is complete." -ForegroundColor Yellow
    Read-Host

    Write-Log "Running Post-Upgrade Restore..."
    & "C:\ServerUpgradeToolkit\3_PostUpgradeRestore\PostUpgradeRestore.ps1" -BackupRoot $backupRoot

    Write-Log "Installing Defender..."
    & "C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderAutoInstall.ps1" -SourcePath "C:\ServerUpgradeToolkit\5_DefenderInstall"

    Write-Log "Applying Hardening..."
    & "C:\ServerUpgradeToolkit\6_Hardening\Hardening2025.ps1"

    Write-Log "Running Defender Health Score..."
    & "C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderHealthScore.ps1"

    $html = @"
<h2>Full Upgrade Flow Complete</h2>
<p>Server: <b>$server</b></p>
<ul>
  <li>Pre-flight backup: OK</li>
  <li>Post-upgrade restore: OK</li>
  <li>Defender install: OK</li>
  <li>Hardening: OK</li>
</ul>
"@
    Send-UpgradeMail -Subject "Full Upgrade Flow Complete ($server)" -Body $html -Html

    Write-Log "=== FULL UPGRADE FLOW COMPLETE ==="
} catch {
    Write-Log "FULL FLOW FAILED: $($_.Exception.Message)" "ERROR"
    Send-UpgradeMail -Subject "Full Upgrade Flow FAILED ($server)" -Body "Check logs on $server."
}

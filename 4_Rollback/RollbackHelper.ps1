. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== ROLLBACK EXECUTION HELPER ==="

Write-Log "If upgrade failed badly, recommended order:"
Write-Log "1. Shut down the VM."
Write-Log "2. Revert Hyper-V snapshot or restore backup."
Write-Log "3. Boot and verify services."
Write-Log "4. Run PostUpgradeRestore.ps1 if needed."

Write-Host "This script is advisory only—no destructive automation." -ForegroundColor Yellow

Send-UpgradeMail -Subject "Rollback Helper Invoked ($env:COMPUTERNAME)" -Body "Rollback helper was run on $env:COMPUTERNAME."
Write-Log "ROLLBACK HELPER COMPLETE."

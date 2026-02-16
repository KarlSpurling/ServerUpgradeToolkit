param(
    [Parameter(Mandatory=$true)]
    [string]$BackupRoot
)

. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== POST-UPGRADE RESTORE STARTED ==="
Write-Log "Using backup root: $BackupRoot"

try {
    if (-not (Test-Path $BackupRoot)) {
        throw "Backup root not found."
    }

    # Certificates
    $certPath = Join-Path $BackupRoot "Certificates"
    if (Test-Path $certPath) {
        Write-Log "Restoring certificates..."
        Get-ChildItem $certPath -Filter *.pfx | ForEach-Object {
            Write-Log "Importing $($_.Name)..."
            Import-PfxCertificate -FilePath $_.FullName -CertStoreLocation Cert:\LocalMachine\My `
                -Password (ConvertTo-SecureString -String "ChangeThisPassword123!" -Force -AsPlainText) | Out-Null
        }
    } else {
        Write-Log "No certificate backup folder found." "WARN"
    }

    # RDS licensing
    $rdsPath = Join-Path $BackupRoot "RDS"
    $licFile = Join-Path $rdsPath "RDS-Licensing.reg"
    if (Test-Path $licFile) {
        Write-Log "Restoring RDS licensing..."
        reg import $licFile | Out-Null
    } else {
        Write-Log "No RDS licensing backup found." "WARN"
    }

    # IIS config (manual)
    Write-Log "IIS configuration backup exists as PreFlightBackup_<timestamp> (manual restore if needed)."

    # RDS deployment info
    if (Test-Path (Join-Path $rdsPath "Deployment")) {
        Write-Log "RDS deployment backup exists at $rdsPath\Deployment (use Import-RDDeployment only if needed)."
    }

    # Quick RDS sanity
    Write-Log "Quick RDS sanity check..."
    try {
        Get-RDSessionHost | Format-Table CollectionName, SessionHost | Out-String | Write-Log
        Get-RDLicenseConfiguration | Out-String | Write-Log
    } catch {
        Write-Log "RDS cmdlets not available or RDS not installed." "WARN"
    }

    Write-Log "POST-UPGRADE RESTORE COMPLETE."
    $html = @"
<h2>Post-Upgrade Restore Complete</h2>
<p>Server: <b>$env:COMPUTERNAME</b></p>
<p>Backup root: <b>$BackupRoot</b></p>
"@
    Send-UpgradeMail -Subject "Post-Upgrade Restore Complete ($env:COMPUTERNAME)" -Body $html -Html
} catch {
    Write-Log "Post-upgrade restore FAILED: $($_.Exception.Message)" "ERROR"
    Send-UpgradeMail -Subject "Post-Upgrade Restore FAILED ($env:COMPUTERNAME)" -Body "Check logs on $env:COMPUTERNAME."
}

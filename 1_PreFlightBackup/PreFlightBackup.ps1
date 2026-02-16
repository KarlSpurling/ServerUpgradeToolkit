. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== PRE-FLIGHT SAFETY NET SCRIPT STARTED ==="

# Webroot detection
Write-Log "Checking for Webroot installation..."
if (Get-Service WRSVC -ErrorAction SilentlyContinue) {
    Write-Log "Webroot service detected (WRSVC)."
}
if (Test-Path "C:\ProgramData\WRData") {
    Write-Log "Webroot data folder detected."
}
if (Test-Path "C:\Program Files\Webroot") {
    Write-Log "Webroot program folder detected."
}

try {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $backupRoot = "C:\PreFlightBackup_$timestamp"
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
    Write-Log "Backup folder: $backupRoot"

    # Certificates
    $certPath = "$backupRoot\Certificates"
    New-Item -ItemType Directory -Path $certPath | Out-Null
    Write-Log "Exporting certificates..."
    $certs = Get-ChildItem Cert:\LocalMachine\My
    foreach ($cert in $certs) {
        $safeName = ($cert.Subject -replace '[^a-zA-Z0-9\-\.]', '_')
        $pfxFile = "$certPath\$safeName.pfx"
        try {
            $cert | Export-PfxCertificate -FilePath $pfxFile `
                -Password (ConvertTo-SecureString -String "ChangeThisPassword123!" -Force -AsPlainText) -ErrorAction Stop
            Write-Log "Exported cert: $safeName"
        } catch {
            Write-Log "Failed to export cert: $safeName - $($_.Exception.Message)" "WARN"
        }
    }

    # RDS deployment
    $rdsPath = "$backupRoot\RDS"
    New-Item -ItemType Directory -Path $rdsPath | Out-Null
    Write-Log "Checking for RDS deployment..."
    try {
        $deployment = Get-RDDeployment -ErrorAction Stop
        if ($deployment) {
            Export-RDDeployment -Path "$rdsPath\Deployment" -ErrorAction Stop
            Write-Log "RDS deployment exported."
        }
    } catch {
        Write-Log "No RDS deployment detected or export failed." "WARN"
    }

    # RDS licensing
    Write-Log "Exporting RDS licensing..."
    try {
        reg export HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM "$rdsPath\RDS-Licensing.reg" /y
        Write-Log "RDS licensing exported."
    } catch {
        Write-Log "RDS licensing export failed or not present." "WARN"
    }

    # IIS config
    $iisPath = "$backupRoot\IIS"
    New-Item -ItemType Directory -Path $iisPath | Out-Null
    Write-Log "Backing up IIS configuration..."
    try {
        & "$env:windir\system32\inetsrv\appcmd.exe" add backup "PreFlightBackup_$timestamp"
        Write-Log "IIS configuration backup created."
    } catch {
        Write-Log "IIS backup failed or IIS not installed." "WARN"
    }

    # System info + roles
    Write-Log "Exporting system info and roles..."
    Get-ComputerInfo | Out-File "$backupRoot\SystemInfo.txt"
    Get-WindowsFeature | Out-File "$backupRoot\InstalledRoles.txt"

    # Event logs
    Write-Log "Exporting recent event logs..."
    Get-EventLog -LogName System -Newest 200 | Export-Clixml "$backupRoot\SystemEvents.xml"
    Get-EventLog -LogName Application -Newest 200 | Export-Clixml "$backupRoot\ApplicationEvents.xml"

    Write-Log "PRE-FLIGHT SAFETY NET COMPLETE."
    $html = @"
<h2>Pre-Flight Backup Complete</h2>
<p>Server: <b>$env:COMPUTERNAME</b></p>
<p>Backup folder: <b>$backupRoot</b></p>
"@
    Send-UpgradeMail -Subject "Pre-Flight Backup Complete ($env:COMPUTERNAME)" -Body $html -Html
} catch {
    Write-Log "Pre-flight backup FAILED: $($_.Exception.Message)" "ERROR"
    Send-UpgradeMail -Subject "Pre-Flight Backup FAILED ($env:COMPUTERNAME)" -Body "Check logs on $env:COMPUTERNAME."
}

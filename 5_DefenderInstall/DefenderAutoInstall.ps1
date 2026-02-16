param(
    [string]$SourcePath = "C:\ServerUpgradeToolkit\5_DefenderInstall"
)

. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== DEFENDER MSI AUTO-INSTALLER STARTED ==="
Write-Log "Source path: $SourcePath"

# Webroot conflict warning
try {
    $webrootService = Get-Service -Name "WRSVC" -ErrorAction SilentlyContinue
    if ($webrootService) {
        Write-Log "Webroot detected — Defender installation may conflict." "WARN"
    }
} catch {
    Write-Log "Webroot detection failed: $($_.Exception.Message)" "WARN"
}

try {
    if (-not (Test-Path -Path $SourcePath)) {
        throw "Source path not found: $SourcePath"
    }

    # Find MSI installers
    $avMsi = Get-ChildItem -Path $SourcePath -Filter "*MpEng*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
    $edrMsi = Get-ChildItem -Path $SourcePath -Filter "*Sense*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
    $onboardScript = Get-ChildItem -Path $SourcePath -Filter "*OnboardingScript*.cmd" -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $avMsi) {
        throw "Defender AV MSI not found (expected file matching *MpEng*.msi)."
    }
    if (-not $edrMsi) {
        throw "Defender EDR MSI not found (expected file matching *Sense*.msi)."
    }

    Write-Log "Installing Defender AV: $($avMsi.Name)"
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($avMsi.FullName)`" /qn /norestart" -Wait

    Write-Log "Installing Defender EDR: $($edrMsi.Name)"
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($edrMsi.FullName)`" /qn /norestart" -Wait

    # Onboarding script
    if ($onboardScript) {
        Write-Log "Running onboarding script: $($onboardScript.Name)"
        Start-Process -FilePath $onboardScript.FullName -Wait
    } else {
        Write-Log "Onboarding script not found — skipping." "WARN"
    }

    # Restart services
    Write-Log "Restarting Defender services..."
    try {
        Restart-Service -Name "WinDefend" -ErrorAction SilentlyContinue
        Restart-Service -Name "Sense" -ErrorAction SilentlyContinue
    } catch {
        Write-Log "Service restart error: $($_.Exception.Message)" "WARN"
    }

    # Force telemetry
    Write-Log "Forcing Defender telemetry..."
    $platformPath = Join-Path -Path "$env:ProgramData\Microsoft\Windows Defender\Platform" -ChildPath "*"
    $mpcmd = Get-ChildItem -Path $platformPath -Filter "MpCmdRun.exe" -ErrorAction SilentlyContinue | Select-Object -Last 1

    if ($mpcmd) {
        Start-Process -FilePath $mpcmd.FullName -ArgumentList "-GetFiles" -Wait
    } else {
        Write-Log "MpCmdRun.exe not found — telemetry not forced." "WARN"
    }

    # Email summary
    Write-Log "DEFENDER INSTALLATION COMPLETE."

    $html = @"
<h2>Defender Installed</h2>
<p>Server: <b>$env:COMPUTERNAME</b></p>
<p>AV MSI: <b>$($avMsi.Name)</b><br/>
EDR MSI: <b>$($edrMsi.Name)</b></p>
"@

    Send-UpgradeMail -Subject "Defender Installed ($env:COMPUTERNAME)" -Body $html -Html

} catch {
    Write-Log "Defender installation FAILED: $($_.Exception.Message)" "ERROR"
    Send-UpgradeMail -Subject "Defender Installation FAILED ($env:COMPUTERNAME)" -Body "Check logs on $env:COMPUTERNAME."
}

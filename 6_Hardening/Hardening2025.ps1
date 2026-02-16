. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== SERVER 2025 HARDENING STARTED ==="

# Webroot conflict warning
if (Get-Service WRSVC -ErrorAction SilentlyContinue) {
    Write-Log "Webroot detected — Defender hardening may not apply correctly." "WARN"
}

try {
    # Defender preferences
    Write-Log "Enabling Defender MAPS + Cloud Protection..."
    Set-MpPreference -MAPSReporting Advanced -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
    Set-MpPreference -CloudBlockLevel High -ErrorAction SilentlyContinue

    Write-Log "Enabling Network Protection (block mode)..."
    Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue

    # ASR rules (audit)
    Write-Log "Enabling key ASR rules in audit mode..."
    $asrRules = @(
        "D4F940AB-401B-4EFC-AADC-AD5F3C50688A",
        "3B576869-A4EC-4529-8536-B80A7769E899",
        "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84"
    )
    foreach ($rule in $asrRules) {
        Add-MpPreference -AttackSurfaceReductionRules_Ids $rule -AttackSurfaceReductionRules_Actions AuditMode -ErrorAction SilentlyContinue
    }

    # SMBv1
    Write-Log "Disabling SMBv1..."
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue

    # TLS hardening
    Write-Log "Hardening SCHANNEL (TLS 1.0/1.1 disabled, 1.2 enabled)..."
    $base = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

    New-Item "$base\TLS 1.0\Server" -Force | Out-Null
    New-Item "$base\TLS 1.0\Client" -Force | Out-Null
    Set-ItemProperty "$base\TLS 1.0\Server" -Name Enabled -Value 0 -Type DWord
    Set-ItemProperty "$base\TLS 1.0\Client" -Name Enabled -Value 0 -Type DWord

    New-Item "$base\TLS 1.1\Server" -Force | Out-Null
    New-Item "$base\TLS 1.1\Client" -Force | Out-Null
    Set-ItemProperty "$base\TLS 1.1\Server" -Name Enabled -Value 0 -Type DWord
    Set-ItemProperty "$base\TLS 1.1\Client" -Name Enabled -Value 0 -Type DWord

    New-Item "$base\TLS 1.2\Server" -Force | Out-Null
    New-Item "$base\TLS 1.2\Client" -Force | Out-Null
    Set-ItemProperty "$base\TLS 1.2\Server" -Name Enabled -Value 1 -Type DWord
    Set-ItemProperty "$base\TLS 1.2\Client" -Name Enabled -Value 1 -Type DWord

    # RDP NLA
    Write-Log "Enabling RDP NLA..."
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 1

    Write-Log "HARDENING COMPLETE (reboot recommended)."
    Send-UpgradeMail -Subject "Hardening Complete ($env:COMPUTERNAME)" -Body "Server 2025 hardening applied on $env:COMPUTERNAME."
} catch {
    Write-Log "Hardening FAILED: $($_.Exception.Message)" "ERROR"
    Send-UpgradeMail -Subject "Hardening FAILED ($env:COMPUTERNAME)" -Body "Check logs on $env:COMPUTERNAME."
}

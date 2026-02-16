. "C:\ServerUpgradeToolkit\Common\Logging.ps1"
. "C:\ServerUpgradeToolkit\Common\MailHelper.ps1"

Write-Log "=== DEFENDER HEALTH SCORING STARTED ==="

$score = 0
$max   = 5

# 1. Services
$services = Get-Service WinDefend,Sense -ErrorAction SilentlyContinue
if ($services -and $services.Status -contains "Running") {
    Write-Log "Defender services running."
    $score++
} else {
    Write-Log "Defender services not fully running." "WARN"
}

# 2. Platform folder
$platform = Get-ChildItem "$env:ProgramData\Microsoft\Windows Defender\Platform" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if ($platform) {
    Write-Log "Defender platform present: $($platform.Name)"
    $score++
} else {
    Write-Log "Defender platform folder missing." "WARN"
}

# 3. Recent Defender events
$events = Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" -MaxEvents 20 -ErrorAction SilentlyContinue
if ($events) {
    Write-Log "Defender operational events found."
    $score++
} else {
    Write-Log "No Defender operational events found." "WARN"
}

# 4. Network connectivity
$net = Test-NetConnection -ComputerName www.microsoft.com -Port 443
if ($net.TcpTestSucceeded) {
    Write-Log "Outbound 443 connectivity OK."
    $score++
} else {
    Write-Log "Outbound 443 connectivity failed." "WARN"
}

# 5. Signature age
try {
    $sig = Get-MpComputerStatus -ErrorAction Stop
    if ($sig.AntispywareSignatureLastUpdated -gt (Get-Date).AddDays(-7)) {
        Write-Log "Defender signatures updated within 7 days."
        $score++
    } else {
        Write-Log "Defender signatures older than 7 days." "WARN"
    }
} catch {
    Write-Log "Get-MpComputerStatus failed (Defender AV may not be installed)." "WARN"
}

Write-Log "Defender health score: $score / $max"

if ($score -eq $max) {
    Write-Host "Defender Health: EXCELLENT ($score/$max)" -ForegroundColor Green
} elseif ($score -ge 3) {
    Write-Host "Defender Health: OK ($score/$max)" -ForegroundColor Yellow
} else {
    Write-Host "Defender Health: POOR ($score/$max)" -ForegroundColor Red
}

$html = @"
<h2>Defender Health Score</h2>
<p>Server: <b>$env:COMPUTERNAME</b></p>
<p>Score: <b>$score / $max</b></p>
"@
Send-UpgradeMail -Subject "Defender Health Score ($env:COMPUTERNAME)" -Body $html -Html

Write-Log "=== DEFENDER HEALTH SCORING COMPLETE ==="

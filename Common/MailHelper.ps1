param(
    [string]$SmtpServer = "smtp.yourdomain.local",
    [int]$SmtpPort = 25,
    [string]$From = "server-upgrade@yourdomain.local",
    [string]$To = "karl@yourdomain.local"
)

function Send-UpgradeMail {
    param(
        [Parameter(Mandatory=$true)][string]$Subject,
        [Parameter(Mandatory=$true)][string]$Body,
        [switch]$Html
    )

    $isBodyHtml = $Html.IsPresent

    try {
        Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort `
            -From $From -To $To -Subject $Subject -Body $Body -BodyAsHtml:$isBodyHtml
    } catch {
        Write-Host "Email send failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

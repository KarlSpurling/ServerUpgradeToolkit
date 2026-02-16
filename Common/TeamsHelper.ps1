param(
    [string]$WebhookUrl = "https://outlook.office.com/webhook/your-webhook-url"
)

function Send-TeamsMessage {
    param(
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$Text
    )

    $payload = @{
        "@type"    = "MessageCard"
        "@context" = "http://schema.org/extensions"
        summary    = $Title
        themeColor = "0078D7"
        title      = $Title
        text       = $Text
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType 'application/json' -Body $payload
    } catch {
        Write-Host "Teams notification failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

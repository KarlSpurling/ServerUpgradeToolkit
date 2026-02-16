param(
    [string]$TenantId     = "YOUR-TENANT-ID",
    [string]$ClientId     = "YOUR-APP-ID",
    [string]$ClientSecret = "YOUR-SECRET"
)

function Get-DefenderToken {
    param(
        [string]$Scope = "https://api.securitycenter.microsoft.com/.default"
    )

    $body = @{
        client_id     = $ClientId
        scope         = $Scope
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }

    $resp = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $body
    return $resp.access_token
}

function Get-DefenderDeviceStatus {
    param(
        [Parameter(Mandatory=$true)][string]$DeviceName
    )

    $token = Get-DefenderToken
    $headers = @{ Authorization = "Bearer $token" }

    $url = "https://api.securitycenter.microsoft.com/api/machines?`$filter=computerDnsName eq '$DeviceName'"

    $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    return $resp.value
}

param (
    [string]$AccessToken,
    [string]$ContactId
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/objects/contacts/$ContactId"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    $Response.properties | ConvertTo-Json
}
catch {
    Write-Host "Error fetching contact ${ContactId}: $($_.Exception.Message)" -ForegroundColor Red
}

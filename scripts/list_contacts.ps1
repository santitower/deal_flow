param (
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/objects/contacts?limit=5"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    $Response.results | Select-Object id, firstname, lastname, email | Format-Table -AutoSize
}
catch {
    Write-Host "Error listing contacts: $($_.Exception.Message)" -ForegroundColor Red
}

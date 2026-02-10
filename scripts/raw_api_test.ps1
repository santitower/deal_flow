param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

$CreateBody = @{
    properties = @{
        email     = "test_anchor_v2@automation.internal"
        firstname = "Test"
        lastname  = "Anchor"
    }
} | ConvertTo-Json

try {
    $Uri = "https://api.hubapi.com/crm/v3/objects/contacts"
    $Response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $Headers -Body $CreateBody -UseBasicParsing
    Write-Host "Success: $($Response.Content)" -ForegroundColor Green
}
catch {
    Write-Host "Error status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    Write-Host "Raw Error Content: $($streamReader.ReadToEnd())" -ForegroundColor Yellow
}

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
        email     = "test_anchor@automation.internal"
        firstname = "Test"
        lastname  = "Anchor"
    }
} | ConvertTo-Json

try {
    $Uri = "https://api.hubapi.com/crm/v3/objects/contacts"
    $Response = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $CreateBody
    Write-Host "Success: $($Response.id)" -ForegroundColor Green
}
catch {
    Write-Host "Error status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    $errorBody = $streamReader.ReadToEnd()
    Write-Host "Error Body: $errorBody" -ForegroundColor Red
}

param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$PropertyName
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/properties/deals/$PropertyName"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    
    Write-Host "Property: $($Response.label) ($($Response.name))" -ForegroundColor Cyan
    Write-Host "Type: $($Response.type) / $($Response.fieldType)"
    Write-Host "Options:"
    $Response.options | Select-Object label, value, displayOrder, hidden | Format-Table -AutoSize
}
catch {
    Write-Host "Error fetching property: $($_.Exception.Message)" -ForegroundColor Red
}

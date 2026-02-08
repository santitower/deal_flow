param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [string]$Search = "deal"
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/properties/deals"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    
    $Props = $Response.results | Where-Object { $_.label -like "*$Search*" -or $_.name -like "*$Search*" }
    
    if ($null -eq $Props) {
        Write-Host "No properties found matching '$Search'." -ForegroundColor Yellow
    }
    else {
        $Props | Select-Object label, name, fieldType, type, groupName | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Error fetching properties: $($_.Exception.Message)" -ForegroundColor Red
}

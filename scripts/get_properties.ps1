param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/properties/deals"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    
    $CustomProps = $Response.results | Where-Object { $_.groupName -eq "wholesale_deal_data" }
    
    if ($null -eq $CustomProps) {
        Write-Host "No properties found in group 'wholesale_deal_data'." -ForegroundColor Yellow
        Write-Host "Found Groups:" -ForegroundColor Cyan
        $Response.results | Select-Object -ExpandProperty groupName -Unique
    }
    else {
        $CustomProps | Select-Object label, name, fieldType, type | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Error fetching properties: $($_.Exception.Message)" -ForegroundColor Red
}

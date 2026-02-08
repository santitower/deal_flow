param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [Parameter(Mandatory = $true)]
    [string]$PropertyName,
    [Parameter(Mandatory = $true)]
    [array]$Options
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# If options is just one string with commas, split it
if ($Options.Count -eq 1 -and $Options[0] -like "*,*") {
    $Options = $Options[0].Split(",").Trim()
}

$HubSpotOptions = @()
$Order = 0
foreach ($Opt in $Options) {
    # Generate an internal value: lowercase snake_case
    $Value = $Opt.ToLower().Replace(" ", "_")
    $HubSpotOptions += @{
        label        = $Opt
        value        = $Value
        displayOrder = $Order
    }
    $Order++
}

$Body = @{
    options = $HubSpotOptions
} | ConvertTo-Json -Depth 4

try {
    $Uri = "https://api.hubapi.com/crm/v3/properties/deals/$PropertyName"
    Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers -Body $Body
    Write-Host "SUCCESS: Property '$PropertyName' updated with new options." -ForegroundColor Green
}
catch {
    Write-Host "Error updating property: $($_.Exception.Message)" -ForegroundColor Red
    # Try to extract more error info
    if ($_.Exception.Response) {
        $Reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $ErrorBody = $Reader.ReadToEnd()
        Write-Host "API Error: $ErrorBody" -ForegroundColor Red
    }
}

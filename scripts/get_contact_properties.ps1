param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,
    [string]$Search = ""
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/properties/contacts"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    
    $Props = $Response.results
    if ($Search) {
        $Props = $Props | Where-Object { $_.label -like "*$Search*" -or $_.name -like "*$Search*" }
    }
    
    if ($null -eq $Props) {
        Write-Host "No contact properties found."
    }
    else {
        $Props | Select-Object label, name, fieldType, type, groupName | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Error fetching contact properties: $($_.Exception.Message)" -ForegroundColor Red
}

param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# 1. Check if the Anchor Contact already exists
$SearchBody = @{
    filterGroups = @(
        @{
            filters = @(
                @{
                    propertyName = "email"
                    operator     = "EQ"
                    value        = "anchor@automation.internal"
                }
            )
        }
    )
} | ConvertTo-Json -Depth 5

try {
    $SearchUri = "https://api.hubapi.com/crm/v3/objects/contacts/search"
    $SearchResponse = Invoke-RestMethod -Uri $SearchUri -Method Post -Headers $Headers -Body $SearchBody
    
    if ($SearchResponse.total -gt 0) {
        $ContactId = $SearchResponse.results[0].id
        Write-Host "Found existing Anchor Contact: $ContactId" -ForegroundColor Cyan
        return $ContactId
    }
}
catch {
    # If search fails, we'll try to create it anyway
}

# 2. Create the Anchor Contact if not found
$CreateBody = @{
    properties = @{
        email     = "anchor@automation.internal"
        firstname = "Automation"
        lastname  = "Anchor"
        jobtitle  = "Internal Processing Record"
    }
} | ConvertTo-Json

try {
    $CreateUri = "https://api.hubapi.com/crm/v3/objects/contacts"
    $CreateResponse = Invoke-RestMethod -Uri $CreateUri -Method Post -Headers $Headers -Body $CreateBody
    $ContactId = $CreateResponse.id
    Write-Host "Created new Anchor Contact: $ContactId" -ForegroundColor Green
    return $ContactId
}
catch {
    Write-Host "Error status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    Write-Host "Error Body: $($streamReader.ReadToEnd())" -ForegroundColor Red
    return $null
}

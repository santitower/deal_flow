param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

$Categories = @(
    @{ label = "Internal: Missed Connection"; email = "missed_call@automation.internal" },
    @{ label = "Internal: Not Interested"; email = "not_interested@automation.internal" },
    @{ label = "Internal: Better Timing"; email = "better_timing@automation.internal" },
    @{ label = "Internal: Hot Lead"; email = "hot_lead@automation.internal" }
)

$Results = @{}

foreach ($Cat in $Categories) {
    # Search
    $SearchBody = @{
        filterGroups = @(@{
                filters = @(@{
                        propertyName = "email"
                        operator     = "EQ"
                        value        = $Cat.email
                    })
            })
    } | ConvertTo-Json -Depth 5

    try {
        $SearchResponse = Invoke-RestMethod -Uri "https://api.hubapi.com/crm/v3/objects/contacts/search" -Method Post -Headers $Headers -Body $SearchBody
        if ($SearchResponse.total -gt 0) {
            $Results[$Cat.label] = $SearchResponse.results[0].id
            Write-Host "Found $($Cat.label): $($Results[$Cat.label])" -ForegroundColor Cyan
            continue
        }
    }
    catch {}

    # Create
    $CreateBody = @{
        properties = @{
            email     = $Cat.email
            firstname = $Cat.label
            lastname  = "(Placeholder)"
            jobtitle  = "Automation Anchor"
        }
    } | ConvertTo-Json

    try {
        $CreateResponse = Invoke-RestMethod -Uri "https://api.hubapi.com/crm/v3/objects/contacts" -Method Post -Headers $Headers -Body $CreateBody
        $Results[$Cat.label] = $CreateResponse.id
        Write-Host "Created $($Cat.label): $($Results[$Cat.label])" -ForegroundColor Green
    }
    catch {
        Write-Host "Error status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Host "Error Body: $($streamReader.ReadToEnd())" -ForegroundColor Red
    }
}

$Results | ConvertTo-Json

param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$BaseUrl = "https://api.hubapi.com/crm/v3/pipelines/deals/default/stages"
$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

$Stages = @(
    @{ label = "New Lead"; displayOrder = 0; metadata = @{ probability = 0.1 } },
    @{ label = "Attempted - No Connect"; displayOrder = 1; metadata = @{ probability = 0.1 } },
    @{ label = "Connected - Working"; displayOrder = 2; metadata = @{ probability = 0.2 } },
    @{ label = "Warm Lead"; displayOrder = 3; metadata = @{ probability = 0.4 } },
    @{ label = "Hot Lead"; displayOrder = 4; metadata = @{ probability = 0.6 } },
    @{ label = "Closed Lost (Not Interested)"; displayOrder = 5; metadata = @{ probability = 0.0 } },
    @{ label = "Closed Lost (Bad Data)"; displayOrder = 6; metadata = @{ probability = 0.0 } }
)

Write-Host "--- Creating/Updating HubSpot Deal Stages ---`n" -ForegroundColor Cyan

foreach ($Stage in $Stages) {
    $Body = $Stage | ConvertTo-Json -Depth 4
    try {
        Write-Host "Creating Stage: $($Stage.label)..." -NoNewline
        $Response = Invoke-RestMethod -Uri $BaseUrl -Method Post -Headers $Headers -Body $Body
        Write-Host " SUCCESS (ID: $($Response.id))" -ForegroundColor Green
    }
    catch {
        $ErrorJson = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($ErrorJson)
        $ErrorBody = $Reader.ReadToEnd() | ConvertFrom-Json
        
        if ($ErrorBody.message -like "*already exists*") {
            Write-Host " SKIPPED (Already exists)" -ForegroundColor Yellow
        }
        else {
            Write-Host " ERROR: $($ErrorBody.message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n--- Script Complete ---" -ForegroundColor Cyan

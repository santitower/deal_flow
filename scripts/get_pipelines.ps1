param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

try {
    $Uri = "https://api.hubapi.com/crm/v3/pipelines/deals"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers
    
    foreach ($Pipeline in $Response.results) {
        Write-Host "Pipeline: $($Pipeline.label) (ID: $($Pipeline.id))" -ForegroundColor Cyan
        foreach ($Stage in $Pipeline.stages) {
            Write-Host "  - Stage: $($Stage.label) (ID: $($Stage.id))"
        }
    }
}
catch {
    Write-Host "Error fetching pipelines: $($_.Exception.Message)" -ForegroundColor Red
}

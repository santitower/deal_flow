param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$BaseUrl = "https://api.hubapi.com"
$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

function Delete-Property {
    param ($ObjectType, $Name)
    $Uri = "$BaseUrl/crm/v3/properties/$ObjectType/$Name"
    try {
        Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Headers -ErrorAction Stop
        Write-Host "SUCCESS: Property '$Name' deleted from $ObjectType." -ForegroundColor Green
    }
    catch {
        Write-Host "WARNING: Could not delete property '$Name'. It may not exist. ($($_.Exception.Message))" -ForegroundColor Yellow
    }
}

function Create-Property {
    param ($ObjectType, $Group, $Name, $Label, $Type, $FieldType, $Options = $null)
    $Uri = "$BaseUrl/crm/v3/properties/$ObjectType"
    $BodyData = @{
        name      = $Name
        label     = $Label
        type      = $Type
        fieldType = $FieldType
        groupName = $Group
    }
    if ($Options) { $BodyData["options"] = $Options }
    $Body = $BodyData | ConvertTo-Json -Depth 4
    try {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body -ErrorAction Stop | Out-Null
        Write-Host "SUCCESS: Property '$Label' ($Name) created on $ObjectType." -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to create property '$Label' on $ObjectType. $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Patch-Property {
    param ($ObjectType, $Name, $BodyData)
    $Uri = "$BaseUrl/crm/v3/properties/$ObjectType/$Name"
    $Body = $BodyData | ConvertTo-Json -Depth 4
    try {
        Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers -Body $Body -ErrorAction Stop | Out-Null
        Write-Host "SUCCESS: Property '$Name' patched on $ObjectType." -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to patch property '$Name'. $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n--- Correcting Deal Properties (Leads Pipeline) ---`n" -ForegroundColor Cyan

# 1. Update Call Outcome (Patch Options)
$OutcomeOptions = @(
    @{ label = "No Answer"; value = "no_answer"; displayOrder = 0 },
    @{ label = "Not Interested"; value = "not_interested"; displayOrder = 1 },
    @{ label = "Not a Good Time"; value = "not_a_good_time"; displayOrder = 2 },
    @{ label = "Warm"; value = "warm"; displayOrder = 3 },
    @{ label = "Hot"; value = "hot"; displayOrder = 4 },
    @{ label = "Wrong Number"; value = "wrong_number"; displayOrder = 5 },
    @{ label = "DNC (Do Not Contact)"; value = "dnc"; displayOrder = 6 }
)
Patch-Property -ObjectType "deals" -Name "call_outcome" -BodyData @{ options = $OutcomeOptions }

# 2. Recreate Automation Queue (Text -> Dropdown)
Delete-Property -ObjectType "deals" -Name "automation_queue"
$QueueOptions = @(
    @{ label = "Queue"; value = "queue"; displayOrder = 1 },
    @{ label = "Processed"; value = "processed"; displayOrder = 2 },
    @{ label = "Needs Review"; value = "needs_review"; displayOrder = 3 }
)
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "automation_queue" -Label "Automation Queue" -Type "enumeration" -FieldType "select" -Options $QueueOptions

# 3. Recreate Follow-Up Date (Text -> Date)
Delete-Property -ObjectType "deals" -Name "follow_up_date"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "follow_up_date" -Label "Follow-Up Date" -Type "date" -FieldType "date"

Write-Host "`n--- Deal Corrections Complete ---`n" -ForegroundColor Cyan

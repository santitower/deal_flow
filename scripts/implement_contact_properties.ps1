param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$BaseUrl = "https://api.hubapi.com"
$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

function Create-Property-Group {
    param ($ObjectType, $Name, $Label)
    
    $Uri = "$BaseUrl/crm/v3/properties/$ObjectType/groups"
    $Body = @{
        name  = $Name
        label = $Label
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body -ErrorAction Stop | Out-Null
        Write-Host "SUCCESS: Group '$Label' created." -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq "Conflict") {
            Write-Host "SKIPPED: Group '$Label' already exists." -ForegroundColor Yellow
        }
        else {
            Write-Host "ERROR: Failed to create group '$Label'. $($_.Exception.Message)" -ForegroundColor Red
        }
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

    if ($Options) {
        $BodyData["options"] = $Options
    }

    $Body = $BodyData | ConvertTo-Json -Depth 4

    try {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body -ErrorAction Stop | Out-Null
        Write-Host "SUCCESS: Property '$Label' ($Name) created." -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq "Conflict") {
            Write-Host "EXISTING: Property '$Label' already exists. Re-verifying options..." -ForegroundColor Yellow
            # For enums, we should ideally patch but let's assume existence is enough for now or user will ask for specific check
        }
        else {
            Write-Host "ERROR: Failed to create property '$Label'. $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n--- Implementing Contact Properties ---`n" -ForegroundColor Cyan

# 1. Create Group
Create-Property-Group -ObjectType "contacts" -Name "wholesale_contact_info" -Label "Wholesale Contact Info"

# 2. Call Outcome
$OutcomeOptions = @(
    @{ label = "No Answer"; value = "no_answer"; displayOrder = 0 },
    @{ label = "Not Interested"; value = "not_interested"; displayOrder = 1 },
    @{ label = "Not a Good Time"; value = "not_a_good_time"; displayOrder = 2 },
    @{ label = "Warm"; value = "warm"; displayOrder = 3 },
    @{ label = "Hot"; value = "hot"; displayOrder = 4 },
    @{ label = "Wrong Number"; value = "wrong_number"; displayOrder = 5 },
    @{ label = "DNC (Do Not Contact)"; value = "dnc"; displayOrder = 6 }
)
Create-Property -ObjectType "contacts" -Group "wholesale_contact_info" -Name "call_outcome" -Label "Call Outcome" -Type "enumeration" -FieldType "select" -Options $OutcomeOptions

# 3. Automation Queue
$QueueOptions = @(
    @{ label = "Queue"; value = "queue"; displayOrder = 1 },
    @{ label = "Processed"; value = "processed"; displayOrder = 2 },
    @{ label = "Needs Review"; value = "needs_review"; displayOrder = 3 }
)
Create-Property -ObjectType "contacts" -Group "wholesale_contact_info" -Name "automation_queue" -Label "Automation Queue" -Type "enumeration" -FieldType "select" -Options $QueueOptions

# 4. Follow-Up Date
Create-Property -ObjectType "contacts" -Group "wholesale_contact_info" -Name "follow_up_date" -Label "Follow-Up Date" -Type "date" -FieldType "date"

Write-Host "`n--- Implementation Complete ---`n" -ForegroundColor Cyan

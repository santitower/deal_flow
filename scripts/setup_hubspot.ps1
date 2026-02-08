param (
    [Parameter(Mandatory=$true)]
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
    } catch {
        if ($_.Exception.Response.StatusCode -eq "Conflict") {
            Write-Host "SKIPPED: Group '$Label' already exists." -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: Failed to create group '$Label'. $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Create-Property {
    param ($ObjectType, $Group, $Name, $Label, $Type, $FieldType, $Options=$null)

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
    } catch {
        if ($_.Exception.Response.StatusCode -eq "Conflict") {
            Write-Host "SKIPPED: Property '$Label' already exists." -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: Failed to create property '$Label'. $($_.Exception.Message)" -ForegroundColor Red
            # Print detailed error if available
            # Write-Host $_.Exception.Response.GetResponseStream().ReadToEnd() 
        }
    }
}

Write-Host "`n--- Starting HubSpot Configuration ---`n" -ForegroundColor Cyan

# 1. Contact Groups & Properties
Create-Property-Group -ObjectType "contacts" -Name "wholesale_contact_info" -Label "Wholesale Contact Info"

Create-Property -ObjectType "contacts" -Group "wholesale_contact_info" -Name "brokerage_name" -Label "Brokerage Name" -Type "string" -FieldType "text"

$RoleOptions = @(
    @{ label = "Owner"; value = "owner" },
    @{ label = "Listing Agent"; value = "listing_agent" },
    @{ label = "Wholesaler"; value = "wholesaler" },
    @{ label = "Property Manager"; value = "property_manager" }
)
Create-Property -ObjectType "contacts" -Group "wholesale_contact_info" -Name "contact_role" -Label "Contact Role" -Type "enumeration" -FieldType "select" -Options $RoleOptions


# 2. Deal Groups & Properties
Create-Property-Group -ObjectType "deals" -Name "wholesale_deal_data" -Label "Wholesale Deal Data"

# Core Info
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "deal_key" -Label "Deal Key" -Type "string" -FieldType "text"

$SourceOptions = @(
    @{ label = "PropStream"; value = "PropStream" },
    @{ label = "Zillow"; value = "Zillow" }
)
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "source_system" -Label "Source System" -Type "enumeration" -FieldType "select" -Options $SourceOptions

# Metrics
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "estimated_arv" -Label "Estimated ARV" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "mao" -Label "MAO" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "equity_amt" -Label "Equity Amount" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "zestimate" -Label "Zestimate" -Type "number" -FieldType "number"

# Property Details
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "property_type" -Label "Property Type" -Type "string" -FieldType "text"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "beds" -Label "Beds" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "baths" -Label "Baths" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "sqft" -Label "SqFt" -Type "number" -FieldType "number"
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "year_built" -Label "Year Built" -Type "number" -FieldType "number"

# Outcomes
$OutcomeOptions = @(
    @{ label = "No Answer"; value = "no_answer" },
    @{ label = "Left VM"; value = "left_vm" },
    @{ label = "Connected"; value = "connected" },
    @{ label = "Wrong Number"; value = "wrong_number" },
    @{ label = "Do Not Contact"; value = "dnc" }
)
Create-Property -ObjectType "deals" -Group "wholesale_deal_data" -Name "call_outcome" -Label "Call Outcome" -Type "enumeration" -FieldType "select" -Options $OutcomeOptions

Write-Host "`n--- Configuration Complete ---`n" -ForegroundColor Cyan

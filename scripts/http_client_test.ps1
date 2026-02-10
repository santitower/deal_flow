param (
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

$Uri = "https://api.hubapi.com/crm/v3/objects/contacts"
$Body = @{
    properties = @{
        email     = "anchor_test_v3@automation.internal"
        firstname = "Anchor"
        lastname  = "Test"
    }
} | ConvertTo-Json

$Client = [System.Net.Http.HttpClient]::new()
$Client.DefaultRequestHeaders.Add("Authorization", "Bearer $AccessToken")
$Content = [System.Net.Http.StringContent]::new($Body, [System.Text.Encoding]::UTF8, "application/json")

$Task = $Client.PostAsync($Uri, $Content)
$Task.Wait()
$Response = $Task.Result

Write-Host "Status: $($Response.StatusCode)" -ForegroundColor Cyan
$ReadTask = $Response.Content.ReadAsStringAsync()
$ReadTask.Wait()
$ErrorBody = $ReadTask.Result
Write-Host "Body: $ErrorBody" -ForegroundColor Yellow

$Client.Dispose()

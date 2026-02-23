param (
    [string]$WorkspacePath = "C:\Users\franc\.openclaw\workspace\INTEGRITY_CHECK.md",
    [string]$SyncPath = "c:\Development\Deal_Flow\deal_flow\workspace\INTEGRITY_CHECK.md",
    [int]$IntervalSeconds = 21600 # 6 hours
)

while ($true) {
    # Generate ONE token and apply to both paths
    $token = [guid]::NewGuid().ToString()
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    
    $content = @"
# Workspace Integrity Token

**TOKEN:** $token
**GENERATED:** $timestamp

**INSTRUCTION:** 
Benito, every time you perform a heartbeat or system check, you MUST read this file and cite the TOKEN above. 
If you cannot read this file, your session is corrupt. 
Do NOT assume the token. Read it from the disk every single time.
"@

    try {
        Set-Content -Path $WorkspacePath -Value $content -Encoding UTF8 -Force -ErrorAction Stop
        
        if ($SyncPath -and (Test-Path $SyncPath)) {
            Set-Content -Path $SyncPath -Value $content -Encoding UTF8 -Force -ErrorAction Stop
        }
        
        Write-Host "[$timestamp] Integrity token updated and synced: $token"
    }
    catch {
        Write-Error "[$timestamp] Failed to update tokens. Error: $($_.Exception.Message)"
    }

    if ($IntervalSeconds -gt 0) {
        Start-Sleep -Seconds $IntervalSeconds
    }
    else {
        break
    }
}

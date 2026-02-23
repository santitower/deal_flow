param (
    [string]$WorkspacePath = "C:\Users\franc\.openclaw\workspace\INTEGRITY_CHECK.md",
    [int]$IntervalSeconds = 21600 # 6 hours
)

function Update-IntegrityToken {
    param (
        [string]$Path
    )
    $token = [guid]::NewGuid().ToString()
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    
    $content = @"
# Workspace Integrity Token

**TOKEN:** $token
**GENERATED:** $timestamp

**INSTRUCTION:** 
Benito, every time you perform a heartbeat or system check, you MUST read this file and cite the TOKEN above. 
If you cannot find or read this file, your session may be compromised. 
Do NOT assume the token. Read it from the disk every single time.
"@

    try {
        Set-Content -Path $Path -Value $content -Encoding UTF8 -Force -ErrorAction Stop
        Write-Host "[$timestamp] Integrity token updated: $token"
    }
    catch {
        Write-Error "[$timestamp] Failed to update token: $($_.Exception.Message)"
    }
}

while ($true) {
    Update-IntegrityToken -Path $WorkspacePath
    
    if ($IntervalSeconds -gt 0) {
        Start-Sleep -Seconds $IntervalSeconds
    }
    else {
        break
    }
}

param (
    [string]$ConfigPath = "C:\Users\franc\.openclaw\openclaw.json",
    [int]$IntervalSeconds = 60,
    [int]$UpperThresholdMB = 15000, # Switch to CPU if usage exceeds this
    [int]$LowerThresholdMB = 5000   # Switch back to GPU if usage drops below this
)

function Get-VramUsage {
    try {
        $usage = nvidia-smi --query-gpu=memory.used --format=csv, noheader, nounits -ErrorAction Stop
        return [int]$usage
    }
    catch {
        return 0
    }
}

function Set-Model ([string]$ModelId) {
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        if ($config.agents.defaults.model.primary -ne $ModelId) {
            $config.agents.defaults.model.primary = $ModelId
            $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8
            Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Switched primary model to $ModelId"
            
            # Trigger gateway reload (gateway.cmd handles the restart loop)
            Get-Process node | Where-Object { $_.Path -like "*openclaw*" } | Stop-Process -Force
        }
    }
}

while ($true) {
    $usage = Get-VramUsage
    
    if ($usage -gt $UpperThresholdMB) {
        Set-Model "ollama/qwen2.5:3b-cpu"
    }
    elseif ($usage -lt $LowerThresholdMB) {
        Set-Model "ollama/qwen2.5:14b-48k"
    }

    if ($IntervalSeconds -gt 0) {
        Start-Sleep -Seconds $IntervalSeconds
    }
    else {
        break
    }
}

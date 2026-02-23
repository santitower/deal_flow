param (
    [string]$LogPath = "C:\Users\franc\.openclaw\logs\gateway.log",
    [string]$ConfigPath = "C:\Users\franc\.openclaw\openclaw.json",
    [string]$ChatId = "-5272386633",
    [int]$ThresholdMinutes = 20
)

function Send-TelegramAlert ([string]$Message) {
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $token = $config.channels.telegram.botToken
        if ($token) {
            $url = "https://api.telegram.org/bot$token/sendMessage"
            $body = @{
                chat_id = $ChatId
                text    = $Message
            }
            Invoke-RestMethod -Uri $url -Method Post -Body $body
        }
    }
}

while ($true) {
    if (Test-Path $LogPath) {
        $lastHeartbeat = Get-Content $LogPath -Tail 500 | Where-Object { $_ -like "*HEARTBEAT_OK*" } | Select-Object -Last 1
        
        if ($lastHeartbeat) {
            if ($lastHeartbeat -match "\[(.*?)\]") {
                $tsString = $matches[1]
                try {
                    $cleanTs = $tsString -replace "^\w+\s+", ""
                    $ts = [datetime]::ParseExact($cleanTs, "MM/dd/yyyy HH:mm:ss.ff", $null)
                    $diff = (Get-Date) - $ts
                    
                    if ($diff.TotalMinutes -gt $ThresholdMinutes) {
                        Send-TelegramAlert "⚠️ Benito Warning: No successful heartbeat detected in $ThresholdMinutes minutes. Gateway may be stalled."
                    }
                }
                catch {
                    # Fallback parse for different cultures
                }
            }
        }
    }
    
    if ($ThresholdMinutes -gt 0) {
        Start-Sleep -Seconds 300
    }
    else {
        break
    }
}

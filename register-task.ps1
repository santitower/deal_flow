#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Register (or re-register) the OpenClaw Gateway scheduled task.
    Run this once from an elevated PowerShell prompt.
.NOTES
    Consolidated from register-task{1-4}.ps1.  Uses XML import for
    maximum compatibility with Task Scheduler 1.4.
#>

$ErrorActionPreference = "Stop"
$taskName   = "OpenClaw Gateway"
$xmlPath    = "C:\Users\franc\.openclaw\openclaw-gateway-task.xml"
$logFile    = "C:\Users\franc\.openclaw\logs\task-register.log"

function Log($msg) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
    Write-Host $line
    $line | Out-File $logFile -Append -Encoding utf8
}

try {
    # Ensure logs dir exists
    $logsDir = Split-Path $logFile
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }

    Log "=== OpenClaw Gateway Task Registration ==="

    # 1. Remove existing task
    Log "Removing existing task (if any)..."
    schtasks /delete /tn $taskName /f 2>&1 | Out-Null
    Start-Sleep 1

    # 2. Verify XML exists
    if (-not (Test-Path $xmlPath)) {
        throw "Task XML not found at: $xmlPath"
    }
    Log "Using XML: $xmlPath"

    # 3. Register via schtasks /xml (most reliable method)
    $result = schtasks /create /tn $taskName /xml $xmlPath /f 2>&1
    Log "schtasks result: $result"

    # 4. Verify registration
    $verify = schtasks /query /tn $taskName /fo LIST 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Task registration failed — not found after create."
    }
    Log "Verification: Task found."

    # 5. Optionally start it now
    $startNow = Read-Host "Start the task now? (y/N)"
    if ($startNow -eq 'y') {
        schtasks /run /tn $taskName 2>&1 | Out-Null
        Log "Task started."
    }

    Log "SUCCESS: '$taskName' registered and will auto-start at logon."
    Write-Host "`nDone. The gateway will start automatically at logon." -ForegroundColor Green

} catch {
    Log "ERROR: $($_.Exception.Message)"
    Write-Host "`nFailed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

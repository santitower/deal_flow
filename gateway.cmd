@echo off
setlocal enabledelayedexpansion
title OpenClaw Gateway
rem ================================================================
rem  OpenClaw Gateway (v2026.2.19-3)
rem  Robust auto-start with port-conflict resolution, Ollama
rem  health monitoring, structured logging, and health checks.
rem ================================================================
set "TMPDIR=C:\Users\franc\AppData\Local\Temp"
set "PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\NVIDIA Corporation\NVIDIA App\NvDLISR;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\Go\bin;C:\Users\franc\AppData\Local\Microsoft\WindowsApps;C:\Users\franc\AppData\Roaming\npm;C:\Users\franc\AppData\Local\Programs\Antigravity\bin;C:\Users\franc\go\bin;C:\Users\franc\AppData\Local\Programs\Ollama;C:\Users\franc\AppData\Local\Python\bin"

set "GATEWAY_PORT=18789"
set "MAX_RETRIES=10"
set "RETRY_DELAY=15"
set "LOGFILE=C:\Users\franc\.openclaw\logs\gateway.log"
set "OPENCLAW_HOME=C:\Users\franc\.openclaw"

rem --- Ollama optimization env vars ---
set "OLLAMA_KV_CACHE_TYPE=q8_0"
set "OLLAMA_FLASH_ATTENTION=1"
set "OLLAMA_NUM_PARALLEL=1"
set "OLLAMA_KEEP_ALIVE=30m"

rem --- Create logs dir if needed ---
if not exist "C:\Users\franc\.openclaw\logs" mkdir "C:\Users\franc\.openclaw\logs"

rem --- Rotate log if > 5 MB ---
if exist "%LOGFILE%" (
    for %%A in ("%LOGFILE%") do (
        if %%~zA gtr 5242880 (
            if exist "%LOGFILE%.2" del "%LOGFILE%.2"
            if exist "%LOGFILE%.1" move /Y "%LOGFILE%.1" "%LOGFILE%.2" >nul
            move /Y "%LOGFILE%" "%LOGFILE%.1" >nul
            echo [%date% %time%] Log rotated. > "%LOGFILE%"
        )
    )
)

call :log "================================================================"
call :log "OpenClaw Gateway starting (v2026.2.19-3)"
call :log "================================================================"

rem ============================================================
rem  1. Ensure Ollama is running (up to 3 attempts)
rem ============================================================
call :log "Checking Ollama..."
set "OLLAMA_ATTEMPTS=0"
:ollama_check
set /a OLLAMA_ATTEMPTS+=1
"C:\Users\franc\AppData\Local\Programs\Ollama\ollama.exe" list >nul 2>&1
if not errorlevel 1 (
    call :log "Ollama ready."
    goto :ollama_done
)
if !OLLAMA_ATTEMPTS! geq 3 (
    call :log "WARNING: Ollama not responding after 3 attempts. Gateway may fail on first LLM call."
    goto :ollama_done
)
call :log "Ollama not running — starting (attempt !OLLAMA_ATTEMPTS!/3)..."
start "" /B "C:\Users\franc\AppData\Local\Programs\Ollama\ollama.exe" serve
timeout /t 10 /nobreak >nul
goto :ollama_check
:ollama_done

rem ============================================================
rem  2. Free port %GATEWAY_PORT% if a stale process holds it
rem     Only kills node.exe processes (safe — won't kill unrelated)
rem ============================================================
call :free_port

rem ============================================================
rem  3. Launch gateway with retry loop
rem ============================================================
set "OPENCLAW_GATEWAY_PORT=%GATEWAY_PORT%"
set "OPENCLAW_GATEWAY_TOKEN=%OPENCLAW_GATEWAY_TOKEN%"
set "OPENCLAW_SYSTEMD_UNIT=openclaw-gateway.service"
set "OPENCLAW_SERVICE_MARKER=openclaw"
set "OPENCLAW_SERVICE_KIND=gateway"
set "OPENCLAW_SERVICE_VERSION=2026.2.19-3"

set "ATTEMPT=0"
:retry
set /a ATTEMPT+=1
echo.
call :log "=== Starting OpenClaw Gateway (attempt !ATTEMPT!/%MAX_RETRIES%) ==="
"C:\Program Files\nodejs\node.exe" C:\Users\franc\AppData\Roaming\npm\node_modules\openclaw\dist\index.js gateway --port %GATEWAY_PORT%

rem --- If we reach here, the process exited ---
set "EXIT_CODE=%ERRORLEVEL%"
call :log "Gateway exited with code !EXIT_CODE!."

if !ATTEMPT! geq %MAX_RETRIES% (
    call :log "Max retries (%MAX_RETRIES%) reached. Giving up."
    goto :done
)

rem --- Exponential backoff: delay * attempt, capped at 120s ---
set /a BACKOFF=RETRY_DELAY * ATTEMPT
if !BACKOFF! gtr 120 set "BACKOFF=120"
call :log "Retrying in !BACKOFF! seconds (attempt !ATTEMPT!)..."
timeout /t !BACKOFF! /nobreak >nul

rem --- Clean up port again before retry ---
call :free_port
goto :retry

:done
call :log "Gateway stopped permanently after !ATTEMPT! attempts."
endlocal
exit /b

rem ============================================================
rem  SUBROUTINE: Free port — only kills node.exe holding the port
rem ============================================================
:free_port
call :log "Checking port %GATEWAY_PORT%..."
set "PORT_FREED=0"
for /f "tokens=5" %%p in ('netstat -aon ^| findstr "LISTENING" ^| findstr ":%GATEWAY_PORT% "') do (
    set "STALE_PID=%%p"
    rem Verify it's a node process before killing
    for /f "tokens=*" %%n in ('tasklist /FI "PID eq %%p" /FO CSV /NH 2^>nul') do (
        echo %%n | findstr /i "node.exe" >nul 2>&1
        if not errorlevel 1 (
            call :log "Port %GATEWAY_PORT% held by node.exe PID %%p — killing stale gateway..."
            taskkill /F /PID %%p >nul 2>&1
            set "PORT_FREED=1"
        ) else (
            call :log "WARNING: Port %GATEWAY_PORT% held by non-node process PID %%p — NOT killing. Check manually."
        )
    )
)
if "!PORT_FREED!"=="1" (
    timeout /t 3 /nobreak >nul
    call :log "Stale process killed, port should be free."
) else (
    call :log "Port %GATEWAY_PORT% is free."
)
exit /b

rem ============================================================
rem  SUBROUTINE: Structured logging to console + file
rem ============================================================
:log
set "MSG=[%date% %time%] %~1"
echo !MSG!
echo !MSG! >> "%LOGFILE%"
exit /b

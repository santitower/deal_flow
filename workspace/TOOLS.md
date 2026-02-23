# TOOLS.md - Local Infrastructure Notes

This file documents the specifics of this OpenClaw instance's environment.

## Machine: THETOWER

- **OS:** Windows
- **User:** franc (THETOWER\franc)
- **OpenClaw Home:** `C:\Users\franc\.openclaw`

## Gateway

- **Port:** 18789 (loopback only — not exposed to network)
- **Auth:** Token-based (`gateway.auth.mode: token`)
- **Auto-start:** Windows Startup folder shortcut → `gateway.cmd`
- **Crash recovery:** Retry loop (10 attempts, exponential backoff up to 120s)
- **Port conflict:** Auto-kills stale node.exe processes holding port 18789

## Ollama (Local LLM)

- **Install:** `C:\Users\franc\AppData\Local\Programs\Ollama\`
- **API:** `http://127.0.0.1:11434`
- **Optimization flags:**
  - `OLLAMA_KV_CACHE_TYPE=q8_0` (quantized KV cache)
  - `OLLAMA_FLASH_ATTENTION=1` (faster inference)
  - `OLLAMA_NUM_PARALLEL=1` (single concurrent request)
  - `OLLAMA_KEEP_ALIVE=30m` (keep model loaded 30 min)

### Available Models

| Model | Type | Notes |
|-------|------|-------|
| qwen2.5:14b-48k | **Primary** | GPU, 48K context custom Modelfile |
| qwen2.5:3b-cpu | **Fallback** | CPU-only, lightweight |
| deepseek-r1:14b | Reasoning | Chain-of-thought |
| phi4:14b | General | Microsoft |
| codestral:22b | Code | Mistral, larger |
| gemma3:12b | General | Google |
| llama3.1:8b | General | Meta |
| nomic-embed-text | Embedding | Memory search |

## Telegram

- **Bot:** Enabled, token configured
- **DM Policy:** Pairing (requires explicit approval)
- **Group Policy:** Allowlist
- **Stream Mode:** Partial
- **Allowed Users:** 2

## Modelfiles (Custom Ollama Configs)

- `Modelfile.deepseek-r1-14b-cpu` — CPU-optimized deepseek
- `Modelfile.qwen25-14b-48k` — Extended context qwen2.5
- `Modelfile.qwen25-3b-cpu` — CPU-optimized qwen2.5 3b

## Key File Locations

- **Gateway script:** `gateway.cmd`
- **Config:** `openclaw.json`
- **System Logs:** `C:\Users\franc\.openclaw\logs\gateway.log`
- **Config Audit:** `C:\Users\franc\.openclaw\logs\config-audit.jsonl`
- **Sessions:** `agents/main/sessions/`
- **Credentials:** `credentials/`
- **Device identity:** `identity/device.json`
## Maintenance & Survival

- **System Repair:** `openclaw doctor --repair` (fixes gateway, services, and configs)
- **Log Review:** Check `logs\gateway.log` for error codes.
- **Stability Protocol:** If you detect a service failure (gateway exit, OOM), you are authorized to run `openclaw doctor --repair` and `openclaw gateway restart`.
- **Integrity Sidecar:** `scripts\integrity-sidecar.ps1` rotates the token every 6 hours.
## Context & Memory

- **Max Context:** 49,152 tokens (48k)
- **Compaction Threshold:** 39,000 tokens (80%)
- **Monitoring:** Check the latest `totalTokens` in your active session file in `agents/main/sessions/`. The filename matches your current `sessionId` from `sessions.json`.
- **Compaction Procedure:** If threshold reached → Summarize state to `memory/YYYY-MM-DD.md` → Notify User → Restart Session.

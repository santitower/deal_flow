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
| qwen2.5:14b-64k | **Primary** | GPU, 64K context custom Modelfile |
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
- `Modelfile.qwen25-14b-64k` — Extended context qwen2.5
- `Modelfile.qwen25-3b-cpu` — CPU-optimized qwen2.5 3b

## Key File Locations

- **Gateway script:** `gateway.cmd`
- **Config:** `openclaw.json`
- **Logs:** `logs/gateway.log`, `logs/config-audit.jsonl`
- **Sessions:** `agents/main/sessions/`
- **Credentials:** `credentials/`
- **Device identity:** `identity/device.json`

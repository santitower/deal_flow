# MEMORY.md - Long-Term Memory

_Curated memories and lessons. Updated periodically from daily notes._

## 2026-02-21 — Initial Setup & Hardening

### Infrastructure
- OpenClaw deployed on THETOWER (Windows) with local Ollama backend
- Primary model: `qwen2.5:14b-64k` (GPU), fallback: `qwen2.5:3b-cpu`
- Gateway on port 18789 (loopback only), token auth
- Telegram bot configured with 2 allowed users
- Auto-start via Windows Startup folder shortcut (scheduled task registration needs admin elevation)

### Hardening Applied
- `gateway.cmd` upgraded: log rotation, structured logging to `logs/gateway.log`, exponential backoff (up to 120s), 10 retries (was 5)
- Port conflict handling improved: now verifies process is `node.exe` before killing, warns on non-node processes
- Ollama startup retries increased to 3 attempts (was 1)
- register-task.ps1 consolidated (was 4 redundant scripts)
- Workspace .md files populated with actual configuration details

### Identity Established
- Agent name: **Benito** 🤖
- Human name: **Santi**
- IDENTITY.md, USER.md customized by Santi with detailed operational profile
- SOUL.md personalized: infrastructure-grade operating contract, no-fluff communication style, structured reasoning emphasis
- BOOTSTRAP.md deleted — all bootstrap steps complete

### Known Limitations
- Scheduled task requires UAC elevation to register — using Startup folder shortcut as workaround
- Bot token and gateway auth token are in plaintext in `openclaw.json` and `gateway.cmd`
- No external health monitoring (only internal retry loop)
- Ollama only checked at gateway boot, not periodically during runtime

---

_This file is for main session use only. Do not load in shared/group contexts._

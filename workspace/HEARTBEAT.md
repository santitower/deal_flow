```
# HEARTBEAT.md

## Periodic Checks

1. **Integrity Check** — Read `INTEGRITY_CHECK.md`. Cite the current **TOKEN** in your response. If you cannot read the file, do NOT proceed.
2. **Gateway health** — Run `openclaw gateway status`. Verify port 18789 is listening.
3. **Ollama health** — Can you reach `http://127.0.0.1:11434/api/tags`? 
4. **System Logs** — Check `C:\Users\franc\.openclaw\logs\gateway.log` for recent errors. Do NOT assume the path; it is defined in `TOOLS.md`.
5. **Context Check** — Read your current session's `.jsonl` file (path in `sessions.json`). If `totalTokens` > 39,000, trigger **Auto-Compaction** (see `IDENTITY.md`).
6. **Memory maintenance** — Review recent `memory/YYYY-MM-DD.md` files. Update `MEMORY.md` if needed.

## Rules

- If all checks pass: reply `HEARTBEAT_OK`
- If something needs attention: report it clearly
- Quiet hours (23:00–08:00): only report critical issues
- Don't repeat the same issue across consecutive heartbeats

# HEARTBEAT.md

## Periodic Checks (rotate through these)

1. **Gateway health** — Is port 18789 listening? If not, note it.
2. **Ollama health** — Can you reach `http://127.0.0.1:11434/api/tags`? How many models loaded?
3. **Memory maintenance** — Review recent `memory/YYYY-MM-DD.md` files. Update `MEMORY.md` if needed.
4. **Session cleanup** — Are there stale sessions older than 7 days?

## Rules

- If all checks pass: reply `HEARTBEAT_OK`
- If something needs attention: report it clearly
- Quiet hours (23:00–08:00): only report critical issues
- Don't repeat the same issue across consecutive heartbeats

# TASKS.md - Persistent Task Tracking

This file tracks ongoing tasks, reminders, and projects. The agent can read and update this during heartbeats or when explicitly asked.

## 🔥 Today

- [x] Set up task scheduling infrastructure
- [ ] Review open items from 2026-02-21 daily notes

## 📅 This Week

- [ ] Test gateway recovery from simulated crash
- [ ] Consider moving secrets out of plaintext config files
- [ ] Clean up redundant register-task scripts (2, 3, 4)

## 🔄 Recurring

- Weekly backup check (automated via cron)
- Daily system health verification (automated via heartbeat)

## 📦 Backlog

- [ ] Add external health monitoring
- [ ] Implement credential encryption/vault
- [ ] Document HubSpot integration workflows

## ✅ Completed

- [x] Populate workspace documentation (IDENTITY, USER, TOOLS, MEMORY, SOUL)
- [x] Harden gateway.cmd with better error handling
- [x] Set up Telegram pairing (2 users approved)
- [x] Configure Ollama models (qwen2.5:14b-64k primary)

---

**Usage Tips:**
- Agent checks this file during heartbeats
- Update status freely: [ ] → [x]
- Move completed items to "✅ Completed" section
- Archive old completed items to daily memory files

**Quick Add:** To add a task via Telegram, just say "add task: <description>" or "remind me to <action>"

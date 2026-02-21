# SCHEDULING.md - Task Scheduling Guide

Complete guide to scheduling tasks and reminders using OpenClaw's built-in scheduling system.

## 🔀 Three Ways to Schedule

### 1. **Heartbeat** (Batch periodic checks)
- **File:** `HEARTBEAT.md`
- **Interval:** ~30 minutes (approximate)
- **Use for:** Multiple quick checks that can batch together
- **Example:** Email check, calendar review, system health
- **Pros:** Low overhead, conversational context available
- **Cons:** Imprecise timing, shares main session history

### 2. **Cron Jobs** (Precise schedules)
- **Command:** `openclaw cron add`
- **Interval:** Flexible (cron expressions, every X duration, one-shot)
- **Use for:** Exact timing, isolated tasks, reminders
- **Example:** "9 AM every Monday", "in 20 minutes", "every 2 hours"
- **Pros:** Precise, isolated, can use different models
- **Cons:** More setup, separate from main session

### 3. **System Events** (Immediate triggers)
- **Command:** `openclaw system event`
- **Interval:** Immediate or next heartbeat
- **Use for:** React to external events, manual triggers
- **Example:** "New email arrived", "Deploy completed"
- **Pros:** Instant response, flexible
- **Cons:** Requires external integration

---

## 📅 Cron Job Patterns

### Common Schedules

```bash
# Every 10 minutes
openclaw cron add --name "Check X" --every 10m --agent main --message "Check X"

# Every hour at :15
openclaw cron add --name "Hourly Task" --cron "15 * * * *" --agent main --message "Do task"

# Daily at 9 AM
openclaw cron add --name "Morning Brief" --cron "0 9 * * *" --agent main --message "Daily briefing"

# Monday at 10 AM
openclaw cron add --name "Weekly Review" --cron "0 10 * * 1" --agent main --message "Weekly review"

# Weekdays at 5 PM
openclaw cron add --name "EOD Summary" --cron "0 17 * * 1-5" --agent main --message "End of day summary"

# One-shot (20 minutes from now)
openclaw cron add --name "Reminder" --at "+20m" --message "Check that thing" --delete-after-run

# One-shot (specific time)
openclaw cron add --name "Meeting Reminder" --at "2026-02-21T14:30:00" --message "Meeting in 5 min" --delete-after-run
```

### Cron Expression Syntax

```
┌───────────── second (0-59, optional)
│ ┌───────────── minute (0-59)
│ │ ┌───────────── hour (0-23)
│ │ │ ┌───────────── day of month (1-31)
│ │ │ │ ┌───────────── month (1-12)
│ │ │ │ │ ┌───────────── day of week (0-7, 0 and 7 = Sunday)
│ │ │ │ │ │
* * * * * *
```

**Examples:**
- `0 9 * * *` — 9 AM daily
- `30 14 * * 1` — 2:30 PM every Monday
- `0 */2 * * *` — Every 2 hours
- `0 0 1 * *` — Midnight on the 1st of each month
- `0 9 * * 1-5` — 9 AM weekdays only

---

## 🎯 Delivery Options

### Announce to Chat
```bash
# Summarize result and send to Telegram
openclaw cron add --name "Brief" --cron "0 9 * * *" \
  --agent main --message "Morning brief" \
  --announce --channel telegram --to @YourChat
```

### Silent Execution
```bash
# Run without delivering anywhere (logs only)
openclaw cron add --name "Maintenance" --every 1h \
  --agent main --message "Check health" \
  --no-deliver
```

### Best-Effort Delivery
```bash
# Don't fail job if delivery fails
openclaw cron add --name "Status" --cron "0 * * * *" \
  --message "Status update" --announce \
  --best-effort-deliver
```

---

## 🛠️ Management Commands

```bash
# List all jobs
openclaw cron list

# Run a job now (testing)
openclaw cron run <job-id>

# Show job execution history
openclaw cron runs

# Edit a job
openclaw cron edit <job-id> --cron "0 10 * * *"

# Disable temporarily
openclaw cron disable <job-id>

# Re-enable
openclaw cron enable <job-id>

# Delete permanently
openclaw cron rm <job-id>

# Check scheduler status
openclaw cron status
```

---

## 💡 Best Practices

### When to Use What

**Use Heartbeat for:**
- Checking email/calendar/notifications together
- Tasks that can drift by ±15 minutes
- Things you want conversational context for
- Combining multiple quick checks into one turn

**Use Cron for:**
- "9 AM sharp every Monday" precision
- One-shot reminders ("in 20 minutes")
- Tasks needing different models/thinking levels
- Isolated execution without main session pollution
- Delivering results directly to chat without agent involvement

**Use System Events for:**
- External triggers (webhooks, file watches)
- Manual "run this now" commands
- Reacting to state changes

### Efficiency Tips

1. **Batch checks:** Use heartbeat instead of 5 separate cron jobs
2. **Stagger cron jobs:** Use `--stagger 5m` to avoid thundering herd
3. **Set timeouts:** Use `--timeout-seconds 30` for long-running tasks
4. **Use best-effort:** Add `--best-effort-deliver` when delivery isn't critical
5. **Clean up one-shots:** Use `--delete-after-run` for reminders

### Example Workflow

```bash
# Morning routine (9 AM daily)
openclaw cron add --name "Morning Routine" \
  --cron "0 9 * * *" \
  --agent main \
  --message "Read TASKS.md. What's on the agenda today?" \
  --announce --channel telegram

# Hourly health check (via heartbeat, not cron)
# → Already handled by HEARTBEAT.md

# End of day summary (5 PM weekdays)
openclaw cron add --name "EOD Summary" \
  --cron "0 17 * * 1-5" \
  --agent main \
  --message "Summarize what we accomplished today based on memory files" \
  --announce

# Weekly backup reminder
openclaw cron add --name "Backup Reminder" \
  --cron "0 10 * * 1" \
  --message "Don't forget weekly system backup" \
  --announce --channel telegram
```

---

## 🔍 Debugging

```bash
# Check if scheduler is running
openclaw cron status

# See recent job runs
openclaw cron runs

# Test a job immediately
openclaw cron run <job-id>

# Check gateway logs
openclaw logs

# Verify gateway is responding
openclaw health
```

---

**Quick Reference:** Save common commands in `completions/` folder for shell autocomplete!

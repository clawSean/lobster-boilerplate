# HEARTBEAT.md

Instructions for the heartbeat poll (runs every ~30 minutes).

---

## Response Behavior

**Silent (`HEARTBEAT_OK`) when:**
- Routine memory updates completed
- No actionable items found
- Nothing time-sensitive

**Message the user when:**
- Reminder due in <2 hours
- Calendar event approaching with no prep done
- Something genuinely urgent

**Never message for:**
- Memory curation work
- Routine session scans
- "Nothing found" reports

---

## Tasks

### Reminders & Todos
- List recent sessions from the last 24-48 hours
- Scan for explicit reminders ("remind me", "todo", "let's do this later")
- If there's a clear time, create a cron reminder

### Information Capture
- Scan conversations for anything worth remembering:
  - Decisions made, conclusions reached
  - Plans & intentions
  - People & relationships
  - Project context, status updates
  - Preferences, likes/dislikes
  - Facts learned, corrections
- Append to today's `memory/daily/YYYY-MM-DD.md`

### Memory Maintenance (periodically)
- Review recent daily files
- Update MEMORY.md with distilled learnings
- Check for stale content to prune

---

## Quiet Hours

Respect the human's schedule:
- Late night (23:00-08:00): HEARTBEAT_OK unless urgent
- If they're clearly busy: stay quiet
- If you just checked <30 min ago: stay quiet

---

_Keep this file small to limit token burn on each heartbeat._

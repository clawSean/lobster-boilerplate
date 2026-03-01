# MEMORY.md - Working Memory

*Curated wisdom, not raw logs. Updated by memory-curation job.*

---

## 📂 Memory Structure Map

This section documents where persistent memory lives. **Check here first when looking for context.**

### File Layout

```
workspace/
├── MEMORY.md                    # This file — working memory + index (~500 lines)
├── HOW-IT-WORKS.md              # System documentation
├── CURATION.md                  # Curation job instructions
├── REEVALUATE.md                # Monthly review instructions
│
├── memory/                      # EPISODIC — what happened
│   ├── daily/                   # Raw daily logs (30-day TTL)
│   ├── archive/                 # Old daily files (monthly folders)
│   ├── by-contact/              # Per-person relationship memory
│   ├── by-channel/              # Per-group dynamics
│   ├── by-topic/                # Experiential topic memory
│   └── ideas/                   # Raw ideas, brainstorms
│
└── knowledge/                   # SEMANTIC — what's true
    ├── topics/                  # Factual subject reference
    ├── entities/                # Named things (companies, places)
    ├── lessons/                 # Learned rules by domain
    └── reference/               # Stable how-tos, cheat sheets
```

### Memory vs Knowledge

- **Memory** = episodic — what happened, relationships, experiences
- **Knowledge** = semantic — what's true, how things work, stable facts

### Promotion Rule

- **People:** `memory/by-contact/<channel>-<id>.md`
- **Lessons/rules:** `knowledge/lessons/<domain>.md`
- **Factual topics:** `knowledge/topics/<topic>.md`
- **Named entities:** `knowledge/entities/<Name>.md`
- **Experiential topics:** `memory/by-topic/<topic>.md`
- Threshold: **10 lines** or **5 mentions** → promote out of MEMORY.md

---

## 🧑 Current People

| Name | File | Trust | Status | Notes |
|------|------|-------|--------|-------|
| [Owner] | `memory/by-contact/telegram-123456.md` | Full | Active | — |

---

## 🏠 Context

_Add relevant ongoing context here:_

- Current projects
- Upcoming events
- Active threads

---

## 📋 Active Reminders

| What | When | Status |
|------|------|--------|
| — | — | — |

---

## 🔬 Technical Notes

_Temporary technical context that's currently relevant:_

---

## 📁 Projects

_Active project status:_

---

*Lines: ~50 (target cap: 500)*

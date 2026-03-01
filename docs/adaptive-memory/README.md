# Adaptive Memory System

**A cognitive architecture for persistent AI agents**

This folder contains a complete memory system implementation based on the four memory systems from cognitive psychology: Working, Episodic, Semantic, and Procedural memory.

---

## Quick Start

1. Copy the `foundation/` files to your agent's workspace
2. Copy the `system/` files for memory operations
3. Customize each file for your agent's identity and use case
4. Set up cron jobs for automated memory maintenance
5. Read `HOW-IT-WORKS.md` for the full architecture

---

## Contents

### [HOW-IT-WORKS.md](./HOW-IT-WORKS.md)
The complete architecture documentation. Start here to understand the system.

### Foundation Files (`foundation/`)
These define who the agent is and how it operates:

| File | Purpose |
|------|---------|
| `SOUL.md` | Core values, personality, boundaries |
| `IDENTITY.md` | Name, appearance, voice |
| `USER.md` | Information about the human(s) being helped |
| `AGENTS.md` | Operating guidelines, session loading rules |
| `TOOLS.md` | Environment-specific notes, credentials locations |

### System Files (`system/`)
These control how memory flows and gets processed:

| File | Purpose |
|------|---------|
| `MEMORY.md` | Working memory + index to everything (~500 line cap) |
| `HEARTBEAT.md` | Instructions for the 30-min heartbeat job |
| `CURATION.md` | Routing decision tree for the 5-hour curation job |
| `COMPILE.md` | Weekly pruning and graduation instructions |
| `REEVALUATE.md` | Monthly system audit and skill review |

### Templates (`templates/`)
Example files for per-entity storage:

| File | Purpose |
|------|---------|
| `_EXAMPLE-contact.md` | Template for per-person memory |
| `_EXAMPLE-channel.md` | Template for per-group memory |
| `_EXAMPLE-topic.md` | Template for topic/knowledge files |

---

## Directory Structure

After setup, your workspace should look like:

```
workspace/
├── SOUL.md, IDENTITY.md, USER.md    # Who the agent is
├── AGENTS.md, TOOLS.md               # How it operates
├── MEMORY.md                         # Working memory + index
├── HEARTBEAT.md                      # Heartbeat instructions
├── CURATION.md                       # Curation instructions
├── COMPILE.md                        # Weekly compile instructions
├── REEVALUATE.md                     # Monthly review instructions
│
├── memory/                           # Episodic (what happened)
│   ├── daily/                        # Raw daily logs
│   ├── by-contact/                   # Per-person memory
│   ├── by-channel/                   # Per-group memory
│   ├── by-topic/                     # Experiential topics
│   └── ideas/                        # Raw brainstorms
│
├── knowledge/                        # Semantic (what's true)
│   ├── topics/                       # Factual reference
│   ├── entities/                     # Named things
│   ├── lessons/                      # Learned rules
│   └── reference/                    # Stable docs
│
└── skills/                           # Procedural (how to do things)
```

---

## Configuration

See `HOW-IT-WORKS.md` for detailed configuration guidance, including:

- **Premier models** for structural work
- **`dmScope: per-channel-peer`** for per-contact memory isolation
- **Isolated sessions** for cron jobs

---

## Academic Foundation

This architecture implements the four memory systems from cognitive psychology:

- **Tulving (1972)** — Episodic vs semantic memory
- **Baddeley & Hitch (1974)** — Working memory model
- **Squire (2004)** — Long-term memory taxonomy

Reference implementation: [ALucek/agentic-memory](https://github.com/ALucek/agentic-memory)

---

*Part of the [Lobster Boilerplate](https://github.com/clawSean/lobster-boilerplate) project*

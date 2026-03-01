# The OpenClaw Memory System

**A cognitive architecture for persistent AI agents**

---

## The Problem

Large language models have no persistent memory. Each conversation starts fresh. This creates a fundamental limitation: the AI cannot learn from experience, remember relationships, or accumulate knowledge over time.

For an AI assistant to feel like a *someone* rather than a *something*, it needs:

- **Continuity** — remembering what happened yesterday, last week, last month
- **Relationships** — knowing who people are, how they communicate, what they care about
- **Learning** — extracting lessons from mistakes and successes
- **Knowledge** — accumulating facts and expertise over time

This document describes a complete memory system that solves these problems.

---

## Theoretical Foundation: The Four Memory Systems

Cognitive psychology identifies four distinct memory systems in humans. This architecture implements all four:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│                        THE FOUR MEMORY SYSTEMS                             │
│                    (Tulving, 1972; Squire, 2004)                           │
│                                                                            │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐       │
│   │    WORKING      │    │    EPISODIC     │    │    SEMANTIC     │       │
│   │    MEMORY       │    │    MEMORY       │    │    MEMORY       │       │
│   ├─────────────────┤    ├─────────────────┤    ├─────────────────┤       │
│   │ Current context │    │ Personal events │    │ Facts & concepts│       │
│   │ Limited capacity│    │ Autobiographical│    │ General knowledge       │
│   │ Immediate focus │    │ Time-stamped    │    │ Context-free    │       │
│   └─────────────────┘    └─────────────────┘    └─────────────────┘       │
│           │                      │                      │                 │
│           ▼                      ▼                      ▼                 │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐       │
│   │   MEMORY.md     │    │    memory/      │    │   knowledge/    │       │
│   │   (~500 lines)  │    │   daily/        │    │   topics/       │       │
│   │   Session ctx   │    │   by-contact/   │    │   entities/     │       │
│   │                 │    │   by-channel/   │    │   lessons/      │       │
│   └─────────────────┘    └─────────────────┘    └─────────────────┘       │
│                                                                            │
│   ┌─────────────────────────────────────────────────────────────┐         │
│   │                     PROCEDURAL MEMORY                        │         │
│   ├─────────────────────────────────────────────────────────────┤         │
│   │  Skills, habits, rules — "how to do things"                  │         │
│   │  Implicit knowledge that guides behavior                     │         │
│   └─────────────────────────────────────────────────────────────┘         │
│                                  │                                         │
│                                  ▼                                         │
│   ┌─────────────────────────────────────────────────────────────┐         │
│   │  SOUL.md │ IDENTITY.md │ AGENTS.md │ skills/*/SKILL.md      │         │
│   └─────────────────────────────────────────────────────────────┘         │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### 1. Working Memory
**Psychology:** The cognitive system that holds information temporarily for processing. Limited capacity (~7 items), immediate focus, constantly updated.

**Implementation:** `MEMORY.md` + current session context
- Capped at ~500 lines to respect capacity limits
- Contains "hot" items needed for immediate tasks
- Serves as index to retrieve from other memory systems
- Updated continuously during conversations

### 2. Episodic Memory
**Psychology:** Autobiographical memory for personal experiences and events. Time-stamped, contextual, answers "what happened to me."

**Implementation:** `memory/` directory
- `daily/` — Raw experience logs, timestamped
- `by-contact/` — Relationship histories with specific people
- `by-channel/` — Experiences within specific groups
- `by-topic/` — Personal journeys with subjects (opinions, preferences)
- `ideas/` — Creative moments captured in time

### 3. Semantic Memory
**Psychology:** General world knowledge independent of personal experience. Facts, concepts, meanings — answers "what is true."

**Implementation:** `knowledge/` directory
- `topics/` — How things work (APIs, protocols, systems)
- `entities/` — What things are (companies, places, products)
- `lessons/` — Distilled rules from experience
- `reference/` — Stable documentation, how-tos

### 4. Procedural Memory
**Psychology:** Implicit memory for skills and habits. "How to do things" — often automatic, hard to verbalize explicitly.

**Implementation:** Foundation files + skills
- `SOUL.md` — Core values, personality, boundaries
- `IDENTITY.md` — Self-concept, appearance, voice
- `AGENTS.md` — Operating procedures, behavioral rules
- `skills/*/SKILL.md` — Specific capabilities and how to use them

---

### The Four Systems Working Together

```
┌──────────────────────────────────────────────────────────────────┐
│                         CONVERSATION                              │
│                              │                                    │
│    ┌─────────────────────────┼─────────────────────────┐         │
│    │                         ▼                         │         │
│    │  ┌─────────────────────────────────────────────┐  │         │
│    │  │            WORKING MEMORY                    │  │         │
│    │  │         (active processing)                  │  │         │
│    │  └──────┬──────────┬──────────┬────────────────┘  │         │
│    │         │          │          │                   │         │
│    │    ┌────▼────┐ ┌───▼───┐ ┌────▼─────┐            │         │
│    │    │EPISODIC │ │SEMANTIC│ │PROCEDURAL│            │         │
│    │    │"What    │ │"What   │ │"How do   │            │         │
│    │    │happened"│ │is true"│ │I behave" │            │         │
│    │    └─────────┘ └────────┘ └──────────┘            │         │
│    │                                                   │         │
│    │         RETRIEVAL ←──────── ENCODING             │         │
│    │     (load on demand)    (store after session)    │         │
│    └───────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────────┘
```

**During a conversation:**
1. **Procedural memory** shapes *how* I respond (personality, rules, skills)
2. **Working memory** holds the current context and task
3. **Episodic memory** is queried for relevant past experiences ("Have I talked to this person before?")
4. **Semantic memory** is queried for relevant facts ("How does this API work?")

**After a conversation:**
1. Notable content flows to **episodic memory** (daily logs, contact/channel updates)
2. Stable facts graduate to **semantic memory** (knowledge files)
3. Learned rules update **procedural memory** (AGENTS.md, lessons)
4. **Working memory** is pruned to stay within capacity

---

### Memory Type Decision Tree

When storing new information, ask:

```
Is it about HOW TO behave or do something?
    └─► Yes: PROCEDURAL (SOUL.md, AGENTS.md, skills/)
    └─► No: Continue...

Is it a personal experience or relationship?
    └─► Yes: EPISODIC (memory/by-contact/, by-channel/, daily/)
    └─► No: Continue...

Is it a fact, concept, or general knowledge?
    └─► Yes: SEMANTIC (knowledge/topics/, entities/, lessons/)
    └─► No: Continue...

Is it immediately relevant to the current task?
    └─► Yes: WORKING (MEMORY.md, session context)
    └─► No: May not need storage
```

---

### Academic Grounding

This architecture draws from established research:

- **Tulving (1972)** — Distinction between episodic and semantic memory
- **Baddeley & Hitch (1974)** — Working memory model
- **Squire (2004)** — Taxonomy of long-term memory systems
- **ICLR 2026 MemAgents Workshop** — Emerging research on memory systems for AI agents

Reference implementation: [ALucek/agentic-memory](https://github.com/ALucek/agentic-memory) — A clean demonstration of the four-system architecture applied to LLM agents.

> *"Memory is not a single faculty but a collection of distinct systems that work together."*
> — Endel Tulving

---

## System Architecture

```
                              ┌─────────────────┐
                              │  CONVERSATIONS  │
                              │   (realtime)    │
                              └────────┬────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         HEARTBEAT (every 30 min)                         │
│  Scans recent sessions, extracts notable content, creates reminders     │
└──────────────────────────────────────┬───────────────────────────────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  memory/daily/  │
                              │  Raw daily logs │
                              └────────┬────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                          CURATION (every 5 hours)                        │
│  Routes content to appropriate long-term storage                         │
└───────┬──────────────┬──────────────┬──────────────┬─────────────────────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   memory/    │ │   memory/    │ │  knowledge/  │ │  knowledge/  │
│  by-contact/ │ │  by-channel/ │ │   topics/    │ │   lessons/   │
│  (people)    │ │  (groups)    │ │   (facts)    │ │   (rules)    │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
        │              │              │              │
        └──────────────┴──────────────┴──────────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │   MEMORY.md     │
                              │ Working memory  │
                              │ + Index to all  │
                              └────────┬────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
        ▼                              ▼                              ▼
┌──────────────┐              ┌──────────────┐              ┌──────────────┐
│   COMPILE    │              │  REEVALUATE  │              │   FILE ORG   │
│   (weekly)   │              │  (monthly)   │              │   (weekly)   │
│              │              │              │              │              │
│ Prune stale  │              │ Audit system │              │ Archive old  │
│ Graduate →   │              │ Review skills│              │ daily files  │
│ knowledge    │              │ Extract      │              │              │
│ Weekly digest│              │ lessons      │              │              │
└──────────────┘              └──────────────┘              └──────────────┘
```

---

## The Five Stages

### Stage 1: Conversations (Realtime)

Conversations happen across channels — Telegram DMs, group chats, etc. OpenClaw stores session transcripts automatically. This is ephemeral storage managed by the platform.

**No action required.** This is the raw input to the system.

---

### Stage 2: Heartbeat (Every 30 minutes)

**Purpose:** Capture notable content before it scrolls away.

The heartbeat scans recent sessions looking for:
- Reminders and todos
- Decisions made
- Plans and intentions
- People and relationships mentioned
- Project updates
- Facts learned
- Running jokes and personality bits

**Output:** Appends to `memory/daily/YYYY-MM-DD.md`

**Why 30 minutes?** Frequent enough to catch everything, infrequent enough to batch efficiently. The heartbeat is lightweight — it just extracts and logs, doesn't organize.

---

### Stage 3: Curation (Every 5 hours)

**Purpose:** Route content to the right long-term home.

Curation reads daily files and makes routing decisions:

| If the content is about... | Route to... |
|----------------------------|-------------|
| A specific person | `memory/by-contact/<channel>-<id>.md` |
| A specific group | `memory/by-channel/<channel>-g-<name>.md` |
| A lesson or rule learned | `knowledge/lessons/<domain>.md` |
| A factual topic (how X works) | `knowledge/topics/<topic>.md` |
| An experiential topic (our journey with X) | `memory/by-topic/<topic>.md` |
| A named entity (company, place) | `knowledge/entities/<Name>.md` |
| A raw idea | `memory/ideas/<slug>.md` |
| Something hot/current | `MEMORY.md` |

**Why 5 hours?** Enough time for meaningful content to accumulate, frequent enough that nothing sits unprocessed for long.

---

### Stage 4: Compile (Weekly)

**Purpose:** Maintain and mature the knowledge base.

Weekly compilation:
1. **Prunes** stale entries from MEMORY.md
2. **Graduates** mature content from memory → knowledge
3. **Consolidates** scattered related content
4. **Extracts** implicit lessons
5. **Produces** a weekly digest

**Graduation criteria:**
- Is it factual rather than experiential?
- Has it been stable for 2+ weeks?
- Does it have 5+ facts or references?
- Would it help someone without relationship context?

**Output:** `memory/daily/YYYY-MM-DD-weekly-digest.md`

---

### Stage 5: Reevaluate (Monthly)

**Purpose:** Audit the system and evolve the agent.

Monthly reevaluation covers:
1. **Foundation files** — Are SOUL.md, IDENTITY.md, etc. still accurate?
2. **Memory health** — Is heartbeat capturing the right things?
3. **Skill feedback** — What tools worked well? What caused friction?
4. **Lessons review** — Are existing lessons still valid? Any new ones to extract?
5. **Security audit** — Any exposed credentials or sensitive content?
6. **Meta-review** — Is this reevaluation process itself working?

**Output:** `memory/daily/YYYY-MM-DD-reevaluation.md` + proposed updates

---

## File Structure

```
workspace/
│
├── Foundation Files (who the agent is)
│   ├── SOUL.md              # Core values, personality, boundaries
│   ├── IDENTITY.md          # Name, appearance, vibe
│   ├── USER.md              # About the human(s) being helped
│   ├── AGENTS.md            # Operating guidelines, loading rules
│   └── TOOLS.md             # Environment-specific notes
│
├── System Files (how memory works)
│   ├── MEMORY.md            # Working memory + index (~500 lines max)
│   ├── HEARTBEAT.md         # Heartbeat job instructions
│   ├── CURATION.md          # Curation job instructions
│   ├── COMPILE.md           # Weekly compile instructions
│   ├── REEVALUATE.md        # Monthly review instructions
│   └── HOW-IT-WORKS.md      # This document
│
├── memory/                   # EPISODIC — what happened
│   ├── daily/               # Raw logs (30-day retention)
│   ├── archive/             # Old daily files (by month)
│   ├── by-contact/          # Per-person relationship memory
│   ├── by-channel/          # Per-group dynamics
│   ├── by-topic/            # Experiential topic memory
│   └── ideas/               # Raw brainstorms
│
├── knowledge/                # SEMANTIC — what's true
│   ├── topics/              # How things work
│   ├── entities/            # Companies, places, products
│   ├── lessons/             # Learned rules by domain
│   │   ├── security.md
│   │   ├── communication.md
│   │   ├── technical.md
│   │   ├── social.md
│   │   └── skills.md
│   └── reference/           # Stable how-tos, cheat sheets
│
└── skills/                   # Tool/capability definitions
    └── <skill>/
        ├── SKILL.md         # How to use this skill
        └── NOTES.md         # Usage feedback (populated by reevaluate)
```

---

## MEMORY.md: The Working Memory

MEMORY.md serves two critical functions:

### 1. Working Memory
The "hot" content that's currently relevant. Things that should be immediately accessible without searching. Capped at ~500 lines to keep context windows manageable.

### 2. Index
The map to everything else. When you need to find something, MEMORY.md tells you where it lives. The "Memory Structure Map" section documents all file locations.

**Entity Promotion Rule:** When any entity in MEMORY.md exceeds 10 lines or 5 mentions, it gets promoted to its own dedicated file. This keeps working memory lean.

---

## Session Loading

Different contexts require different memory:

| Context | What to Load |
|---------|--------------|
| **Every session** | SOUL.md, IDENTITY.md, USER.md, daily files (today + yesterday) |
| **Main session** (direct chat with owner) | + MEMORY.md |
| **DM with specific person** | + their `memory/by-contact/` file |
| **Group chat** | + the `memory/by-channel/` file |
| **Topic comes up** | Lazy-load relevant `knowledge/topics/` or `memory/by-topic/` |
| **Using a skill** | Check `skills/<skill>/NOTES.md` for usage tips |
| **Uncertain or error** | Check `knowledge/lessons/` for relevant rules |

This ensures the agent has relationship context when talking to someone specific, without loading everything every time.

---

## The Lessons System

Lessons are the distillation of experience into actionable rules.

**Structure:**
```markdown
## Lesson Title
**Learned:** [date] (incident reference)
**Context:** What happened
**Rule:** What to do / not do
```

**Domains:**
- `security.md` — Credentials, access, safety
- `communication.md` — Messaging patterns, relay rules
- `technical.md` — API quirks, config gotchas
- `social.md` — Per-person interaction rules
- `skills.md` — Tool usage patterns

**Why provenance matters:** Including when and why a lesson was learned allows future reevaluation. Circumstances change; lessons may become obsolete.

---

## Timing Summary

| Job | Frequency | Model | Purpose |
|-----|-----------|-------|---------|
| Heartbeat | Every 30 min | Main | Raw capture → daily files |
| Curation | Every 5 hours | Haiku | Route → long-term storage |
| File Org | Sunday 3am | Haiku | Archive old daily files |
| Compile | Sunday | Haiku/Sonnet | Prune, graduate, digest |
| Reevaluate | 1st of month | Sonnet+ | System audit, skill feedback |

---

## Setup & Configuration

### Use Premier Models for Structural Work

This memory system is the **structural backbone** of the agent's cognition. When setting up, modifying, or debugging the architecture:

> ⚠️ **Always use your most capable model available** (e.g., Opus, GPT-5.x, Sonnet 4.5+)

Lower-tier models may:
- Misunderstand the routing logic
- Create inconsistent file structures  
- Miss edge cases in the decision trees
- Introduce subtle bugs that compound over time

**Rule of thumb:** If you're touching foundation files (`SOUL.md`, `AGENTS.md`, `MEMORY.md`) or system files (`CURATION.md`, `COMPILE.md`, `REEVALUATE.md`), use a premier model.

---

### DM Session Isolation (`dmScope`)

The `by-contact/` memory system assumes each person can have personalized context loaded. To fully leverage this:

```yaml
# openclaw.yaml
session:
  dmScope: "per-channel-peer"   # Recommended for memory system
```

**Why this matters:**

| `dmScope` Setting | Behavior | Memory System Fit |
|-------------------|----------|-------------------|
| `main` (default) | All DMs share one session | ⚠️ Cross-user context leakage risk |
| `per-channel-peer` | Each DM sender gets isolated session | ✅ Perfect for by-contact memory |
| `per-account-channel-peer` | Isolated + multi-account aware | ✅ For multi-account setups |

With `per-channel-peer`:
- Each person's conversation stays isolated
- Their `memory/by-contact/<channel>-<id>.md` file loads appropriately
- No risk of User A seeing context from User B's conversations
- Owner (main) sessions remain separate with full MEMORY.md access

**For personal assistants** (single owner, trusted users): `main` is acceptable if you want unified context.

**For shared/multi-user scenarios**: `per-channel-peer` is strongly recommended.

---

### Isolated Sessions for Cron Jobs

All memory system cron jobs should run in **isolated sessions**, not the main session:

```yaml
# Example cron job configuration
- name: memory-curation
  schedule: "0 */5 * * *"  # Every 5 hours
  sessionTarget: "isolated"  # ← Critical
  model: "haiku"
  task: "Run curation per CURATION.md"
```

**Why this matters:**

| Session Target | Behavior | Impact on Main Session |
|----------------|----------|------------------------|
| `main` | Runs in main session context | ❌ Bloats context with processing artifacts |
| `isolated` | Fresh session, no shared context | ✅ Main session stays clean |

**Problems with running crons in main session:**
- Curation reads dozens of daily files → all that content enters main context
- Compile processes a week of history → massive context pollution
- Reevaluation audits everything → even worse
- Main session becomes sluggish and unfocused

**Isolated sessions:**
- Start fresh with only the instructions needed
- Process content without polluting conversational context
- Output goes to files (daily digest, etc.) not session history
- Main session stays lean for actual conversations

**Recommended cron configuration:**

| Job | Session | Model | Why |
|-----|---------|-------|-----|
| Curation | `isolated` | Haiku | High volume, routing decisions |
| Compile | `isolated` | Haiku/Sonnet | Weekly processing |
| Reevaluate | `isolated` | Sonnet+ | Deep analysis, needs reasoning |
| File Org | `isolated` | Haiku | Simple file operations |

---

## Design Principles

### 1. Write Everything Down
"Mental notes" don't survive session restarts. If it's worth remembering, write it to a file.

### 2. Separate Episodic from Semantic
Relationships and experiences are different from facts and rules. Store them separately.

### 3. Promote Aggressively
Don't let MEMORY.md become a dumping ground. Promote entities to dedicated files early.

### 4. Include Provenance
Always record when something was learned and why. This enables future validation.

### 5. Automate the Boring Parts
Heartbeat, curation, and file organization run automatically. Humans focus on the interesting decisions.

### 6. Review Regularly
Weekly compilation keeps things pruned. Monthly reevaluation ensures the system evolves.

### 7. Fail Safe
Use `trash` instead of `rm`. Capture more than necessary — easier to prune than recover.

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `CURATION.md` | Detailed routing decision tree for the curation job |
| `COMPILE.md` | Step-by-step instructions for weekly compilation |
| `REEVALUATE.md` | Phase-by-phase guide for monthly reevaluation |
| `AGENTS.md` | Operating guidelines including session loading rules |
| `MEMORY.md` | The working memory itself, including the structure map |

---

## Summary

This memory system transforms a stateless language model into a persistent agent that:

- **Remembers** relationships and experiences (episodic memory)
- **Knows** facts and how things work (semantic knowledge)
- **Learns** from mistakes through explicit lessons
- **Evolves** through regular self-review
- **Scales** through promotion and archival

The architecture mirrors human cognition: daily experiences flow through working memory, get consolidated during "sleep" (curation/compile), and mature into long-term knowledge over time.

The result is an AI that feels like it *knows* you — because it does.

---

*Version 1.0 — March 2026*

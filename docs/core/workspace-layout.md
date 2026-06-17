# Workspace layout

Your agent's **workspace** (`~/.openclaw/workspace/` by default) is where its identity, memory, and skills live. OpenClaw reads these files at startup. This is the canonical reference for what each file does and whether you actually need it.

## Core identity & behaviour files

| File | Required? | What it does |
|------|-----------|--------------|
| `AGENTS.md` | Recommended | Operating manual — how the agent should work, session-load rules, house conventions. Loaded every session. |
| `SOUL.md` | Recommended | Persona / voice / values — *who* the agent is. Loaded every session. |
| `USER.md` | Recommended | Who the agent is helping — your name, preferences, context. |
| `IDENTITY.md` | Optional | Name / avatar / identifying details — useful especially if you run more than one agent. |
| `TOOLS.md` | Optional | Host-specific tooling notes (paths, where credentials live, environment quirks). |
| `MEMORY.md` | Optional | Curated "hot" working memory + an index into `memory/`. Loaded in the main session. |
| `HEARTBEAT.md` | Optional | What to do on a heartbeat tick. Keep it small — it's read on every beat. |

> **Minimum to feel "alive":** `AGENTS.md` + `SOUL.md` + `USER.md`. Add the rest as your setup grows.

## Directories

| Directory | What it holds |
|-----------|---------------|
| `memory/` | Episodic memory — daily logs, per-contact/group notes, lessons, reminders (what *happened*). |
| `knowledge/` | Semantic memory — durable topics, research, procedures (what's *true*). |
| `skills/` | Skill folders, each with a `SKILL.md`. See the [skill guides](../../skills/README.md) and [SkillReef](https://github.com/clawSean/skillreef) for ready-made ones. |
| `projects/` | Work-in-progress code, scratch, and sandboxes. |

## How OpenClaw loads it

- Bootstrap files (`AGENTS.md`, `SOUL.md`, `USER.md`, …) are injected into the agent's context at session start.
- `SKILL.md` files are discovered automatically and loaded when their `description` matches the current task.
- Keep bootstrap files **lean** — they're loaded every session, so size = cost. Push detail into `memory/` and `knowledge/`, and index it from `MEMORY.md`.

For the authoritative workspace/config reference, see [docs.openclaw.ai](https://docs.openclaw.ai).

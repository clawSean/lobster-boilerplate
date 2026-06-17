# 🦞 Lobster Skills

A **starter set of skill _guides_** for OpenClaw agents. Each `.md` here walks you through building one skill — what it does, its dependencies, and how to wire it up. These are recipes, not drop-in folders: you create the actual `SKILL.md` (+ any scripts) in your workspace by following the guide.

> **Want ready-made skills instead?** Browse and install from **[SkillReef](https://github.com/clawSean/skillreef)** (the living registry) or **[ClawHub](https://clawhub.ai)** — `openclaw skills install <slug>`. This set is a curated starting point; SkillReef is the full catalogue (and where to publish your own).

Skills live in your agent's `workspace/skills/` directory. OpenClaw discovers them automatically once a `SKILL.md` is in place.

---

## Available Skills

| Skill | What It Does | Dependencies |
|---|---|---|
| [1password-secrets](./1password-secrets.md) | Runtime credential access via `op read` | 1Password CLI + service account |
| [asana](./asana.md) | Project management via Asana MCP | mcp-remote, 1Password |
| [coingecko](./coingecko.md) | Crypto price data and market info | None (free tier) or API key |
| [coinmarketcap](./coinmarketcap.md) | CMC quotes, metadata, platform mapping | API key (1Password) |
| [diem-balance](./diem-balance.md) | Check Venice AI Diem credits | Python3, Venice API key |
| [knowledge-search](./knowledge-search.md) | Semantic search over knowledge/ via ChromaDB | Ollama, ChromaDB, Python3 |
| [mermaid](./mermaid.md) | Render diagrams from code (flowcharts, sequences, etc.) | mermaid-cli (`mmdc`), Chromium |
| [perplexity-search](./perplexity-search.md) | Deep web research with citations | API key (1Password) |
| [search-twitter](./search-twitter.md) | Twitter/X API search and tweet fetching | API key (1Password) |
| [service-health](./service-health.md) | Health checks across all external services | Varies by service |
| [shrimp](./shrimp.md) | Spawn a sub-agent for background tasks | OpenClaw sub-agent support |
| [slack](./slack.md) | Slack workspace access via MCP | slack-mcp-server, 1Password |
| [telegram-pin](./telegram-pin.md) | Pin messages in Telegram groups | Bot token |

## Skill structure (what you build)

Following a guide, you create a skill folder in your workspace with this shape:

```
skills/<name>/
├── SKILL.md           # Instructions for the agent (required)
├── NOTES.md           # Usage feedback, gotchas (populated over time)
└── scripts/           # Helper scripts (optional)
    └── *.sh / *.py / *.js
```

The `SKILL.md` frontmatter tells OpenClaw when to load the skill:

```yaml
---
name: skill-name
description: >
  When to use this skill. Loaded by the agent when
  the description matches the current task context.
---
```

## Building a skill from a guide

1. Read the skill's guide (the `.md` files above) and create `workspace/skills/<name>/SKILL.md` from it
2. Install any dependencies (each guide lists them)
3. If it needs API keys, add them to 1Password and update the `1password-secrets` skill table
4. The agent discovers and uses it automatically based on the description match

> For skills that ship ready-to-run, install from [SkillReef](https://github.com/clawSean/skillreef) / [ClawHub](https://clawhub.ai) instead of building from scratch.

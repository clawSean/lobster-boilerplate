# 🦞 Lobster Skills

Drop-in skill guides for OpenClaw agents. Each skill is a self-contained folder with a `SKILL.md` that tells the agent what it can do and how.

Skills live in your agent's `workspace/skills/` directory. OpenClaw discovers them automatically.

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

## Skill Structure

Each skill follows the same pattern:

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

## Installing a Skill

1. Copy the skill folder into `workspace/skills/`
2. Ensure any dependencies are installed (see each skill's guide)
3. If the skill needs API keys, add them to 1Password and update the `1password-secrets` skill table
4. The agent will discover and use it automatically based on the description match

# Perplexity Search

Deep web research with cited, synthesized answers via the Perplexity Sonar API.

## Setup

1. **Get an API key** at [perplexity.ai](https://www.perplexity.ai/) and add it to 1Password.

2. **Create the skill folder:**
   ```
   skills/perplexity-search/
   ├── SKILL.md
   └── scripts/
       ├── ask.sh       # Quick Q&A (sonar-pro, cheapest)
       ├── research.sh  # Deep research (sonar-deep-research)
       └── reason.sh    # Complex reasoning (sonar-reasoning-pro)
   ```

3. **Scripts fetch the API key from 1Password:**
   ```bash
   op read "op://YourVault/Perplexity API Key/password"
   ```

## Usage

```bash
# Quick question (default — use this most of the time)
bash skills/perplexity-search/scripts/ask.sh "What happened with Ethereum this week?"

# Deep research (expensive, use sparingly)
bash skills/perplexity-search/scripts/research.sh "Privacy DeFi landscape 2026"

# Complex reasoning (extended thinking)
bash skills/perplexity-search/scripts/reason.sh "Compare ZK proofs vs FHE for privacy"
```

## When to Use vs Brave Search

| Use Case | Tool |
|---|---|
| Quick fact lookup, simple queries | Brave (`web_search`) |
| Deep research, multi-source synthesis | **Perplexity** |
| Need citations/sources in the answer | **Perplexity** |
| Current events analysis | **Perplexity** |

## Cost Awareness

- `ask.sh` is the cheapest — default to this
- `research.sh` does multi-step queries — only when you need depth
- `reason.sh` includes extended thinking — for complex problems

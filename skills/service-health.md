# Service Health Checks

Quickly verify which external services are up, down, or degraded.

## Setup

1. **Create the skill folder:**
   ```
   skills/service-health/
   ├── SKILL.md
   ├── scripts/
   │   └── check-all.sh     # Runs all checks, aggregates results
   └── checks/
       ├── openclaw.sh      # Gateway health endpoint
       ├── 1password.sh     # op whoami connectivity
       ├── twitter.sh       # Lightweight API call
       ├── perplexity.sh    # Minimal sonar query
       ├── brave.sh         # Simple search query
       ├── coingecko.sh     # Ping endpoint
       └── qmd.sh           # Memory backend health
   ```

2. **Each check script** follows the same contract:
   - Exit `0` = up, `1` = down, `2` = degraded/warning
   - Stdout = status message

3. **`check-all.sh` auto-discovers** scripts in `checks/` — add a new file and it's included automatically.

## Usage

```bash
# Check everything
bash skills/service-health/scripts/check-all.sh

# JSON output
bash skills/service-health/scripts/check-all.sh --json

# Single service
bash skills/service-health/checks/twitter.sh
```

## Output

```
✅ openclaw      Gateway healthy
✅ 1password     Authenticated
❌ twitter       401 Unauthorized
⚠️  perplexity   Slow response (3.2s)
✅ brave         OK
✅ coingecko     OK
```

## Adding a New Service

Create a script in `checks/` that tests connectivity and exits with the right code. It's auto-discovered on next `check-all.sh` run.

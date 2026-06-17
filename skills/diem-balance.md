# Diem Balance

Check Venice AI Diem balance and remaining API credits.

## Setup

1. **Requires Python 3** and a Venice API key. The script reads the key from your OpenClaw auth profiles (`~/.openclaw/agents/main/agent/auth-profiles.json`, the standard auth location).

2. **Create the skill folder:**
   ```
   skills/diem-balance/
   ├── SKILL.md
   └── diem.py
   ```

3. The `diem.py` script calls the Venice API and displays balance headers (Diem, USD, VCU) and rate limit info.

## Usage

```bash
python3 skills/diem-balance/diem.py
```

Shows HTTP status, balance headers, and rate limit information. Useful for monitoring API spend.

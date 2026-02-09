# OpenClaw + Telegram bootstrap (boilplate)

This is a **starting point** for bringing a fresh VPS online with an OpenClaw agent similar to Sean's setup.

It goes a bit **beyond** the default OpenClaw onboarding by:

- explaining **why** you need specific keys (Brave, OpenAI, etc.)
- showing how to wire **memory + search** so the agent isn’t “half‑blind”
- documenting the **Telegram group permission syntax** so you can safely add more people/groups
- including an optional helper for **Venice Diem** balance/rate limits.

---

## 1. System + Node

- Use a recent Ubuntu LTS.
- Install Node.js 22.x (via NodeSource or nvm).

```bash
# example (NodeSource):
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 2. Install OpenClaw globally

```bash
npm install -g openclaw
openclaw version
```

## 3. Prepare workspace

```bash
mkdir -p ~/.openclaw/workspace
cd ~/.openclaw/workspace
```

Recommended top-level files in the workspace (mirroring Sean/JPop's pattern):

- `AGENTS.md` – notes about how the agent behaves.
- `SOUL.md` – persona / tone.
- `USER.md` – who you are.
- `MEMORY.md` + `memory/YYYY-MM-DD.md` – long-term + daily notes.

---

## 4. Configure OpenClaw (config template)

Copy the template into place:

```bash
mkdir -p ~/.openclaw
cp templates/openclaw.template.json ~/.openclaw/openclaw.json
```

Then edit `~/.openclaw/openclaw.json` and fill in:

- `tools.web.search.apiKey` → your **Brave Search API key**.
- `channels.telegram.botToken` → your **Telegram bot token** from **@BotFather**.
- `channels.telegram.groups` → your group IDs and enable flags.
- `gateway.auth.token` → any random secret string for local API auth.

### Why the Brave API key matters

OpenClaw can **only search the web** if `tools.web.search.apiKey` is set.

- Without it, `/web_search` will be effectively disabled, and the agent will say it can’t search.
- With it, the agent can:
  - look up live data (markets, docs, news)
  - fetch external docs when answering questions

This repo expects a **Brave Search** key, but you can switch to another search provider if OpenClaw supports it in the future.

### Why the OpenAI (and other model) keys matter for memory

The **memory system relies on models that can call `memory_search` and read/write files**. In a typical setup:

- The **primary chat model** (here `openai-codex/gpt-5.2`) is what you talk to.
- Sub‑agents (cron jobs, background tasks) often use a cheaper model (e.g. Haiku) to:
  - scan `memory/*.md`
  - update `MEMORY.md`
  - keep long‑term notes consistent.

Make sure you have working auth for:

- `openai-codex` (for GPT‑5.1 / 5.2 style models)
- `anthropic` (for Haiku/Sonnet/Opus, if you use them)
- `venice` (for Kimi/DeepSeek, if configured)

If those providers are not properly configured, things like **`memory_search` will silently fail** or be much less useful (the agent can’t “remember” across days).

The template assumes you’ll provide credentials via the normal OpenClaw auth mechanisms (token, OAuth, etc.), not hardcoded into `openclaw.json`.

---

## 5. Telegram wiring + permissions

1. Create a bot with **@BotFather**.
2. Add the bot to your group.
3. Optionally disable **privacy mode** in BotFather if you want it to see all messages.
4. Put the group id(s) + bot token into `openclaw.json`.

### `channels.telegram.groups` structure

Example snippet:

```json
"channels": {
  "telegram": {
    "enabled": true,
    "dmPolicy": "pairing",
    "botToken": "YOUR_TELEGRAM_BOT_TOKEN_HERE",
    "groups": {
      "-1001234567890": {
        "requireMention": false,
        "enabled": true
      },
      "-1009876543210": {
        "requireMention": true,
        "enabled": true
      }
    },
    "groupAllowFrom": [
      1111111111,
      2222222222
    ],
    "groupPolicy": "allowlist",
    "streamMode": "partial"
  }
}
```

**Fields:**

- `groups[GROUP_ID].enabled` – controls whether the bot is active in that group at all.
- `groups[GROUP_ID].requireMention` – if `true`, the agent only responds when @mentioned.
- `groupPolicy`: usually `"allowlist"` so only IDs in `groupAllowFrom` can control the bot.
- `groupAllowFrom`: array of Telegram **user IDs** that are allowed to issue commands / direct the agent in groups.

**How to permission a new person:**

1. Get their Telegram **numeric user ID** (via a “user info” bot or logging).
2. Add it to `groupAllowFrom`:

   ```json
   "groupAllowFrom": [
     1111111111,  // owner
     2222222222,  // friend
     3333333333   // new person
   ]
   ```
3. Restart the gateway (or reload config) so the change takes effect.

This makes it explicit **who** the agent will treat as an authority inside group chats.

---

## 6. Optional: Venice Diem balance helper

If you use **Venice** as a model provider and want a quick way to check your Diem balance and rate limits, you can use the included helper script:

- `scripts/diem.py`

It:

- reads your Venice API key from `~/.openclaw/agents/main/agent/auth-profiles.json` (the standard OpenClaw auth location),
- sends a tiny test request to Venice,
- prints:
  - HTTP status,
  - any error message, and
  - all relevant `x-venice-balance-*` and `x-ratelimit-*` headers.

Usage:

```bash
cd ~/.openclaw/workspace/boilplate
python3 scripts/diem.py
```

You should see something like:

```text
HTTP status: 200
Venice headers (balance / rate limits):
- x-venice-balance-diem: 1.69...
- x-ratelimit-limit-requests: ...
- x-ratelimit-remaining-requests: ...
...
```

If your Diem balance is depleted, you may see HTTP 402 errors or missing balance headers.

---

## 7. Start the gateway

```bash
openclaw gateway start
openclaw status
```

Once the gateway is running and Telegram is configured, messages in your group should start hitting the agent.

This repo is intentionally simple – adjust the template + docs to your taste and commit your own defaults.
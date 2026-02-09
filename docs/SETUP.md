# OpenClaw + Telegram bootstrap (boilplate)

This is a **starting point** for bringing a fresh VPS online with an OpenClaw agent similar to Sean's setup.

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

## 4. Configure OpenClaw

Copy the template into place:

```bash
mkdir -p ~/.openclaw
cp templates/openclaw.template.json ~/.openclaw/openclaw.json
```

Then edit `~/.openclaw/openclaw.json` and fill in:

- `tools.web.search.apiKey` → your **Brave Search API key** (or disable search).
- `channels.telegram.botToken` → your **Telegram bot token** from **@BotFather**.
- `channels.telegram.groups` → your group IDs and enable flags.
- `gateway.auth.token` → any random secret string for local API auth.

## 5. Telegram wiring

1. Create a bot with **@BotFather**.
2. Add the bot to your group.
3. Optionally disable privacy mode if you want it to see all messages.
4. Put the group id(s) + bot token into `openclaw.json`.

## 6. Start the gateway

```bash
openclaw gateway start
openclaw status
```

Once the gateway is running and Telegram is configured, messages in your group should start hitting the agent.

This repo is intentionally simple – adjust the template to your taste and commit your own defaults.

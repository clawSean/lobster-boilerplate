# Sandbox gateway

A **sandbox gateway** is a second, deliberately *locked-down* OpenClaw gateway you use to test things — a new bot, slash commands, a risky config — with no blast radius on your real agent. It's a specific application of the [second-gateway base pattern](second-gateway-base.md): same isolation (its own service, home, workspace, port, and bot token), but with tools and channels stripped to the bare minimum.

> The sandbox-gateway pattern in this section was contributed by **[@nicknmorty](https://github.com/nicknmorty)** from his own locked-down sandbox setup.

## When to use it

- Live-testing a bot or slash commands against Telegram without exposing your main agent.
- Trying a config / plugin change in isolation.
- Giving an untrusted prompt or task somewhere it can't reach your real workspace, secrets, or tools.

## The shape

Build on the second-gateway base, then lock it down.

**Separate everything** (per the base pattern): own systemd unit (`openclaw-sandbox.service`), own home (`~/.openclaw-sandbox`), own workspace, own port, own bot token.

**Isolated secrets** — the sandbox gets its OWN env file with only what it needs. **Never** point it at your main `~/.openclaw/.env`:

```bash
# ~/.openclaw-sandbox/.env   (sandbox-only secrets)
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN_SANDBOX}
OPENCLAW_GATEWAY_TOKEN=${SANDBOX_GATEWAY_TOKEN}
```

### Tool lockdown (the whole point)

In the sandbox's `openclaw.json`, deny everything the test doesn't strictly need:

- `skills: []` — no skills loaded.
- No file tools, no web tools, no memory tools.
- No exec/process, no browser/canvas, no nodes/cron/gateway.
- Set a global `tools.deny` — **deny wins** across config nuances, so it's the reliable lock.
- Disable elevated exec entirely for this posture.

### Channel / command lockdown

- Enable **only** the channel you're testing (e.g. Telegram for slash-command/bot testing).
- DM pairing on; **groups disabled**; config writes disabled.
- Disable risky commands: `bash`, `debug`, `restart`, `config`.

### Systemd hardening

```ini
[Unit]
# Restart rate-limit keys belong HERE, not in [Service]
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
NoNewPrivileges=yes
Environment=OPENCLAW_HOME=%h/.openclaw-sandbox
WorkingDirectory=%h/.openclaw-sandbox/.openclaw
Restart=always
RestartSec=10
TimeoutStartSec=30
TimeoutStopSec=30
```

> ⚠️ Put the restart **rate-limit** keys (`StartLimitIntervalSec` / `StartLimitBurst`) in `[Unit]`, not `[Service]` — they're silently ignored under `[Service]`. Verify with `systemctl show <unit> | grep StartLimit`.

## A note on "true" sandbox mode

OpenClaw has a built-in true sandbox mode (`mode: all`, `workspaceAccess: none`) — but it **requires Docker**. On a host without Docker (a Raspberry Pi, a minimal VPS), that mode won't start. This pattern is the **pseudo-sandbox**: no container isolation, but a separate gateway + aggressive tool/channel lockdown gets you most of the safety for slash-command and bot testing. If you have Docker, prefer true sandbox mode; otherwise, use this.

## Setup checklist

1. Create `~/.openclaw-sandbox` (home + workspace).
2. Create `~/.openclaw-sandbox/.env` with **only** the sandbox's secrets — no dependency on the shared `~/.openclaw/.env`.
3. Write the sandbox `openclaw.json`: `tools.deny` covering everything, `skills: []`, only the test channel enabled, groups off, risky commands disabled.
4. `openclaw config validate` before starting.
5. Install the hardened systemd unit (start-limit keys in `[Unit]`).
6. `sudo systemctl daemon-reload && sudo systemctl start openclaw-sandbox.service`
7. Verify: `sudo systemctl status openclaw-sandbox.service --no-pager -n 30` + logs, and confirm the bot is DM-only.

See the [second-gateway base](second-gateway-base.md) for the underlying isolation mechanics.

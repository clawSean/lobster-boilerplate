# Deployment

> Doctor / breakglass agent pattern originally authored by Nick Haener
> ([@nicknmorty](https://github.com/nicknmorty)) as the `claw-doc` project —
> migrated here and adapted onto the lobster-boilerplate `second-gateway` base.

## Deployment stance

This module favors clarity over cleverness. Start with a simple dedicated
deployment, then add automation only after the boundary is working.

Decide early whether your deployment is meant to be:

- an operational **doctor** with powerful environment access
- an **advisor** that primarily reads, inspects, and recommends

That choice affects tooling, routing, and trust assumptions.

## Build on the second-gateway base

The runtime mechanics are already provided by the
[second-gateway base pattern](../second-gateway-base.md). You do not need to
reinvent the systemd unit or the 1Password injection script — copy and rename
them for this role:

- `infra/systemd/openclaw-second-gateway.service` → e.g. `openclaw-doctor-agent.service`
- `infra/scripts/render-second-gateway-env-from-1password.sh`
- `infra/env/second-gateway.env.template`

Point the renamed service at this module's workspace and config templates.

## Example directory layout

```text
/path/to/doctor-agent/
  config/openclaw.json5
  workspace/
  runtime/
  logs/
```

## Example deployment flow

1. Create a dedicated host directory, for example `/path/to/doctor-agent`
2. Create or assign a dedicated OpenClaw home/runtime root for this gateway only
   (e.g. `~/.openclaw-second-gateway`)
3. Copy `templates/openclaw.example.json5` to `config/openclaw.json5`
4. Copy files from `templates/workspace/` into the runtime workspace
5. Replace placeholders like `${TELEGRAM_BOT_TOKEN}` and `${OPENCLAW_GATEWAY_TOKEN}`
6. Point all runtime paths at dedicated directories
7. Start the dedicated gateway service (the renamed second-gateway unit)
8. Validate routing, auth, and channel access in a non-public test channel first

## Placeholder values to replace

- `${TELEGRAM_BOT_TOKEN}`
- `${OPENCLAW_GATEWAY_TOKEN}`
- `${OPENAI_API_KEY}`
- `${PRIMARY_CHAT_ID}`
- `${ALERT_CHAT_ID}`
- `${WORKSPACE_ROOT}`
- `${RUNTIME_ROOT}`

In the 1Password-backed flow these map to entries such as
`op://Infrastructure/second-gateway/TELEGRAM_BOT_TOKEN` — never to literal
secret values checked into git.

## Example validation checklist

- gateway starts with the dedicated config
- agent can read the workspace prompt files
- bot can send a test message to the intended chat
- secrets are loaded from private local storage (or 1Password), not from this module
- no runtime artifacts are being written into the public repo tree

## Before going live

- review [SANITIZATION.md](./SANITIZATION.md)
- make sure the channel IDs are your own, not copied examples
- confirm the bot token is dedicated to this deployment
- confirm logs and task state stay outside the public repo
- decide whether you are intentionally enabling operational access or keeping the
  agent in advisor mode
- if granting powerful tool access, require strong routing boundaries and a human
  approval model for state-changing actions

## Do not do this

- do not run directly from the public repo with real secrets checked in
- do not treat the example config as production-ready without review
- do not merge personal and breakglass gateway state into one directory
- do not treat a separate workspace alone as sufficient isolation if the same
  gateway/runtime still serves unrelated agents

# OpenClaw Runtime Secrets

This guide is for the default OpenClaw gateway. The canonical service name is
`openclaw-gateway.service` (or `openclaw-gateway-<profile>.service` for a named
profile).

Do not install `openclaw-clawdoc.service` for a first-time/default setup. That
file is a separate-gateway example for an isolated `claw-doc` agent.

## Option A: simple `.env` fallback

Use this if you do not want a password manager yet. It is not as strong as
1Password, but it is clear and supported.

```bash
install -d -m 700 ~/.openclaw
cat > ~/.openclaw/.env <<'EOF'
OPENCLAW_GATEWAY_TOKEN=replace_me
TELEGRAM_BOT_TOKEN=replace_me
OPENAI_API_KEY=replace_me
BRAVE_API_KEY=replace_me
EOF
chmod 600 ~/.openclaw/.env
systemctl --user restart openclaw-gateway.service
```

OpenClaw loads `~/.openclaw/.env` / `$OPENCLAW_STATE_DIR/.env` as a trusted
runtime dotenv source. Do not rely on a project/workspace `.env` for provider
credentials.

## Option B: 1Password runtime injection

This pattern keeps API keys/tokens out of git and out of long-lived files on disk.
1Password is strongly recommended for shared or long-lived systems.

## What this gives you

- 1Password is the source of truth for secrets.
- OpenClaw config uses `${VAR}` placeholders only.
- Secrets are rendered at service start into `/run/openclaw/env` (tmpfs, ephemeral).
- No plaintext keys in `openclaw.json`, repo files, or systemd unit inline environment.
- The default gateway remains `openclaw-gateway.service`.

## Architecture

1. `systemd` starts `openclaw-gateway.service`.
2. `ExecStartPre` runs `infra/scripts/openclaw-env-from-1password`.
3. Script pulls secrets via `op read` and writes `/run/openclaw/env` with `0600` permissions.
4. `EnvironmentFile=/run/openclaw/env` loads vars for OpenClaw.
5. OpenClaw starts and resolves `${VAR}` references.

## Files

- `infra/systemd/openclaw-runtime-from-1password.service`
- `infra/scripts/openclaw-env-from-1password`
- `infra/env/openclaw.runtime.env.template`

`infra/systemd/openclaw-runtime-from-1password.service` is a service-body
example. In a normal install, copy/merge those directives into the canonical
`openclaw-gateway.service` or an `openclaw-gateway.service.d/` drop-in. Do not
create a second gateway unless you intentionally want a separate agent/profile.

## Example config usage

```json5
{
  gateway: { auth: { mode: "token", token: "${OPENCLAW_GATEWAY_TOKEN}" } },
  channels: { telegram: { enabled: true, botToken: "${TELEGRAM_BOT_TOKEN}" } },
  models: { providers: { openai: { apiKey: "${OPENAI_API_KEY}" } } },
  tools: { web_search: { providers: { brave: { apiKey: "${BRAVE_API_KEY}" } } } }
}
```

## Rotation workflow

1. Rotate secret in provider (Telegram/OpenAI/etc).
2. Update corresponding 1Password field.
3. Restart service:
   - user service: `systemctl --user restart openclaw-gateway.service`
   - system service: `sudo systemctl restart openclaw-gateway.service`
4. Validate health: `openclaw gateway status` + channel probe.

## Security notes

- Never paste secrets into `Environment=` lines in unit files.
- Never commit generated runtime env files.
- Do not print `/run/openclaw/env` to logs/screenshots.
- If you need stricter posture, use a dedicated non-login service account and lock down `sudo`/journal access.

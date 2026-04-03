# OpenClaw Runtime Secrets via 1Password (No Secrets at Rest)

This pattern keeps API keys/tokens out of git and out of long-lived files on disk.

## What this gives you

- 1Password is the source of truth for secrets.
- OpenClaw config uses `${VAR}` placeholders only.
- Secrets are rendered at service start into `/run/openclaw/env` (tmpfs, ephemeral).
- No plaintext keys in `openclaw.json`, repo files, or systemd unit inline environment.

## Architecture

1. `systemd` starts service.
2. `ExecStartPre` runs `infra/scripts/openclaw-env-from-1password`.
3. Script pulls secrets via `op read` and writes `/run/openclaw/env` with `0600` permissions.
4. `EnvironmentFile=/run/openclaw/env` loads vars for OpenClaw.
5. OpenClaw starts and resolves `${VAR}` references.

## Files

- `infra/systemd/openclaw-runtime-from-1password.service`
- `infra/scripts/openclaw-env-from-1password`
- `infra/env/openclaw.runtime.env.template`

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
3. Restart service: `sudo systemctl restart openclaw`.
4. Validate health: `openclaw gateway status` + channel probe.

## Security notes

- Never paste secrets into `Environment=` lines in unit files.
- Never commit generated runtime env files.
- Do not print `/run/openclaw/env` to logs/screenshots.
- If you need stricter posture, use a dedicated non-login service account and lock down `sudo`/journal access.

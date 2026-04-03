# Secrets Runtime Architecture (claw-doc)

This pattern keeps secrets out of git and out of static systemd units.

## Layout

- `infra/systemd/openclaw-clawdoc.service`
- `infra/scripts/render-env-from-1password.sh`
- `infra/env/.env.template`

## Flow

1. systemd launches `ExecStartPre`.
2. pre-start script pulls secrets from 1Password (`op read ...`).
3. script writes `/run/openclaw-clawdoc/env` with mode `0600`.
4. systemd loads `EnvironmentFile=/run/openclaw-clawdoc/env`.
5. OpenClaw starts with config references like `${OPENCLAW_GATEWAY_TOKEN}`.

## Why this pattern

- No plaintext secrets in git.
- No inline secrets in unit files.
- Easy rotation: update 1Password item, restart service.
- Secrets live in tmpfs (`/run`) and disappear on reboot.

## Rotation runbook (quick)

1. Rotate secret in provider (Telegram/OpenAI/etc).
2. Update corresponding 1Password field.
3. `sudo systemctl restart openclaw-clawdoc`
4. Verify:
   - `systemctl status openclaw-clawdoc`
   - `journalctl -u openclaw-clawdoc -n 100 --no-pager`
   - `openclaw gateway status`

## Notes

- Do not print env file contents in logs/screenshots.
- If using multiple bots/accounts, add account-specific vars and map in `openclaw.json`.
- Prefer least-privilege tokens for GitHub/Twilio/Telegram integrations.

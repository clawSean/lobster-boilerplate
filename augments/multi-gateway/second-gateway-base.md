# Second Gateway: Secrets Runtime Architecture (base pattern)

> **Separate gateway example only.**
>
> This file documents the generic **second isolated gateway** pattern. It is
> useful when you intentionally run a second OpenClaw instance with its own
> working directory, service, port, bot token, and 1Password item — separate
> from the default gateway.
>
> For first-time/default setup, use `docs/core/1password-runtime-secrets.md` and
> wire secrets into `openclaw-gateway.service` instead.

This is the **base** of the [Multi-gateway setups](./README.md) section. The
[Doctor / breakglass agent](./doctor-agent/README.md) example builds directly on
top of it.

This pattern keeps secrets out of git and out of static systemd units.

## Layout

- `infra/systemd/openclaw-second-gateway.service`
- `infra/scripts/render-second-gateway-env-from-1password.sh`
- `infra/env/second-gateway.env.template`

These paths are intentionally `second-gateway`-specific so they never collide
with the default gateway. Replace the service name, working directory, runtime
directory, port, and 1Password item refs when creating your own separate gateway.

## Flow

1. systemd launches `ExecStartPre`.
2. pre-start script pulls secrets from 1Password (`op read ...`).
3. script writes `/run/openclaw-second-gateway/env` with mode `0600`.
4. systemd loads `EnvironmentFile=/run/openclaw-second-gateway/env`.
5. OpenClaw starts with config references like `${OPENCLAW_GATEWAY_TOKEN}`.

## Why this pattern

- No plaintext secrets in git.
- No inline secrets in unit files.
- Easy rotation: update 1Password item, restart service.
- Secrets live in tmpfs (`/run`) and disappear on reboot.

## Rotation runbook (quick)

1. Rotate secret in provider (Telegram/OpenAI/etc).
2. Update corresponding 1Password field.
3. `sudo systemctl restart openclaw-second-gateway`
4. Verify:
   - `systemctl status openclaw-second-gateway`
   - `journalctl -u openclaw-second-gateway -n 100 --no-pager`
   - `openclaw gateway status`

## Notes

- Do not install this service for the standard gateway.
- The standard gateway service is `openclaw-gateway.service`.
- Do not print env file contents in logs/screenshots.
- If using multiple bots/accounts, add account-specific vars and map in `openclaw.json`.
- Prefer least-privilege tokens for GitHub/Twilio/Telegram integrations.

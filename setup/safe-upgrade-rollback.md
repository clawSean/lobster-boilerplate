# Safe OpenClaw Upgrade And Rollback

These scripts are sanitized examples for a normal OpenClaw install. They assume:

- OpenClaw is installed globally from npm as `openclaw`.
- The default service is `openclaw-gateway.service`.
- OpenClaw state lives in `~/.openclaw`.
- Secrets are in `~/.openclaw/.env`, a systemd environment file, or your own password-manager flow.

If your install differs, set environment variables instead of editing secrets or
local paths into the scripts.

> 🍎 **macOS / non-systemd hosts:** the scripts wrap `openclaw update`, which is cross-platform. The `systemctl` service check in the preflight is auto-skipped when `systemctl` is absent (it warns, doesn't fail), so the flow still runs. On macOS the gateway is a launchd LaunchAgent managed by `openclaw gateway install`.

## Files

- `setup/infra/scripts/openclaw-safe-upgrade.sh` - back up config/auth material, run the staged `openclaw update --tag` path, validate, and check gateway health.
- `setup/infra/scripts/openclaw-safe-rollback.sh` - same staged update flow for a specific previous version.
- `setup/infra/scripts/openclaw-safe-switch.sh` - small `upgrade` / `rollback` wrapper.
- `setup/infra/scripts/openclaw-make-restart-backup.sh` - backs up config, env files, and auth profiles with locked-down permissions.
- `setup/infra/scripts/openclaw-restore-restart-backup.sh` - restores a restart backup and runs `openclaw config validate`.
- `setup/infra/scripts/openclaw-restart-preflight.sh` - lightweight validation before planned restarts.

## First-Time Setup

Copy the scripts into your workspace or run them from this repo:

```bash
chmod +x setup/infra/scripts/openclaw-*.sh
setup/infra/scripts/openclaw-restart-preflight.sh
```

If your service or state directory differs:

```bash
OPENCLAW_SERVICE=openclaw-gateway-myagent.service \
OPENCLAW_HOME=/srv/openclaw/myagent \
setup/infra/scripts/openclaw-restart-preflight.sh
```

## Upgrade

Use `latest` or an explicit OpenClaw version:

```bash
ROLLBACK_VERSION=2026.6.6 setup/infra/scripts/openclaw-safe-upgrade.sh latest
```

The script:

1. Resolves `latest` through npm when needed.
2. Refuses versions listed in `KNOWN_BAD_VERSIONS` unless `ALLOW_KNOWN_BAD=1`.
3. Creates a restart-safety backup of config, env files, and auth profiles.
4. Runs `openclaw update --tag <version> --yes`.
5. Relies on OpenClaw's first-party staged updater to coordinate package install, service restart, and gateway verification.
6. Runs `openclaw --version`, `openclaw config validate`, and `openclaw gateway status`.
7. Prints recovery commands if the update fails.

## Rollback

Rollback requires an explicit version:

```bash
setup/infra/scripts/openclaw-safe-rollback.sh 2026.6.6
```

You can also use the wrapper:

```bash
setup/infra/scripts/openclaw-safe-switch.sh upgrade latest
setup/infra/scripts/openclaw-safe-switch.sh rollback 2026.6.6
```

## Restore A Restart Backup

If config or auth material needs to be restored:

```bash
setup/infra/scripts/openclaw-restore-restart-backup.sh ~/.openclaw/backups/restart-safety/pre-upgrade-2026.6.7-YYYYMMDD-HHMMSS
```

The restore script validates config before telling you to restart anything.
It also creates a fresh `pre-restore-*` backup before overwriting live config or auth files.

## Useful Environment Variables

- `OPENCLAW_PACKAGE` - npm package name, default `openclaw`.
- `OPENCLAW_SERVICE` - systemd unit name, default `openclaw-gateway.service`.
- `OPENCLAW_HOME` - state directory, default `~/.openclaw`.
- `LOG_ROOT` - script log directory.
- `ROLLBACK_VERSION` - rollback hint printed during upgrades.
- `KNOWN_BAD_VERSIONS` - space-separated version denylist for your environment.
- `ALLOW_KNOWN_BAD=1` - bypasses the denylist for isolated testing.
- `VALIDATE_COMMAND` - validation command, default `openclaw config validate`.
- `POST_STATUS_COMMAND` - status command, default `openclaw gateway status`.

## Safety Notes

- Keep backup directories out of git. They can contain env files and OAuth/auth profile material.
- `openclaw update` already stages npm package updates in a temporary prefix before swapping the package tree.
- Run `openclaw config validate` after every config restore or manual config edit.
- Do not restart a production gateway until validation passes.
- If update finalization fails after the core package changes, try `openclaw update repair --yes`.
- If config repair is needed, use `openclaw doctor --fix` after reviewing what it will change.

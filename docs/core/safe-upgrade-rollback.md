# Safe OpenClaw Upgrade And Rollback

These scripts are sanitized examples for a normal OpenClaw install. They assume:

- OpenClaw is installed globally from npm as `openclaw`.
- The default service is `openclaw-gateway.service`.
- OpenClaw state lives in `~/.openclaw`.
- Secrets are in `~/.openclaw/.env`, a systemd environment file, or your own password-manager flow.

If your install differs, set environment variables instead of editing secrets or
local paths into the scripts.

## Files

- `infra/scripts/openclaw-safe-upgrade.sh` - stop service, back up state/package, install target version, validate, restart.
- `infra/scripts/openclaw-safe-rollback.sh` - same flow for a specific previous version.
- `infra/scripts/openclaw-safe-switch.sh` - small `upgrade` / `rollback` wrapper.
- `infra/scripts/openclaw-make-restart-backup.sh` - backs up config, env files, and auth profiles with locked-down permissions.
- `infra/scripts/openclaw-restore-restart-backup.sh` - restores a restart backup and runs `openclaw config validate`.
- `infra/scripts/openclaw-restart-preflight.sh` - lightweight validation before planned restarts.

## First-Time Setup

Copy the scripts into your workspace or run them from this repo:

```bash
chmod +x infra/scripts/openclaw-*.sh
infra/scripts/openclaw-restart-preflight.sh
```

If your service or state directory differs:

```bash
OPENCLAW_SERVICE=openclaw-gateway-myagent.service \
OPENCLAW_HOME=/srv/openclaw/myagent \
infra/scripts/openclaw-restart-preflight.sh
```

## Upgrade

Use `latest` or an explicit OpenClaw version:

```bash
ROLLBACK_VERSION=2026.6.6 infra/scripts/openclaw-safe-upgrade.sh latest
```

The script:

1. Resolves `latest` through npm when needed.
2. Refuses versions listed in `KNOWN_BAD_VERSIONS` unless `ALLOW_KNOWN_BAD=1`.
3. Creates a restart-safety backup of config, env files, and auth profiles.
4. Backs up the current global npm package directory when it exists.
5. Stops the configured service.
6. Reinstalls the global package.
7. Runs `openclaw config validate`.
8. Starts the service and prints follow-up commands.

## Rollback

Rollback requires an explicit version:

```bash
infra/scripts/openclaw-safe-rollback.sh 2026.6.6
```

You can also use the wrapper:

```bash
infra/scripts/openclaw-safe-switch.sh upgrade latest
infra/scripts/openclaw-safe-switch.sh rollback 2026.6.6
```

## Restore A Restart Backup

If config or auth material needs to be restored:

```bash
infra/scripts/openclaw-restore-restart-backup.sh ~/.openclaw/backups/restart-safety/pre-upgrade-2026.6.7-YYYYMMDD-HHMMSS
```

The restore script validates config before telling you to restart anything.

## Useful Environment Variables

- `OPENCLAW_PACKAGE` - npm package name, default `openclaw`.
- `OPENCLAW_SERVICE` - systemd unit name, default `openclaw-gateway.service`.
- `OPENCLAW_HOME` - state directory, default `~/.openclaw`.
- `BACKUP_ROOT` - package backup root.
- `LOG_ROOT` - script log directory.
- `ROLLBACK_VERSION` - rollback hint printed during upgrades.
- `KNOWN_BAD_VERSIONS` - space-separated version denylist for your environment.
- `ALLOW_KNOWN_BAD=1` - bypasses the denylist for isolated testing.
- `VALIDATE_COMMAND` - validation command, default `openclaw config validate`.
- `POST_STATUS_COMMAND` - status command, default `openclaw gateway status`.

## Safety Notes

- Keep backup directories out of git. They can contain env files and OAuth/auth profile material.
- Review `npm config get ignore-scripts` before upgrades if your threat model requires locked-down lifecycle scripts.
- Run `openclaw config validate` after every config restore or manual config edit.
- Do not restart a production gateway until validation passes.

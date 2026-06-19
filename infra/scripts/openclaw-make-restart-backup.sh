#!/usr/bin/env bash
set -euo pipefail

label="${1:-manual}"
safe_label="$(printf '%s' "$label" | tr -c 'A-Za-z0-9._-' '-' | sed 's/^-*//; s/-*$//')"
[ -n "$safe_label" ] || safe_label="manual"

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
BACKUP_ROOT="${BACKUP_ROOT:-$OPENCLAW_HOME/backups/restart-safety}"
backup_dir="$BACKUP_ROOT/${safe_label}-$(date +%Y%m%d-%H%M%S)"

install -d -m 700 "$backup_dir"
install -d -m 700 "$backup_dir/env" "$backup_dir/agents"

cat >"$backup_dir/SECRET_CONTAINMENT_NOTICE.txt" <<'NOTICE'
This backup may contain OpenClaw secrets, auth profiles, OAuth material, or
provider tokens. Keep it local, permission-locked, out of git, and out of chat
logs unless you are using a deliberate secret recovery workflow.
NOTICE
chmod 600 "$backup_dir/SECRET_CONTAINMENT_NOTICE.txt"

if [ -f "$OPENCLAW_HOME/openclaw.json" ]; then
  cp -p "$OPENCLAW_HOME/openclaw.json" "$backup_dir/openclaw.json"
else
  printf 'Warning: %s/openclaw.json was not found\n' "$OPENCLAW_HOME" >&2
fi

for file in \
  "$OPENCLAW_HOME/.env" \
  "$OPENCLAW_HOME/gateway.systemd.env"; do
  [ -f "$file" ] && cp -p "$file" "$backup_dir/env/$(basename "$file")"
done

if [ -d "$OPENCLAW_HOME/agents" ]; then
  find "$OPENCLAW_HOME/agents" -type f \( -name 'auth-profiles.json' -o -name 'auth-state.json' \) -print |
    while IFS= read -r file; do
      rel="${file#$OPENCLAW_HOME/agents/}"
      target="$backup_dir/agents/$rel"
      install -d -m 700 "$(dirname "$target")"
      cp -p "$file" "$target"
    done
fi

chmod -R go-rwx "$backup_dir"
printf 'Restart-safety backup created: %s\n' "$backup_dir"

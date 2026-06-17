#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s /path/to/.openclaw/backups/restart-safety/<backup-dir>\n' "$0" >&2
  exit 2
fi

backup_dir="${1%/}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_HOME

if [ ! -d "$backup_dir" ]; then
  printf 'Backup directory not found: %s\n' "$backup_dir" >&2
  exit 2
fi

if [ ! -f "$backup_dir/openclaw.json" ]; then
  printf 'Backup does not contain openclaw.json: %s\n' "$backup_dir" >&2
  exit 2
fi

install -d -m 700 "$OPENCLAW_HOME"

printf 'Restoring OpenClaw restart-safety backup from: %s\n' "$backup_dir"
printf 'Target OpenClaw home: %s\n' "$OPENCLAW_HOME"

"$SCRIPT_DIR/openclaw-make-restart-backup.sh" "pre-restore"

cp -p "$backup_dir/openclaw.json" "$OPENCLAW_HOME/openclaw.json"

if [ -d "$backup_dir/env" ]; then
  find "$backup_dir/env" -maxdepth 1 -type f -print |
    while IFS= read -r file; do
      cp -p "$file" "$OPENCLAW_HOME/$(basename "$file")"
    done
fi

if [ -d "$backup_dir/agents" ]; then
  find "$backup_dir/agents" -type f \( -name 'auth-profiles.json' -o -name 'auth-state.json' \) -print |
    while IFS= read -r file; do
      rel="${file#$backup_dir/agents/}"
      target="$OPENCLAW_HOME/agents/$rel"
      install -d -m 700 "$(dirname "$target")"
      cp -p "$file" "$target"
    done
fi

chmod go-rwx "$OPENCLAW_HOME/openclaw.json" 2>/dev/null || true
if [ -d "$OPENCLAW_HOME/agents" ]; then
  find "$OPENCLAW_HOME/agents" -type f \( -name 'auth-profiles.json' -o -name 'auth-state.json' \) -print |
    while IFS= read -r file; do
      chmod go-rwx "$file" 2>/dev/null || true
    done
fi

openclaw config validate
printf 'Restore complete. Review validation output before restarting OpenClaw.\n'

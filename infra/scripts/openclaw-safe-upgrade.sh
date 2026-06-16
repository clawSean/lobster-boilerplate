#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${1:-latest}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROLLBACK_VERSION="${ROLLBACK_VERSION:-}"
OPENCLAW_PACKAGE="${OPENCLAW_PACKAGE:-openclaw}"
OPENCLAW_SERVICE="${OPENCLAW_SERVICE:-openclaw-gateway.service}"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
LOG_ROOT="${LOG_ROOT:-$OPENCLAW_HOME/logs}"
BACKUP_ROOT="${BACKUP_ROOT:-$OPENCLAW_HOME/backups/openclaw-upgrade}"
KNOWN_BAD_VERSIONS="${KNOWN_BAD_VERSIONS:-}"
ALLOW_KNOWN_BAD="${ALLOW_KNOWN_BAD:-0}"
VALIDATE_COMMAND="${VALIDATE_COMMAND:-openclaw config validate}"
POST_STATUS_COMMAND="${POST_STATUS_COMMAND:-openclaw gateway status}"

timestamp="$(date +%Y%m%d-%H%M%S)"
resolved_target=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [version|latest]

Environment:
  ROLLBACK_VERSION=<version>      Version shown in rollback guidance.
  OPENCLAW_PACKAGE=openclaw
  OPENCLAW_SERVICE=openclaw-gateway.service
  OPENCLAW_HOME=$HOME/.openclaw
  BACKUP_ROOT=$HOME/.openclaw/backups/openclaw-upgrade
  KNOWN_BAD_VERSIONS="2026.x.y 2026.x.z"
  ALLOW_KNOWN_BAD=1
EOF
}

log() {
  printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"
}

run() {
  printf '+ %s\n' "$*"
  "$@"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

validate_version() {
  [[ "$1" =~ ^[0-9]{4}\.[0-9]+\.[0-9]+([-.][A-Za-z0-9.]+)?$ ]]
}

is_known_bad_version() {
  local bad
  for bad in $KNOWN_BAD_VERSIONS; do
    [ "$resolved_target" = "$bad" ] && return 0
  done
  return 1
}

resolve_target_version() {
  if [ "$TARGET_VERSION" = "latest" ]; then
    resolved_target="$(npm view "$OPENCLAW_PACKAGE" version)"
  else
    resolved_target="$TARGET_VERSION"
  fi
}

preflight() {
  command -v npm >/dev/null || die "npm is required"
  command -v openclaw >/dev/null || die "openclaw CLI is required"
  resolve_target_version
  validate_version "$resolved_target" || die "invalid OpenClaw version: $resolved_target"
  if [ -n "$ROLLBACK_VERSION" ]; then
    validate_version "$ROLLBACK_VERSION" || die "invalid rollback version: $ROLLBACK_VERSION"
  fi
  if is_known_bad_version && [ "$ALLOW_KNOWN_BAD" != "1" ]; then
    die "refusing known-bad OpenClaw version $resolved_target; set ALLOW_KNOWN_BAD=1 only for an isolated validation pass"
  fi
  install -d -m 700 "$LOG_ROOT" "$BACKUP_ROOT"
}

stop_service() {
  log "Stopping OpenClaw service"
  if command -v systemctl >/dev/null 2>&1; then
    run systemctl --user stop "$OPENCLAW_SERVICE" || run sudo systemctl stop "$OPENCLAW_SERVICE" || true
  else
    log "systemctl is unavailable; stop the OpenClaw process manually if it is running"
  fi
}

backup_global_install() {
  log "Backing up current global package if present"
  package_root="$(npm root -g)/$OPENCLAW_PACKAGE"
  if [ -d "$package_root" ]; then
    backup_dir="$BACKUP_ROOT/pre-$resolved_target-$timestamp"
    run cp -a "$package_root" "$backup_dir"
    printf 'Package backup: %s\n' "$backup_dir"
  else
    printf 'No existing global package found at %s\n' "$package_root"
  fi
}

install_target() {
  log "Installing $OPENCLAW_PACKAGE@$resolved_target"
  run npm config get ignore-scripts
  run npm rm -g "$OPENCLAW_PACKAGE" || true
  run npm cache verify
  run npm install -g "$OPENCLAW_PACKAGE@$resolved_target"
}

verify_install() {
  log "Verifying install"
  run openclaw version
  run $VALIDATE_COMMAND
}

start_service() {
  log "Starting OpenClaw service"
  if command -v systemctl >/dev/null 2>&1; then
    run systemctl --user start "$OPENCLAW_SERVICE" || run sudo systemctl start "$OPENCLAW_SERVICE" || true
  else
    log "systemctl is unavailable; start OpenClaw manually"
  fi
}

post_start_validation() {
  log "Post-start validation"
  run $VALIDATE_COMMAND
  $POST_STATUS_COMMAND || true
}

print_followup() {
  cat <<EOF

Upgrade attempt finished.

Useful follow-up commands:
  journalctl --user -u $OPENCLAW_SERVICE -f
  openclaw status
  openclaw gateway status

If rollback is needed:
  ROLLBACK_VERSION=${ROLLBACK_VERSION:-<previous-version>} infra/scripts/openclaw-safe-rollback.sh ${ROLLBACK_VERSION:-<previous-version>}
EOF
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi
  preflight
  log "Safe OpenClaw upgrade starting"
  printf 'Target version: %s\n' "$resolved_target"
  [ -n "$ROLLBACK_VERSION" ] && printf 'Rollback hint: %s\n' "$ROLLBACK_VERSION"
  "$SCRIPT_DIR/openclaw-make-restart-backup.sh" "pre-upgrade-$resolved_target" 2>/dev/null || true
  stop_service
  backup_global_install
  install_target | tee "$LOG_ROOT/openclaw-safe-upgrade-$resolved_target-$timestamp.log"
  verify_install
  start_service
  post_start_validation
  print_followup
}

main "$@"

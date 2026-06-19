#!/usr/bin/env bash
set -euo pipefail

ROLLBACK_VERSION="${1:-${ROLLBACK_VERSION:-}}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_HOME
LOG_ROOT="${LOG_ROOT:-$OPENCLAW_HOME/logs}"
KNOWN_BAD_VERSIONS="${KNOWN_BAD_VERSIONS:-}"
ALLOW_KNOWN_BAD="${ALLOW_KNOWN_BAD:-0}"
VALIDATE_COMMAND="${VALIDATE_COMMAND:-openclaw config validate}"
POST_STATUS_COMMAND="${POST_STATUS_COMMAND:-openclaw gateway status}"

timestamp="$(date +%Y%m%d-%H%M%S)"
log_file=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <version>

Environment:
  OPENCLAW_HOME=$HOME/.openclaw
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
    [ "$ROLLBACK_VERSION" = "$bad" ] && return 0
  done
  return 1
}

on_error() {
  local status=$?
  trap - ERR
  printf '\nERROR: OpenClaw rollback failed with exit status %s.\n' "$status" >&2
  [ -n "$log_file" ] && printf 'Log: %s\n' "$log_file" >&2
  cat >&2 <<EOF

Recovery checks:
  openclaw update repair --yes
  openclaw gateway status
  openclaw gateway restart

Manual package recovery, if needed:
  openclaw update --tag $ROLLBACK_VERSION --yes
EOF
  openclaw update repair --yes >/dev/null 2>&1 || true
  $POST_STATUS_COMMAND >/dev/null 2>&1 || true
  exit "$status"
}

preflight() {
  [ -n "$ROLLBACK_VERSION" ] || { usage; die "rollback version is required"; }
  validate_version "$ROLLBACK_VERSION" || die "invalid OpenClaw version: $ROLLBACK_VERSION"
  if is_known_bad_version && [ "$ALLOW_KNOWN_BAD" != "1" ]; then
    die "refusing known-bad OpenClaw version $ROLLBACK_VERSION; set ALLOW_KNOWN_BAD=1 only for an isolated validation pass"
  fi
  command -v openclaw >/dev/null || die "openclaw CLI is required"
  install -d -m 700 "$LOG_ROOT"
  log_file="$LOG_ROOT/openclaw-safe-rollback-$ROLLBACK_VERSION-$timestamp.log"
}

create_restart_backup() {
  log "Creating restart-safety backup"
  run "$SCRIPT_DIR/openclaw-make-restart-backup.sh" "pre-rollback-$ROLLBACK_VERSION"
}

install_target() {
  log "Running staged OpenClaw rollback"
  run openclaw update --tag "$ROLLBACK_VERSION" --yes
}

post_update_validation() {
  log "Post-rollback validation"
  run openclaw --version
  # Intentionally split command strings so operators can override with flags.
  run $VALIDATE_COMMAND
  run $POST_STATUS_COMMAND
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi
  preflight
  trap on_error ERR
  log "Safe OpenClaw rollback starting"
  printf 'Target version: %s\n' "$ROLLBACK_VERSION"
  create_restart_backup
  {
    install_target
    post_update_validation
  } 2>&1 | tee "$log_file"
}

main "$@"

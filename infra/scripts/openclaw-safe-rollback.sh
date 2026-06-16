#!/usr/bin/env bash
set -euo pipefail

ROLLBACK_VERSION="${1:-${ROLLBACK_VERSION:-}}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_PACKAGE="${OPENCLAW_PACKAGE:-openclaw}"
OPENCLAW_SERVICE="${OPENCLAW_SERVICE:-openclaw-gateway.service}"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
LOG_ROOT="${LOG_ROOT:-$OPENCLAW_HOME/logs}"
KNOWN_BAD_VERSIONS="${KNOWN_BAD_VERSIONS:-}"
ALLOW_KNOWN_BAD="${ALLOW_KNOWN_BAD:-0}"
VALIDATE_COMMAND="${VALIDATE_COMMAND:-openclaw config validate}"
POST_STATUS_COMMAND="${POST_STATUS_COMMAND:-openclaw gateway status}"

timestamp="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <version>

Environment:
  OPENCLAW_PACKAGE=openclaw
  OPENCLAW_SERVICE=openclaw-gateway.service
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

preflight() {
  [ -n "$ROLLBACK_VERSION" ] || { usage; die "rollback version is required"; }
  validate_version "$ROLLBACK_VERSION" || die "invalid OpenClaw version: $ROLLBACK_VERSION"
  if is_known_bad_version && [ "$ALLOW_KNOWN_BAD" != "1" ]; then
    die "refusing known-bad OpenClaw version $ROLLBACK_VERSION; set ALLOW_KNOWN_BAD=1 only for an isolated validation pass"
  fi
  command -v npm >/dev/null || die "npm is required"
  command -v openclaw >/dev/null || die "openclaw CLI is required"
  install -d -m 700 "$LOG_ROOT"
}

stop_service() {
  log "Stopping OpenClaw service"
  if command -v systemctl >/dev/null 2>&1; then
    run systemctl --user stop "$OPENCLAW_SERVICE" || run sudo systemctl stop "$OPENCLAW_SERVICE" || true
  else
    log "systemctl is unavailable; stop the OpenClaw process manually if it is running"
  fi
}

install_target() {
  log "Installing $OPENCLAW_PACKAGE@$ROLLBACK_VERSION"
  run npm config get ignore-scripts
  run npm rm -g "$OPENCLAW_PACKAGE" || true
  run npm cache verify
  run npm install -g "$OPENCLAW_PACKAGE@$ROLLBACK_VERSION"
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

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi
  preflight
  log "Safe OpenClaw rollback starting"
  printf 'Target version: %s\n' "$ROLLBACK_VERSION"
  "$SCRIPT_DIR/openclaw-make-restart-backup.sh" "pre-rollback-$ROLLBACK_VERSION" 2>/dev/null || true
  stop_service
  install_target | tee "$LOG_ROOT/openclaw-safe-rollback-$ROLLBACK_VERSION-$timestamp.log"
  verify_install
  start_service
  post_start_validation
}

main "$@"

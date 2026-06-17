#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${1:-latest}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROLLBACK_VERSION="${ROLLBACK_VERSION:-}"
OPENCLAW_PACKAGE="${OPENCLAW_PACKAGE:-openclaw}"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_HOME
LOG_ROOT="${LOG_ROOT:-$OPENCLAW_HOME/logs}"
KNOWN_BAD_VERSIONS="${KNOWN_BAD_VERSIONS:-}"
ALLOW_KNOWN_BAD="${ALLOW_KNOWN_BAD:-0}"
VALIDATE_COMMAND="${VALIDATE_COMMAND:-openclaw config validate}"
POST_STATUS_COMMAND="${POST_STATUS_COMMAND:-openclaw gateway status}"

timestamp="$(date +%Y%m%d-%H%M%S)"
resolved_target=""
log_file=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [version|latest]

Environment:
  ROLLBACK_VERSION=<version>      Version shown in rollback guidance.
  OPENCLAW_PACKAGE=openclaw       Package used only to resolve "latest".
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

on_error() {
  local status=$?
  trap - ERR
  printf '\nERROR: OpenClaw upgrade failed with exit status %s.\n' "$status" >&2
  [ -n "$log_file" ] && printf 'Log: %s\n' "$log_file" >&2
  cat >&2 <<EOF

Recovery checks:
  openclaw update repair --yes
  openclaw gateway status
  openclaw gateway restart

If package rollback is needed:
  infra/scripts/openclaw-safe-rollback.sh ${ROLLBACK_VERSION:-<previous-version>}
EOF
  openclaw update repair --yes >/dev/null 2>&1 || true
  $POST_STATUS_COMMAND >/dev/null 2>&1 || true
  exit "$status"
}

preflight() {
  command -v npm >/dev/null || die "npm is required to resolve openclaw@latest"
  command -v openclaw >/dev/null || die "openclaw CLI is required"
  resolve_target_version
  validate_version "$resolved_target" || die "invalid OpenClaw version: $resolved_target"
  if [ -n "$ROLLBACK_VERSION" ]; then
    validate_version "$ROLLBACK_VERSION" || die "invalid rollback version: $ROLLBACK_VERSION"
  fi
  if is_known_bad_version && [ "$ALLOW_KNOWN_BAD" != "1" ]; then
    die "refusing known-bad OpenClaw version $resolved_target; set ALLOW_KNOWN_BAD=1 only for an isolated validation pass"
  fi
  install -d -m 700 "$LOG_ROOT"
  log_file="$LOG_ROOT/openclaw-safe-upgrade-$resolved_target-$timestamp.log"
}

create_restart_backup() {
  log "Creating restart-safety backup"
  run "$SCRIPT_DIR/openclaw-make-restart-backup.sh" "pre-upgrade-$resolved_target"
}

install_target() {
  log "Running staged OpenClaw update"
  run openclaw update --tag "$resolved_target" --yes
}

post_update_validation() {
  log "Post-update validation"
  run openclaw --version
  # Intentionally split command strings so operators can override with flags.
  run $VALIDATE_COMMAND
  run $POST_STATUS_COMMAND
}

print_followup() {
  cat <<EOF

Upgrade finished.

Useful follow-up commands:
  openclaw status
  openclaw gateway status
  openclaw doctor

If rollback is needed:
  infra/scripts/openclaw-safe-rollback.sh ${ROLLBACK_VERSION:-<previous-version>}
EOF
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi
  preflight
  trap on_error ERR
  log "Safe OpenClaw upgrade starting"
  printf 'Target version: %s\n' "$resolved_target"
  [ -n "$ROLLBACK_VERSION" ] && printf 'Rollback hint: %s\n' "$ROLLBACK_VERSION"
  create_restart_backup
  {
    install_target
    post_update_validation
  } 2>&1 | tee "$log_file"
  print_followup
}

main "$@"

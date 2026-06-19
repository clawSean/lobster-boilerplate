#!/usr/bin/env bash
set -euo pipefail

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_HOME
OPENCLAW_SERVICE="${OPENCLAW_SERVICE:-openclaw-gateway.service}"
VALIDATE_COMMAND="${VALIDATE_COMMAND:-openclaw config validate}"
STATUS_COMMAND="${STATUS_COMMAND:-openclaw gateway status}"
REQUIRE_ENV_FILE="${REQUIRE_ENV_FILE:-0}"
RUNTIME_ENV_FILE="${RUNTIME_ENV_FILE:-$OPENCLAW_HOME/.env}"

failures=0

section() {
  printf '\n== %s ==\n' "$1"
}

pass() {
  printf 'OK: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
}

fail() {
  failures=$((failures + 1))
  printf 'FAIL: %s\n' "$1"
}

section "Config"
if $VALIDATE_COMMAND; then
  pass "OpenClaw config validates"
else
  fail "OpenClaw config validation failed"
fi

section "Secrets"
if [ "$REQUIRE_ENV_FILE" = "1" ]; then
  if [ -r "$RUNTIME_ENV_FILE" ]; then
    pass "runtime env file is readable: $RUNTIME_ENV_FILE"
  else
    fail "runtime env file is not readable: $RUNTIME_ENV_FILE"
  fi
else
  if [ -r "$RUNTIME_ENV_FILE" ]; then
    pass "runtime env file is present: $RUNTIME_ENV_FILE"
  else
    warn "runtime env file is not present; set REQUIRE_ENV_FILE=1 to make this a blocker"
  fi
fi

section "Service"
if command -v systemctl >/dev/null 2>&1; then
  if systemctl --user cat "$OPENCLAW_SERVICE" >/dev/null 2>&1; then
    pass "user service exists: $OPENCLAW_SERVICE"
  elif systemctl cat "$OPENCLAW_SERVICE" >/dev/null 2>&1; then
    pass "system service exists: $OPENCLAW_SERVICE"
  else
    warn "systemd service was not found by name: $OPENCLAW_SERVICE"
  fi
else
  warn "systemctl is unavailable; service check skipped"
fi

section "Gateway"
if $STATUS_COMMAND; then
  pass "gateway status command exits cleanly"
else
  warn "gateway status command did not exit cleanly; this can be expected before first start"
fi

section "Result"
if [ "$failures" -eq 0 ]; then
  pass "restart preflight passed"
else
  printf 'FAIL: %s restart preflight blocker(s)\n' "$failures"
fi

if [ "$failures" -eq 0 ]; then
  exit 0
fi
exit 1

#!/usr/bin/env bash
set -euo pipefail

# Separate gateway example for a second isolated OpenClaw gateway.
# For the standard gateway, use infra/scripts/openclaw-env-from-1password and
# wire it into openclaw-gateway.service.

OUT_FILE="${1:-/run/openclaw-second-gateway/env}"
OUT_DIR="$(dirname "$OUT_FILE")"

mkdir -p "$OUT_DIR"
umask 077

# Requires active 1Password CLI auth/session (`op signin` or service account token)
# Replace vault/item/field refs with your own entries.
cat >"$OUT_FILE" <<EOF
OPENCLAW_GATEWAY_TOKEN=$(op read "op://Infrastructure/second-gateway/OPENCLAW_GATEWAY_TOKEN")
TELEGRAM_BOT_TOKEN=$(op read "op://Infrastructure/second-gateway/TELEGRAM_BOT_TOKEN")
OPENAI_API_KEY=$(op read "op://Infrastructure/second-gateway/OPENAI_API_KEY")
BRAVE_API_KEY=$(op read "op://Infrastructure/second-gateway/BRAVE_API_KEY")
EOF

chmod 600 "$OUT_FILE"

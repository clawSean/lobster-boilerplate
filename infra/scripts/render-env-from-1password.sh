#!/usr/bin/env bash
set -euo pipefail

OUT_FILE="${1:-/run/openclaw-clawdoc/env}"
OUT_DIR="$(dirname "$OUT_FILE")"

mkdir -p "$OUT_DIR"
umask 077

# Requires active 1Password CLI auth/session (`op signin` or service account token)
# Replace vault/item/field refs with your own entries.
cat >"$OUT_FILE" <<EOF
OPENCLAW_GATEWAY_TOKEN=$(op read "op://Infrastructure/claw-doc/OPENCLAW_GATEWAY_TOKEN")
TELEGRAM_BOT_TOKEN=$(op read "op://Infrastructure/claw-doc/TELEGRAM_BOT_TOKEN")
OPENAI_API_KEY=$(op read "op://Infrastructure/claw-doc/OPENAI_API_KEY")
BRAVE_API_KEY=$(op read "op://Infrastructure/claw-doc/BRAVE_API_KEY")
EOF

chmod 600 "$OUT_FILE"

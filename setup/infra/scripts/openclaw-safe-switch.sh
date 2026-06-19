#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") upgrade [version|latest]
  $(basename "$0") rollback <version>
EOF
}

action="${1:-}"
version="${2:-}"

case "$action" in
  upgrade)
    exec "$SCRIPT_DIR/openclaw-safe-upgrade.sh" "${version:-latest}"
    ;;
  rollback)
    [ -n "$version" ] || {
      usage
      exit 2
    }
    exec "$SCRIPT_DIR/openclaw-safe-rollback.sh" "$version"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac

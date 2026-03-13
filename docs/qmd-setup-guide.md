# 🦞 OpenClaw QMD Memory Setup Guide (QMD 2.x)

**Verified with:** OpenClaw `2026.3.8` + QMD `2.0.1` (updated 2026-03-12)

This guide covers enabling OpenClaw memory with the **QMD backend** (`memory.backend = "qmd"`).

---

## 🏗️ Prerequisites

### 1) Bun runtime

```bash
curl -fsSL https://bun.sh/install | bash
```

### 2) SQLite + build tools

- Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y sqlite3 build-essential
```

- macOS:

```bash
brew install sqlite
xcode-select --install
```

---

## 📦 Install / Upgrade QMD (use npm package, not GitHub URL)

> Important: for QMD 2.x, install from npm package name.

```bash
bun install -g @tobilu/qmd@latest
qmd --version
```

Expected: `qmd 2.x`

If Bun reports blocked postinstall scripts, trust and run them:

```bash
bun pm -g untrusted
bun pm -g trust better-sqlite3
```

---

## 🔧 Ensure gateway can find `qmd`

QMD usually lands in `~/.bun/bin/qmd`. Make sure that location is on PATH for the OpenClaw gateway service, or symlink it:

```bash
sudo ln -sf "$HOME/.bun/bin/bun" /usr/local/bin/bun
sudo ln -sf "$HOME/.bun/bin/qmd" /usr/local/bin/qmd
```

---

## ⚙️ OpenClaw config

In `~/.openclaw/openclaw.json`, set (or keep) this shape:

```json
{
  "memory": {
    "backend": "qmd",
    "citations": "auto",
    "qmd": {
      "command": "/usr/local/bin/qmd",
      "includeDefaultMemory": true,
      "searchMode": "search",
      "update": {
        "interval": "5m",
        "debounceMs": 15000,
        "onBoot": true,
        "waitForBootSync": false
      },
      "limits": {
        "maxResults": 6
      }
    }
  }
}
```

---

## 🚀 Warm-up (recommended)

Use the same XDG dirs OpenClaw uses so QMD builds/warms the same index:

```bash
STATE_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
export XDG_CONFIG_HOME="$STATE_DIR/agents/mainelobster/qmd/xdg-config"
export XDG_CACHE_HOME="$STATE_DIR/agents/mainelobster/qmd/xdg-cache"

qmd update
qmd embed
```

Then restart gateway:

```bash
openclaw gateway restart
```

---

## ✅ Verification

```bash
qmd --version
openclaw status
openclaw memory search "test query"
```

What you want:
- QMD shows `2.x`
- OpenClaw status shows memory/vector ready
- `openclaw memory search` returns results

---

## 🧯 Troubleshooting

- **`Could not locate ... better_sqlite3.node`**
  - Run:
  ```bash
  bun pm -g trust better-sqlite3
  ```

- **Vulkan build errors / fallback logs on Linux VPS**
  - Usually harmless; QMD can run CPU-only.

- **Very slow first query**
  - Normal on first run: QMD downloads local models.

- **Gateway restart warns token mismatch**
  - Sync service token first:
  ```bash
  openclaw gateway install --force
  ```

- **Mac mini note**
  - Apple Silicon uses Metal acceleration and is typically much faster than CPU-only VPS for embeddings/reranking.

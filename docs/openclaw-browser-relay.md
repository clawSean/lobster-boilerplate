# OpenClaw Browser Relay (Chrome Extension) — Remote Gateway Setup

**Verified with: OpenClaw 2026.2.26**

**Last updated:** 2026-02-27

**Goal:** Let the OpenClaw agent on a remote VPS control your existing, already-logged-in Chrome tabs on your local machine (laptop/desktop) via the Chrome extension + Tailscale.

---

## Architecture

```
VPS (gateway host)                    Local machine (browser host)
┌──────────────────┐                  ┌──────────────────────────────┐
│  OpenClaw Gateway │◄── Tailscale ──►│  Node Host                   │
│  127.0.0.1:18789 │    (WSS/443)    │    ├── Browser Control (18791)│
│                  │                  │    └── Extension Relay (18792)│
│  Tailscale Serve │                  │                              │
│  wss://host.ts.net                  │  Chrome Extension            │
└──────────────────┘                  │    └── Attached Tab(s)       │
                                      └──────────────────────────────┘
```

Five pieces:

1. **Gateway** (VPS) — runs the agent, receives tool calls, proxies browser commands to the node.
2. **Tailscale Serve** (VPS) — provides WSS so the node host can connect securely.
3. **Node Host** (local machine) — connects to the gateway, runs a local browser control service + relay.
4. **Extension Relay** (local machine) — loopback server on port 18792 bridging node host and Chrome extension.
5. **Chrome Extension** (local machine) — attaches to a tab via `chrome.debugger`, pipes CDP to the relay.

---

## Prerequisites

- Tailscale installed and connected on both machines (see [tailscale-setup.md](tailscale-setup.md))
- Gateway configured with Tailscale Serve (see [tailscale-setup.md](tailscale-setup.md))
- OpenClaw installed on both machines
- **Same OpenClaw version on both machines** (version mismatch causes `device signature invalid` errors)

---

## Step 1: VPS gateway config

<!-- Most of this should already be done if you followed tailscale-setup.md -->

Ensure these gateway settings in `~/.openclaw/openclaw.json` on the VPS:

```json
{
  "gateway": {
    "bind": "loopback",
    "tailscale": { "mode": "serve" },
    "auth": {
      "mode": "token",
      "token": "YOUR_TOKEN",
      "allowTailscale": true
    },
    "nodes": {
      "browser": {
        "mode": "auto",
        "node": "YOUR_NODE_DISPLAY_NAME"
      }
    }
  }
}
```

If not already set:

```bash
openclaw config set gateway.nodes.browser.mode auto
# Set after the node is connected and you know its display name:
openclaw config set gateway.nodes.browser.node "My Laptop"
openclaw gateway restart
```

> **Critical:** `gateway.nodes.browser.node` must be set to your node's display name (the `--display-name` you use when starting the node host). Without this pin, the gateway routes browser commands to its own local relay (on the VPS), not through the node to your laptop.

---

## Step 2: Install OpenClaw on local machine

<!-- VARIES: use your OS package manager if preferred -->

```bash
npm install -g openclaw
openclaw --version
```

> **Version must match the VPS.** If the VPS runs 2026.2.26, the local machine must too. Mismatched versions cause `device signature invalid` during the node host handshake. Update the VPS first if needed: `npm install -g openclaw@latest && openclaw gateway restart`

---

## Step 3: Install the Chrome extension (local machine)

```bash
openclaw browser extension install
openclaw browser extension path
```

In Chrome:

1. Go to `chrome://extensions`
2. Enable **Developer mode**
3. Click **Load unpacked** → select the directory printed by `extension path`
4. Pin the extension to the toolbar

---

## Step 4: Configure the Chrome extension (local machine)

Open the extension's **Options page** (right-click extension icon → Options) and set:

| Field | Value |
|-------|-------|
| **Port** | `18792` |
| **Gateway token** | Must match `gateway.auth.token` from the VPS config |

> The relay port is derived as **gateway port + 3** (18789 + 3 = 18792). This is always 18792 unless you changed the gateway port.

---

## Step 5: Configure local `openclaw.json` (local machine)

Create `~/.openclaw/openclaw.json` on the local machine with **only** these settings:

```json
{
  "browser": {
    "enabled": true
  },
  "gateway": {
    "port": 18789
  }
}
```

> **Do NOT set `gateway.mode: "remote"` or `gateway.remote` here.** Adding remote gateway config causes CLI commands to try pairing a separate device identity, which conflicts with the node host connection. The node host handles the remote connection itself via its `--host` flag.

> **`gateway.port: 18789`** is required so the node host derives the correct relay port (18792). Without it, the relay may bind to a privileged port (e.g. 446 if you connect on port 443) and silently fail.

> **`browser.enabled: true`** tells the node host to start the browser control service and extension relay locally.

---

## Step 6: Start the node host (local machine)

<!-- VARIES: hostname, token, and display name are unique to your setup -->

```bash
export OPENCLAW_GATEWAY_TOKEN="YOUR_GATEWAY_AUTH_TOKEN"
openclaw node run --host YOUR_HOSTNAME.ts.net --port 443 --tls --display-name "My Laptop"
```

Replace:
- `YOUR_HOSTNAME.ts.net` with your VPS MagicDNS hostname (run `tailscale status --json | python3 -c "import sys,json; print(json.load(sys.stdin)['Self']['DNSName'].rstrip('.'))"` on the VPS)
- `YOUR_GATEWAY_AUTH_TOKEN` with the token from `gateway.auth.token` in the VPS config
- `"My Laptop"` with whatever display name you want (must match the `gateway.nodes.browser.node` pin on the VPS)

The terminal should show the PATH and then sit idle with no errors. If it exits, see Troubleshooting below.

---

## Step 7: Approve the node pairing (VPS)

First-time connections require pairing approval:

```bash
openclaw devices list       # find the pending request
openclaw devices approve <requestId>
```

The node host auto-reconnects after approval. Subsequent connections don't need re-approval.

> If the node host exits with `pairing required` before you can approve it, just restart it — the gateway auto-approves within a few seconds, or use `Restart=always` in a systemd service (see Persistent Setup below).

---

## Step 8: Pin the browser node (VPS)

If you haven't already:

```bash
openclaw config set gateway.nodes.browser.node "My Laptop"
openclaw gateway restart
```

Wait ~10 seconds for the node to reconnect, then verify:

```bash
openclaw nodes status    # should show "paired · connected"
```

---

## Step 9: Attach a tab and test

On the local machine:
1. Open any Chrome tab
2. Click the OpenClaw extension icon — badge should show **ON**

From the VPS:

```bash
openclaw browser --browser-profile chrome tabs
```

This should list the tab(s) you attached. If it works, the agent can now use the `browser` tool with `profile="chrome"` to control your Chrome tabs.

---

## Verify the relay (local machine)

```bash
curl http://127.0.0.1:18792/
```

Should return `OK`. If it returns "Couldn't connect", the relay isn't running — see Troubleshooting.

---

## Persistent setup (make the node host a service)

### macOS (launchd)

```bash
openclaw node install --host YOUR_HOSTNAME.ts.net --port 443 --tls --display-name "My Laptop"
```

### Linux (systemd)

`openclaw node install` has had bugs on Linux. Create the unit manually:

```ini
# /etc/systemd/system/openclaw-node.service
[Unit]
Description=OpenClaw Node Host
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=simple
Environment=OPENCLAW_GATEWAY_TOKEN=YOUR_TOKEN
ExecStart=/usr/bin/openclaw node run --host YOUR_HOSTNAME.ts.net --port 443 --tls --display-name "My Node"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now openclaw-node
```

`Restart=always` with `RestartSec=5` handles the first-connection pairing dance (node connects → "pairing required" → exits → systemd restarts → gateway auto-approves → node stays connected).

---

## After OpenClaw updates

On **both** machines:

```bash
npm install -g openclaw@latest
```

On the local machine:

```bash
openclaw browser extension install
```

Then in `chrome://extensions`, click **Reload** on the extension.

On the VPS:

```bash
openclaw gateway restart
```

> Always update both machines to the same version before restarting. Version mismatch breaks the device auth handshake.

---

## Troubleshooting

### `device signature invalid`

**Cause:** OpenClaw version mismatch between gateway and node host.
**Fix:** Update both to the same version: `npm install -g openclaw@latest`

### `SECURITY ERROR: Cannot connect over plaintext ws://`

**Cause:** Gateway is using `bind: "tailnet"` (direct bind) instead of Tailscale Serve.
**Fix:** Set `gateway.bind: "loopback"` and `gateway.tailscale.mode: "serve"`. See [tailscale-setup.md](tailscale-setup.md).

### `pairing required`

**Cause:** First connection from a new device identity.
**Fix:** Approve on the VPS: `openclaw devices list` then `openclaw devices approve <requestId>`. If using a systemd service with `Restart=always`, it resolves automatically.

### Relay not reachable (`curl` fails on 18792)

**Cause (1):** `browser.enabled: true` missing from local `~/.openclaw/openclaw.json`.
**Cause (2):** `gateway.port: 18789` missing from local config — relay derived wrong port.
**Cause (3):** `gateway.mode: "remote"` set in local config — remove it.
**Fix:** Ensure local config has only `browser.enabled: true` and `gateway.port: 18789`. Restart the node host.

### `browser tabs` returns empty or uses VPS relay

**Cause:** `gateway.nodes.browser.node` not set — gateway routes browser commands to its own local relay instead of through the node.
**Fix:** `openclaw config set gateway.nodes.browser.node "YOUR_NODE_NAME" && openclaw gateway restart`

### Extension badge shows `!`

**Cause:** Relay not running, or token mismatch in extension Options.
**Fix:** Check `curl http://127.0.0.1:18792/` (relay running?). Verify token in extension Options matches `gateway.auth.token`.

### Node disconnects on gateway restart

**Expected.** The node host auto-reconnects within a few seconds. If using `openclaw node run` (foreground), it reconnects automatically. If it doesn't, restart it manually.

---

## Security notes

- The Chrome extension uses `chrome.debugger` — when attached, the agent can click, type, navigate, and read page content using whatever that tab is logged into.
- **Use a dedicated Chrome profile** for relay usage (not your daily-driver profile).
- The relay only listens on loopback (`127.0.0.1`). Traffic between VPS and local machine is encrypted by Tailscale (WireGuard) + TLS (Tailscale Serve).
- Keep relay ports off LAN/public. Never use Tailscale Funnel for browser control.
- Treat node pairing like operator access.

---

## Quick reference

| What | Where | Value |
|------|-------|-------|
| Gateway port | VPS | 18789 (default) |
| Browser control port | Local machine | 18791 (gateway + 2) |
| Extension relay port | Local machine | 18792 (gateway + 3) |
| Tailscale Serve port | VPS | 443 (HTTPS) |
| Gateway config | VPS | `~/.openclaw/openclaw.json` |
| Node host config | Local machine | `~/.openclaw/openclaw.json` |
| Extension files | Local machine | `~/.openclaw/browser/chrome-extension/` |
| Node identity | Local machine | `~/.openclaw/identity/device.json` |
| Node pairing token | Local machine | `~/.openclaw/node.json` |

---

## Docs

- Chrome extension: [docs.openclaw.ai/tools/chrome-extension](https://docs.openclaw.ai/tools/chrome-extension)
- Browser tool: [docs.openclaw.ai/tools/browser](https://docs.openclaw.ai/tools/browser)
- Node host CLI: [docs.openclaw.ai/cli/node](https://docs.openclaw.ai/cli/node)
- Tailscale integration: [docs.openclaw.ai/gateway/tailscale](https://docs.openclaw.ai/gateway/tailscale)
- Remote access: [docs.openclaw.ai/gateway/remote](https://docs.openclaw.ai/gateway/remote)

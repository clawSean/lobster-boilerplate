# Tailscale Setup Guide

**Goal:** Create a private encrypted network (tailnet) between two or more machines. Zero impact on existing services, SSH, DNS, web hosting, or firewall rules.

**What Tailscale does:** Installs a virtual network interface with a private `100.x.x.x` IP and creates an encrypted WireGuard tunnel between your devices. That's it — purely additive, touches nothing else.

---

## Prerequisites

- A Tailscale account (free tier covers 100 devices): [login.tailscale.com](https://login.tailscale.com)

---

## Install

### macOS

**Option A — Website (recommended):**
Go to [login.tailscale.com](https://login.tailscale.com), create an account, and download the macOS app from [tailscale.com/download](https://tailscale.com/download). Install, open, sign in.

**Option B — Homebrew:**
```bash
brew install tailscale
tailscale up
```

### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
```

This prints an auth URL — open it in any browser where you're logged into Tailscale and approve the device.

### Windows

Download from [tailscale.com/download](https://tailscale.com/download). Install, open, sign in.

---

## Verify

Run on any connected machine:

```bash
tailscale status
```

You should see all your devices listed with their `100.x.x.x` IPs and status.

Example output:

```
100.122.114.48  my-vps              user@example  linux  -
100.78.18.37    my-macbook          user@example  macOS  idle, tx 1188 rx 1236
```

---

## Test Connectivity

```bash
ping <other-device-tailscale-ip>
```

Or SSH directly over Tailscale:

```bash
ssh user@100.x.x.x
```

---

## Useful Commands

| Command | Purpose |
|---------|---------|
| `tailscale status` | List all devices + connection state |
| `tailscale ip -4` | Show this machine's Tailscale IPv4 |
| `tailscale ping <host>` | Test direct connection to another device |
| `tailscale up` | Connect / authenticate |
| `tailscale down` | Disconnect (keeps installed) |
| `tailscale logout` | Deauth this device from the tailnet |
| `tailscale serve status` | Show active Tailscale Serve config |

---

## Using with OpenClaw

### Why Tailscale Serve (not direct tailnet bind)

OpenClaw supports two ways to expose the gateway on a tailnet:

| Approach | Config | Protocol | Node host support |
|----------|--------|----------|-------------------|
| **Direct bind** | `gateway.bind: "tailnet"` | `ws://` (plaintext) | Broken — node hosts refuse plaintext ws:// to non-loopback addresses |
| **Tailscale Serve** | `gateway.bind: "loopback"` + `tailscale.mode: "serve"` | `wss://` (TLS) | Works — Tailscale Serve provides HTTPS/WSS |

> **Use Tailscale Serve.** Direct tailnet bind (`gateway.bind: "tailnet"`) causes `SECURITY ERROR: Cannot connect over plaintext ws://` when node hosts try to connect from other machines. Tailscale Serve keeps the gateway on loopback while providing WSS through Tailscale's HTTPS proxy.

### Setup (VPS / gateway host)

<!-- VARIES: Tailscale IP and MagicDNS hostname are unique to your tailnet -->

```bash
# 1. Confirm Tailscale is connected
tailscale status

# 2. Get your MagicDNS hostname (you'll need this later)
tailscale status --json | python3 -c "import sys,json; print(json.load(sys.stdin)['Self']['DNSName'].rstrip('.'))"
# Example: my-vps.tail12345.ts.net

# 3. Configure the gateway for Tailscale Serve
openclaw config set gateway.bind loopback
openclaw config set gateway.tailscale.mode serve
openclaw config set gateway.auth.mode token

# 4. Set allowed origins for the Control UI (use your MagicDNS hostname)
openclaw config set gateway.controlUi.allowedOrigins '["https://<YOUR_MAGICDNS_HOSTNAME>"]'

# 5. Ensure an auth token exists
openclaw config get gateway.auth.token
# If empty, set one:
openclaw config set gateway.auth.token "$(openssl rand -hex 24)"

# 6. Restart
openclaw gateway restart
```

### Verify Tailscale Serve

```bash
tailscale serve status
```

Expected output:

```
https://<hostname>.ts.net (tailnet only)
|-- / proxy http://127.0.0.1:18789
```

The gateway is now accessible at `https://<hostname>.ts.net` from any device on your tailnet. Traffic is encrypted by both WireGuard (Tailscale) and TLS (Serve).

### Resulting `openclaw.json` gateway section

<!-- VARIES: token, hostname, and tailscale domain are unique to your setup -->

```json
{
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "controlUi": {
      "allowedOrigins": [
        "https://my-vps.tail12345.ts.net"
      ]
    },
    "auth": {
      "mode": "token",
      "token": "your-secret-token-here",
      "allowTailscale": true
    },
    "trustedProxies": [
      "127.0.0.1"
    ],
    "tailscale": {
      "mode": "serve",
      "resetOnExit": false
    }
  }
}
```

### Connecting from other tailnet devices

Devices on your tailnet reach the gateway via the MagicDNS hostname:

- **Control UI:** `https://<hostname>.ts.net/`
- **WebSocket:** `wss://<hostname>.ts.net` (port 443, TLS)
- **Node hosts:** `openclaw node run --host <hostname>.ts.net --port 443 --tls`

Loopback (`127.0.0.1:18789`) still works on the VPS itself.

---

## Tailscale Serve prerequisites

- Tailscale CLI must be installed and logged in.
- HTTPS must be enabled for your tailnet (Tailscale prompts if missing).
- MagicDNS must be enabled (on by default for new tailnets).

---

## Key Facts

- **No impact** on existing networking, ports, services, DNS, or SSH
- **~20MB RAM** footprint — lightweight daemon
- **Survives reboots** — installed as a system service automatically
- **Free tier** — up to 100 devices, 3 users
- **MagicDNS** — devices are reachable by hostname (e.g., `ssh my-vps`) if enabled in the Tailscale admin console
- **Re-auth:** Some devices may need periodic re-authentication depending on your tailnet's key expiry policy. Check the admin console at [login.tailscale.com](https://login.tailscale.com).

---

## Docs

- OpenClaw Tailscale docs: [docs.openclaw.ai/gateway/tailscale](https://docs.openclaw.ai/gateway/tailscale)
- Tailscale Serve overview: [tailscale.com/kb/1312/serve](https://tailscale.com/kb/1312/serve)
- `tailscale serve` command: [tailscale.com/kb/1242/tailscale-serve](https://tailscale.com/kb/1242/tailscale-serve)

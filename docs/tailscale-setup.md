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

---

## Using with OpenClaw

Once Tailscale is running on both machines, configure the OpenClaw Gateway to listen on the Tailscale interface instead of `0.0.0.0` (all interfaces):

```bash
# 1. Get your Tailscale IP
tailscale ip -4
# Example: 100.122.114.48

# 2. Set bind to tailnet
openclaw config set gateway.bind tailnet

# 3. REQUIRED: Set allowed origins for the Control UI
#    Without this, the Gateway will CRASH on restart for non-loopback binds.
openclaw config set gateway.controlUi.allowedOrigins '["http://<YOUR_TAILSCALE_IP>:18789"]'

# 4. Ensure auth token is set
openclaw config get gateway.auth.token
# If empty:
openclaw config set gateway.auth.token "your-secret-token"

# 5. NOW restart
openclaw gateway restart
```

> ⚠️ **CRITICAL:** Steps 2 and 3 must BOTH be done before restarting. If you only set `gateway.bind: "tailnet"` without `controlUi.allowedOrigins`, the Gateway crashes immediately on startup and you lose access (including SSH-based agent sessions that depend on it). You'll need to manually edit `~/.openclaw/openclaw.json` to fix it.

This binds the Gateway **only** to the Tailscale IP — not the public interface, not loopback. Only devices on your tailnet can reach it.

Node hosts on other tailnet machines connect using the VPS Tailscale IP:

```bash
openclaw node run --host <vps-tailscale-ip> --port 18789
```

> **Note:** With `bind: "tailnet"`, loopback (`127.0.0.1:18789`) no longer works. All connections go through the Tailscale IP — including local ones. This is fine for a dedicated VPS.

---

## Key Facts

- **No impact** on existing networking, ports, services, DNS, or SSH
- **~20MB RAM** footprint — lightweight daemon
- **Survives reboots** — installed as a system service automatically
- **Free tier** — up to 100 devices, 3 users
- **MagicDNS** — devices are reachable by hostname (e.g., `ssh my-vps`) if enabled in the Tailscale admin console
- **Re-auth:** Some devices may need periodic re-authentication depending on your tailnet's key expiry policy. Check the admin console at [login.tailscale.com](https://login.tailscale.com).

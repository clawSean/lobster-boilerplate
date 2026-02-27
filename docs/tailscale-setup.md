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

## Key Facts

- **No impact** on existing networking, ports, services, DNS, or SSH
- **~20MB RAM** footprint — lightweight daemon
- **Survives reboots** — installed as a system service automatically
- **Free tier** — up to 100 devices, 3 users
- **MagicDNS** — devices are reachable by hostname (e.g., `ssh my-vps`) if enabled in the Tailscale admin console
- **Re-auth:** Some devices may need periodic re-authentication depending on your tailnet's key expiry policy. Check the admin console at [login.tailscale.com](https://login.tailscale.com).

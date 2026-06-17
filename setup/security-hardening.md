# Security hardening

> **Decide your trust boundaries first, then install OpenClaw inside them.** The dangerous default failure mode is accidentally creating a remote, natural-language control plane over your machine — an internet-connected command runner with secrets sprinkled everywhere. This is the order of operations to avoid that.
>
> Contributed by **[@nicknmorty](https://github.com/nicknmorty)**.

Do these *before* and alongside the [SETUP](SETUP.md) steps — security is part of getting running, not an afterthought.

## 1. Bind the Gateway to loopback

Do **not** expose the gateway directly to LAN/WAN unless you fully understand the auth model. Preferred shape:

```json5
gateway: { bind: "loopback", auth: { mode: "token" } }
```

Reach it remotely through **Tailscale Serve** (see [tailscale-setup.md](tailscale-setup.md)) or another private, authenticated tunnel — never a raw open port.

## 2. Lock down Telegram / users immediately

Use **allowlists, not open access**. The owner should be explicit; an admin should never be accidentally removed. Treat commands, exec, elevated tools, group access, and DM access as **separate surfaces** — review each one.

## 3. Secrets live in `.env`, not the config

Config gets copied, logged, diffed, pasted, backed up, and reviewed. The config should reference `${TELEGRAM_BOT_TOKEN}` / `${GATEWAY_AUTH_TOKEN}`, **not** the real value. `.env` is your one protected local secret store — tight permissions, gitignored, kept out of scanner output. (See [1password-runtime-secrets.md](1password-runtime-secrets.md) for the runtime-injection path.)

## 4. Firewall first, then services

On a Pi / Debian-ish host:

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw enable
sudo ufw status verbose
```

Need LAN SSH too? Add a **narrow** rule, not "anywhere":

```bash
sudo ufw allow from 192.168.4.0/22 to any port 22 proto tcp
```

Do **not** open the OpenClaw gateway port to the world — ideally not even to the LAN.

## 5. Harden SSH

Disable password auth, disable root login, use keys, and prefer Tailscale-only SSH. SSH is usually the one public-ish door people forget about.

## 6. Install Fail2ban

It watches logs for repeated failed logins and temporarily bans the source IP via firewall rules. Not magic, but it cuts brute-force noise and adds an automated response around SSH.

## 7. Validate config after every change

Non-negotiable for OpenClaw — run this **before every restart**:

```bash
openclaw config validate
```

## 8. Treat exec / tools as the danger zone

Any agent that can run shell, edit files, send messages, schedule jobs, call APIs, or touch memory is **high trust**. Start narrow: allowlist tools, named approvers, no broad `full` exec unless you know exactly why.

## 9. Backups / recovery before cleverness

Back up config, workspace/memory, cron jobs, auth-profile metadata, systemd user services, and project repos. Keep secrets separate and intentionally handled. (Safe upgrade/rollback scripts live in [`infra/`](infra/) as a companion.)

## 10. A recurring audit

Even a weekly check — **ports, listeners, gateway bind, Telegram allowlists, exec policy, cron jobs, plugin/skill changes** — catches drift before it bites.

---

**Bottom line:** the real first-time advice is not "install OpenClaw, then add security." It's "decide your trust boundaries first, then install OpenClaw inside them."

# Multi-gateway setups

Most people only ever need the **default** OpenClaw gateway documented in
`setup/`. This section is for the less common — but very useful — case where
you intentionally run **more than one** OpenClaw gateway on the same host, each
with its own working directory, service, port, bot token, and secrets.

> **Not the same as `openclaw doctor`.** OpenClaw ships a built-in
> `openclaw doctor` (and `openclaw doctor --fix`) CLI command for quick
> self-healing of a single install. The "doctor / breakglass agent" below is a
> different thing entirely: a *dedicated agent on its own gateway*. Keep the two
> concepts distinct.

## Why a second gateway

Running a second gateway gives you a genuine isolation boundary instead of just
a different prompt set. That matters when an agent needs:

- stronger or different tool access than your everyday assistant
- a separate trust boundary and smaller blast radius
- cleaner runtime state, credentials, and logs
- its own bot/channel routing

## How this section is organized

Each entry is a sibling that builds on the same base pattern, so you can add new
gateway roles later without restructuring:

- **[Second gateway — base pattern](./second-gateway-base.md)** — the generic,
  unopinionated mechanics: a dedicated systemd service, a 1Password-backed
  runtime env, and a distinct port/working directory. Start here.
- **[Doctor / breakglass agent](./doctor-agent/README.md)** — a worked example
  built on the base pattern: a docs-first operational agent for diagnosis and
  remediation, with a clear Doctor-mode vs Advisor-mode distinction.
- **[Sandbox gateway](./sandbox-gateway.md)** — a deliberately locked-down
  gateway for safely testing bots, slash commands, or risky configs: aggressive
  tool/channel lockdown on top of the base, plus the Docker-vs-pseudo-sandbox
  tradeoff. Contributed by [@nicknmorty](https://github.com/nicknmorty).

## Supporting infra

The base pattern is backed by these files (rename them per gateway role):

- `setup/infra/systemd/openclaw-second-gateway.service`
- `setup/infra/scripts/render-second-gateway-env-from-1password.sh`
- `setup/infra/env/second-gateway.env.template`

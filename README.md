# lobster-boilerplate

**A setup *assistant* for bootstrapping an OpenClaw + Telegram agent** — the *why* behind a good-default setup, plus a map to the rest of the ecosystem.

It's not just a copy-paste kit: it takes you from a fresh host — a VPS, a Raspberry Pi, a home server, a cloud VM, or your own Linux/Mac box — to a running agent on one readable path, explaining each config choice (and its failure mode) so you understand what you're building, then points you to the right sibling project for anything deeper.

> Deliberately **light on code, heavy on config + docs**. The templates exist for convenience; the value is the guidance and the map. _(Design principles: [VISION.md](VISION.md).)_

## Start here

1. [Quickstart](#quickstart) — fresh host → running agent, in brief.
2. [setup/SETUP.md](setup/SETUP.md) — the full step-by-step (read this one).
3. [setup/workspace-layout.md](setup/workspace-layout.md) — which workspace files do what.
4. [setup/1password-runtime-secrets.md](setup/1password-runtime-secrets.md) — how secrets are handled.
5. [Multi-gateway setups](augments/multi-gateway/) — optional: a second isolated gateway (doctor/breakglass agent, sandbox).
6. [troubleshooting/](troubleshooting/README.md) — `openclaw doctor`, verify-it-works, and common gotchas.
7. [Ecosystem & See-also](#ecosystem--see-also) — where to go for more.

## Quickstart

> TL;DR for the impatient — see [SETUP.md](setup/SETUP.md) for the *why* behind each step.

```bash
# 1. Install Node 22+ and OpenClaw
npm install -g openclaw

# 2. Initialize local config + workspace (or: openclaw onboard — interactive wizard)
openclaw setup

# 3. Drop in this repo's opinionated config and fill your secrets
cp setup/config/openclaw.template.json ~/.openclaw/openclaw.json
$EDITOR ~/.openclaw/openclaw.json      # Telegram bot token, model auth, Brave key

# 4. Sanity-check, then start
openclaw doctor                        # diagnose config / gateway / plugins / channels
openclaw gateway start                 # or: openclaw gateway install  (managed service)

# 5. Verify
openclaw status                        # gateway up? then DM your bot to confirm
```

## Files

- **`setup/`** — the core path: `SETUP.md` (fresh host → running agent), `workspace-layout.md` (what each workspace file does), `1password-runtime-secrets.md` (secret handling: `.env` vs 1Password runtime injection), `tailscale-setup.md` (secure browser relay), and `config/` + `infra/` (below).
- **`setup/config/openclaw.template.json`** — minimal, opinionated OpenClaw config with placeholders for your tokens/keys.
- **`setup/config/openclaw.full-example.json5`** — maximal JSON5 reference showing most documented keys with safe placeholders.
- **`setup/infra/`** — systemd units + 1Password env-render scripts for running the gateway(s) as persistent services.
- **`augments/`** — optional add-ons once the core path works: `multi-gateway/` (a second isolated gateway — the generic `second-gateway` base, a worked **Doctor / breakglass agent**, and a **Sandbox gateway** lockdown pattern), `skills/` (starter skill *guides*, each `.md` walks you through building the skill), `memory/` (local embeddings, qmd deep-dives), `browser-relay.md`, and `airbnb-mcp-setup.md`. For ready-made skills, see [SkillReef](#ecosystem--see-also).
- **`troubleshooting/`** — `openclaw doctor`, verify-it-works checks, and the common-gotchas table.

## Ecosystem & See-also

lobster-boilerplate is a map as much as a kit. For anything beyond the core path, these are the canonical siblings:

- **[SkillReef](https://github.com/clawSean/skillreef)** — the living registry of public-safe OpenClaw skills. Browse for ready-made skills or publish your own. (This repo's `skills/` is a curated starter subset.)
- **[ClawHub](https://clawhub.ai)** — hub for shareable skills & docs; install with `openclaw skills install <slug>` or `openclaw plugins install clawhub:<pkg>`.
- **Bottom Feeder** (clawSean) — depth-first knowledge-crawler skill; it *populates* the `knowledge/` base your `knowledge-search` skill reads.
- **[Crustacean Cognition](https://github.com/clawSean/crustacean-cognition)** — the current advanced memory architecture (4C pipeline). Use this for serious memory work.
- **[openclaw-x-twitter-kit](https://github.com/clawSean/openclaw-x-twitter-kit)** — deeper X/Twitter capabilities than the bundled `search-twitter` guide.
- **[docs.openclaw.ai](https://docs.openclaw.ai)** — canonical upstream reference for config keys, the `openclaw doctor` CLI, channels, and plugins. When in doubt, defer here.

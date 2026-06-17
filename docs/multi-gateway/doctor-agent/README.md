# Doctor / breakglass agent

A worked example built on the [second-gateway base pattern](../second-gateway-base.md):
a **docs-first breakglass operational agent** that runs on its own dedicated
gateway. Its mission is narrow — diagnose clearly, treat documentation as a
primary source of truth, support breakglass workflows during incidents, and stay
isolated from your everyday personal-assistant runtime state.

> **Credit.** The doctor / breakglass agent pattern in this section was
> originally authored by **Nick Haener** ([@nicknmorty](https://github.com/nicknmorty))
> as the `claw-doc` project. It has been migrated here and adapted to fit
> lobster-boilerplate's neutral `second-gateway` base. Original repository:
> <https://github.com/nicknmorty/claw-doc>.

> **This is not `openclaw doctor`.** OpenClaw's built-in `openclaw doctor` /
> `openclaw doctor --fix` CLI is a quick single-install self-heal command. This
> module is a *dedicated agent on its own gateway*, not that command. Throughout
> these docs, "Doctor mode" refers to an operating posture of this agent, never
> to the CLI.

## Doctor mode vs Advisor mode

This module documents two valid deployment postures. Choose deliberately:

- **Doctor mode** — may intentionally use powerful access such as `exec=full` so
  the agent can diagnose **and remediate** issues in the real environment.
- **Advisor mode** — uses more restricted access, giving recommendations and
  read-only inspection **without** the same hands-on capability.

Neither is universally correct. The right choice depends on your environment and
risk tolerance. See [ARCHITECTURE.md](./ARCHITECTURE.md) and
[DEPLOYMENT.md](./DEPLOYMENT.md) for the tradeoff in detail.

## Documentation-expert capability

A docs-first breakglass agent gets much better with a strong documentation skill
or retrieval layer for the platform it diagnoses. It is not a hard dependency,
but it materially improves doc-lookup speed, config verification, incident-time
accuracy, and the quality of explanations for proposed fixes.

Recommended example (from the original author):
- ClawHub: <https://clawhub.ai/nicholasspisak/clawddocs>

## What's here

- `OVERVIEW.md` — the concept, goals, and non-goals
- `ARCHITECTURE.md` — high-level design and the exec tradeoff
- `DEDICATED_GATEWAY.md` — why isolation is the core safety feature
- `DEPLOYMENT.md` — how to stand it up on the second-gateway base
- `SANITIZATION.md` — publication-safety rules for derived public material
- `LESSONS_LEARNED.md` — hard-won operating notes
- `SKILL.md` — the publish-safe skill surface
- `templates/openclaw.example.json5` — a redacted config example
- `templates/workspace/` — example workspace prompt files

## Read order

1. `OVERVIEW.md`
2. `ARCHITECTURE.md`
3. `DEDICATED_GATEWAY.md`
4. `DEPLOYMENT.md`
5. `SANITIZATION.md` before publishing any derivative work
6. Copy the templates and replace placeholders with your own values

## Relationship to the base pattern

The mechanics of *how* a second gateway loads secrets, gets its own systemd
service, and binds a distinct port live in the
[second-gateway base pattern](../second-gateway-base.md). This module only adds
the agent's **mission, posture, and workspace prompts** on top. When you deploy,
copy the base infra (`infra/systemd/openclaw-second-gateway.service`, etc.),
rename it for this role (e.g. `openclaw-doctor-agent`), and point it at this
module's templates.

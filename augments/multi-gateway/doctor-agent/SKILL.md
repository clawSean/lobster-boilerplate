---
name: doctor-agent
description: Public-safe docs-first breakglass OpenClaw agent template for operators who want a dedicated-gateway troubleshooting and documentation agent without publishing live environment state.
metadata:
  {
    "openclaw":
      {
        "emoji": "🩺"
      }
  }
---

# doctor-agent

> Originally authored by Nick Haener ([@nicknmorty](https://github.com/nicknmorty))
> as the `claw-doc` project. Migrated into lobster-boilerplate and adapted onto
> the neutral `second-gateway` base. Original repository:
> <https://github.com/nicknmorty/claw-doc>.

The doctor agent is a public-safe template for a docs-first breakglass OpenClaw
agent deployed behind its own dedicated gateway.

> **Not `openclaw doctor`.** This is a *dedicated agent on its own gateway*, not
> OpenClaw's built-in `openclaw doctor` / `openclaw doctor --fix` CLI. "Doctor
> mode" here is an operating posture of this agent, never the CLI command.

## When to use this

Use this pattern when you want an operator-focused agent that:
- diagnoses issues clearly
- treats documentation as a primary source of truth
- supports breakglass workflows during incidents
- stays isolated from everyday assistant runtime state

## Core idea

A breakglass agent often needs stronger access and a tighter mission than a
normal personal assistant. This template treats gateway isolation as the default
architectural choice so operators can reduce blast radius, keep runtime state
cleaner, and reason more clearly about trust boundaries. The isolation mechanics
come from the [second-gateway base pattern](../second-gateway-base.md).

## Deployment postures

Two valid operating modes are documented in this module:

- **Doctor mode**: may intentionally use stronger access such as `exec=full` for
  real diagnosis and remediation
- **Advisor mode**: uses more restricted access and focuses on guidance rather
  than direct action

The correct posture depends on environment and risk tolerance.

## Recommended capability boost

A docs-first breakglass agent gets much better with a strong documentation skill
or retrieval layer.

Recommended example (from the original author):
- ClawHub: <https://clawhub.ai/nicholasspisak/clawddocs>

This is not a hard dependency, but it materially improves:
- doc lookup speed
- config verification
- incident-time accuracy
- explanation quality for proposed fixes

## What this module includes

- architecture and deployment docs
- dedicated-gateway guidance
- sanitization guidance for public publication
- a redacted OpenClaw config example
- example workspace prompt files
- an intentionally public-safe publication surface built from docs and templates
  rather than live runtime state

## What this module does not include

- live credentials or secrets
- pairing or device identity artifacts
- logs, transcripts, or task databases
- machine-specific runtime state
- copied local git configuration

## Module layout

- `*.md` for overview, architecture, deployment, and sanitization guidance
- `templates/openclaw.example.json5` for a public-safe config example
- `templates/workspace/` for example workspace files

## Read first

Same order as the module `README.md`:

1. `OVERVIEW.md`
2. `ARCHITECTURE.md`
3. `DEDICATED_GATEWAY.md`
4. `DEPLOYMENT.md`
5. `SANITIZATION.md` — before publishing any derivative work
6. `LESSONS_LEARNED.md` — hard-won operating notes
7. Copy the templates and replace placeholders with your own values

## Important publication rule

This module is meant to be **public-safe**. Do not add real secrets, live config
values, internal logs, pairing artifacts, or environment-specific operational
state before publishing.

# Architecture

> Doctor / breakglass agent pattern originally authored by Nick Haener
> ([@nicknmorty](https://github.com/nicknmorty)) as the `claw-doc` project —
> migrated here and adapted onto the lobster-boilerplate `second-gateway` base.

## High-level design

The doctor-agent pattern separates the public reference, the operator workspace,
and the running gateway.

```text
Operator
  |
  v
Telegram or another approved channel
  |
  v
Dedicated OpenClaw gateway (the second-gateway base)
  |
  +--> breakglass agent runtime
  |
  +--> isolated workspace prompts and templates
  |
  +--> dedicated credentials and auth tokens
  |
  +--> task state, logs, and runtime artifacts kept private
```

This module supplies only the agent's **mission, posture, and workspace
prompts**. The mechanics of *how* the second gateway loads secrets, gets its own
systemd service, and binds a distinct port live in the
[second-gateway base pattern](../second-gateway-base.md).

## Design principles

### 1. Dedicated gateway first

The gateway is its own trust boundary.

Do not colocate this breakglass agent with unrelated personal assistants unless
you deliberately accept the wider blast radius.

### 2. Docs-first workspace

The agent should be guided by explicit docs and prompt files instead of tribal
knowledge.

### 3. Sanitized-by-default publication

Public documentation should come from templates and hand-reviewed docs, not from
live runtime exports. See [SANITIZATION.md](./SANITIZATION.md).

### 4. Tight scope

A breakglass agent should have a narrow mission, clear escalation behavior, and
tooling that matches its intended role.

For some operators, that means full operational access. For others, it means an
advisor-only posture with tighter restrictions. The important thing is to choose
deliberately and document the consequences.

## Recommended separation

### Public reference (this module)

Contains:

- documentation
- example config
- prompt scaffolding

Does not contain:

- runtime state
- real secrets
- device metadata
- real logs or transcripts

### Private deployment repo or host state

Contains:

- real `openclaw.json5` / `openclaw.json`
- system/service wiring for the dedicated gateway (the second-gateway base)
- runtime logs
- auth material
- host-specific scripts
- local operational state

## Suggested components

- dedicated gateway service, separate from the main/personal assistant gateway
  (see `setup/infra/systemd/openclaw-second-gateway.service`)
- dedicated bot token: `${TELEGRAM_BOT_TOKEN}`
- dedicated gateway auth token: `${OPENCLAW_GATEWAY_TOKEN}`
- dedicated workspace root such as `/path/to/doctor-agent/workspace`
- optional notification channel IDs such as `-1001234567890`

These are examples only.

## Exec tradeoff

A true breakglass deployment may intentionally allow `exec=full` so the agent can
diagnose and remediate issues in the real environment.

That power is not free. It increases the consequences of bad routing, bad
prompts, or weak operational boundaries.

If you disable or restrict exec access, the doctor agent can still be useful, but
its role changes:

- with `exec=full`, it is a **doctor**
- with restricted exec, it is an **advisor**

Neither mode is universally correct. The right choice depends on your risk
tolerance and whether you want recommendations or hands-on intervention.

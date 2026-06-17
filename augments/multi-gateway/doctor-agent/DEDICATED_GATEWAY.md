# Dedicated Gateway

> Doctor / breakglass agent pattern originally authored by Nick Haener
> ([@nicknmorty](https://github.com/nicknmorty)) as the `claw-doc` project —
> migrated here and adapted onto the lobster-boilerplate `second-gateway` base.

## Why isolation matters

For a breakglass agent, the dedicated gateway is the main safety feature.

This matters even more if the operator chooses an operational posture with
powerful tooling such as `exec=full`.

If the same gateway handles unrelated assistants, experiments, or personal
workflows, then:

- credentials accumulate in one place
- logs and runtime state become harder to reason about
- operational risk increases
- publication mistakes become more likely

## Recommended pattern

Use one gateway per high-trust operational role.

For the doctor agent, that means:

- separate gateway process or service (the second-gateway base)
- separate OpenClaw home/runtime root for that gateway
  (e.g. `~/.openclaw-second-gateway`)
- separate config file
- separate auth token
- separate bot or channel routing where appropriate
- separate workspace directory
- separate runtime storage (e.g. `/run/openclaw-second-gateway/env`)

This is stronger than just using a different prompt set or folder. The goal is a
genuinely separate operational boundary. The base infra in
[second-gateway-base.md](../second-gateway-base.md) gives you exactly this; this
module just points it at the doctor agent's workspace and posture.

## Example separation

```text
/path/to/doctor-agent/
  config/openclaw.json5
  workspace/
    AGENTS.md
    SOUL.md
    IDENTITY.md
    TOOLS.md
    HEARTBEAT.md
  runtime/
  logs/
```

## Minimum isolation checklist

- do not reuse personal gateway auth tokens
- do not point the module at a live runtime directory
- do not share a workspace full of unrelated prompts
- do not publish files copied from `.openclaw/` or other runtime roots
- do not commit local `.git/config` or credential helper output

## Strong recommendation

If you are deciding between convenience and isolation here, choose isolation.

If you want the doctor agent to act as a real doctor in your environment,
isolation is what makes that power tolerable. Without that boundary, you are just
widening blast radius.

If you are not comfortable granting that level of access, run it in a more
restricted advisor mode instead.

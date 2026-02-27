# boilplate

A starter kit for bootstrapping a new OpenClaw + Telegram setup.

The goal of this repo is to capture Sean/JPop's "good default" setup:

- a sane `openclaw.json` template (with **keys/secret values redacted**)
- a recommended filesystem layout for the workspace
- a short checklist of steps to go from fresh VPS → running agent
- an optional helper script for checking **Venice Diem** balance/rate limits

> **Note:** This repo is deliberately light on code and heavy on config + docs. It's meant as a reference + copy/paste starting point, not a framework.

## Files

- `templates/openclaw.template.json` – minimal, opinionated OpenClaw config with placeholders for your tokens/keys.
- `templates/openclaw.full-example.json5` – **maximal** JSON5 reference config showing most documented keys with safe placeholder values.
- `docs/SETUP.md` – step‑by‑step guide for bringing a new box online.
- `skills/diem-balance/diem.py` (in your OpenClaw workspace) – optional helper to query Venice and print your Diem balance + rate-limit headers.

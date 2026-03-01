# TOOLS.md - Environment Notes

Skills define _how_ tools work. This file is for _your_ specifics — environment details, credential locations, and quick-reference notes.

---

## Host Paths

| Path | Purpose |
|------|---------|
| `~/workspace/` | Main workspace |
| `~/projects/` | Code repositories |
| `~/.secrets/` | Legacy secrets (prefer 1Password) |

---

## Secrets Management

All secrets should be fetched at runtime via secure methods:

```bash
# Example: 1Password CLI
op read "op://Vault/Item/field"
```

| Secret | Location |
|--------|----------|
| API Key A | `op://Vault/Service A/api_key` |
| API Key B | `op://Vault/Service B/password` |

**Never hardcode secrets in files.**

---

## External Services

| Service | Notes |
|---------|-------|
| Example API | Rate limit: 100/min |
| Another Service | Requires auth header |

---

## Devices & Cameras

_(Add device names, locations, identifiers as you pair them)_

| Device | Location | ID |
|--------|----------|-----|
| — | — | — |

---

## Voice / TTS

_(Add voice preferences, ElevenLabs voice IDs, etc.)_

---

## Why This File?

Skills are shared. This setup is yours. Keeping them separate means you can update skills without losing local notes, and share skills without leaking infrastructure details.

---

_Last updated: [date]_

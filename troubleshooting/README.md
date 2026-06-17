# Troubleshooting

Once you've followed [setup/SETUP.md](../setup/SETUP.md) and started the gateway, use this guide to confirm everything is actually live — and to fix it when it isn't.

**First move for almost anything:** run `openclaw doctor`. It diagnoses config, Gateway, plugins, and channels, and `openclaw doctor --fix` auto-repairs the common problems (including migrating legacy config shapes).

```bash
openclaw doctor          # diagnose
openclaw doctor --fix    # diagnose + auto-repair
```

---

## Verify it works

Quick checks that the setup is actually live:

```bash
openclaw status        # Gateway running? channels connected? model reachable?
```

- **Telegram:** DM your bot (or @-mention it in a paired group) — you should get a reply.
- **Web search:** ask the agent something that needs a live lookup; confirm it answers without a "no search provider" error.
- **Memory:** ask it to remember something, then in a new turn ask it back.

If `openclaw status` shows the gateway up but a channel or model unhealthy, that line tells you which piece to fix — then re-check.

---

## Common gotchas

| Symptom | Likely cause / fix |
|---------|--------------------|
| Gateway won't start | `gateway.mode` missing → set `gateway.mode: "local"` ([SETUP §7](../setup/SETUP.md#7-start-the-gateway)), or run `openclaw doctor --fix`. |
| Bot silent in a group | Telegram privacy mode — message BotFather `/setprivacy` → Disable, or @-mention the bot. Also confirm the chat id is allow-listed. |
| Bot silent in DMs | DM not paired / your user id not allowed — check the Telegram `dmPolicy` / allow-list. |
| "No search provider" | Brave key not wired — see [SETUP §4](../setup/SETUP.md#4-configure-openclaw-config-template) (`plugins.entries.brave.config.webSearch.apiKey`). |
| Model / auth errors | Model auth profile missing or wrong provider id — `openclaw doctor` will flag it; see [SETUP §4](../setup/SETUP.md#4-configure-openclaw-config-template). |
| Config edits not taking effect | `openclaw gateway restart` after editing the config. |

---

## Tips & tricks

- **Re-run `openclaw doctor` after every change.** Most fixes are a config tweak followed by `openclaw doctor --fix` and `openclaw gateway restart` — let the doctor confirm the green before you move on.
- **Read the unhealthy line, not the whole dump.** `openclaw status` and `openclaw doctor` name the exact piece (channel, model, plugin) that's failing — fix that one, then re-check rather than guessing.
- **Tail the logs while you reproduce.** Run the gateway in the foreground (`openclaw gateway start`) during first-run testing so errors print live; switch to the systemd-managed `run` only once it's stable.
- When in doubt, the upstream reference is [docs.openclaw.ai](https://docs.openclaw.ai).

# OpenClaw Browser Relay (Chrome Extension) Notes

**Last updated:** 2026-02-26


**Goal:** Let OpenClaw control *your existing, already-logged-in* Chrome tabs (instead of an isolated automation profile).

---

## What it does

- Controls your normal Chrome window/tabs via a Chrome extension + CDP bridge.
- You **explicitly attach** a tab via the extension icon.
  - Only **attached** tabs are controllable.

---

## How it works (mental model)

3 moving pieces:

1) **Browser control service** (Gateway or node) — what the OpenClaw `browser` tool talks to.
2) **Local relay server** (CDP bridge) — default: `http://127.0.0.1:18792`.
3) **Chrome MV3 extension** — uses `chrome.debugger` to attach to the active tab and pipes CDP traffic to the relay.

---

## Install / setup (unpacked extension)

1) Install extension files to a stable local path:

```bash
openclaw browser extension install
```

2) Print the installed extension directory (the folder Chrome should load):

```bash
openclaw browser extension path
```

3) In Chrome:

- Open `chrome://extensions`
- Enable **Developer mode**
- Click **Load unpacked** → select the directory from step (2)
- Pin the extension

---

## Using it

- In agent/tool calls: use `browser` with **`profile="chrome"`** (targets the extension relay).
- Attach/detach a tab: click the extension icon on that tab.
  - Badge **ON** = attached
  - Badge **!** = relay not reachable (often: relay/control service not running on the same machine as Chrome)

---

## After OpenClaw updates

- Re-run:

```bash
openclaw browser extension install
```

- Then in `chrome://extensions`, hit **Reload** on the extension.

---

## Remote Gateway note (VPS Gateway, local Chrome)

If the Gateway isn’t running on the same machine as Chrome:

- Run a **node** on the machine that runs Chrome.
- The Gateway proxies browser actions to that node, while the extension+relay stay local.

---

## Security / best practice

- This is effectively “hands on your browser” for any attached tab (click/type/navigate/read content using whatever that tab is logged into).
- Recommended:
  - Use a **dedicated Chrome profile** for relay usage.
  - Keep relay/Gateway/node **tailnet-only** (do not expose relay ports to LAN/public).

---

## Docs

- Local: `/usr/lib/node_modules/openclaw/docs/tools/chrome-extension.md`
- Related: `/usr/lib/node_modules/openclaw/docs/tools/browser.md`

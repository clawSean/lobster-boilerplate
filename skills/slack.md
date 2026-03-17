# Slack (MCP via 1Password)

Slack workspace access via `slack-mcp-server`, with tokens sourced from 1Password at runtime — no credentials on disk.

## Setup

1. **Get Slack tokens** — you need XOXC and XOXD tokens from your Slack workspace. These are user-level tokens (not bot tokens).

2. **Store tokens in 1Password:**
   - Item: `Slack Tokens` (or your preferred name)
   - Fields: `XOXC Token`, `XOXD Token`

3. **Create the skill folder:**
   ```
   skills/slack/
   ├── SKILL.md
   └── bin/
       └── slack-mcp-op    # Launcher script
   ```

4. **Create the launcher script** (`bin/slack-mcp-op`):
   ```bash
   #!/usr/bin/env bash
   export SLACK_MCP_XOXC_TOKEN="$(op read 'op://YourVault/Slack Tokens/XOXC Token')"
   export SLACK_MCP_XOXD_TOKEN="$(op read 'op://YourVault/Slack Tokens/XOXD Token')"
   exec npx -y slack-mcp-server@latest --transport stdio
   ```

5. **Register with mcporter:**
   ```bash
   mcporter list slack
   ```

## Usage

Once connected via MCP, the agent can:
- List channels (public, private, DMs)
- Read and send messages
- Search message history
- React to messages

## Verification

```bash
mcporter call slack.channels_list channel_types="public_channel,private_channel,im"
```

## Security

- Tokens are fetched from 1Password at runtime — never written to config files
- The launcher script exports them as environment variables only for the subprocess lifetime

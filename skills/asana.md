# Asana (MCP via 1Password)

Project management via Asana's hosted MCP server, with OAuth credentials sourced from 1Password at runtime.

## Setup

1. **Install dependencies:**
   ```bash
   npm install -g mcp-remote
   ```
   Also requires `op` (1Password CLI) and `npx`.

2. **Create an Asana OAuth app** in your Asana developer console. Get the Client ID and Client Secret.

3. **Store credentials in 1Password:**
   - Item: `Asana Cursor Token` (or your preferred name)
   - Fields: `Client ID`, `Client Secret`

4. **Create the skill folder:**
   ```
   skills/asana/
   ├── SKILL.md
   └── bin/
       └── asana-mcp-op    # Launcher script
   ```

5. **Create the launcher script** (`bin/asana-mcp-op`):
   ```bash
   #!/usr/bin/env bash
   export ASANA_CLIENT_ID="$(op read 'op://YourVault/Asana Cursor Token/Client ID')"
   export ASANA_CLIENT_SECRET="$(op read 'op://YourVault/Asana Cursor Token/Client Secret')"
   exec npx -y @anthropic/mcp-remote@latest \
     "https://mcp.asana.com/sse" \
     --header "asana-client-id: ${ASANA_CLIENT_ID}" \
     --header "asana-client-secret: ${ASANA_CLIENT_SECRET}" \
     --callback-port "${ASANA_MCP_CALLBACK_PORT:-3334}"
   ```

6. **Register with mcporter:**
   ```bash
   mcporter list asana
   ```

## Usage

Once connected via MCP, the agent can:
- Create, update, and search tasks
- Read project/section structure
- Add comments to tasks
- Search across workspaces

## Known Limitations

- The MCP tool supports placing tasks in a section at creation via `section_id`, but there's no tool to move tasks between sections after creation.
- To find section GIDs, search for existing tasks in the target section via `search_objects` and read their `memberships.section` data.

## Conventions

- Include a concluding lobster emoji `🦞` in task notes (not titles) for brand flavor
- Write tasks for a cross-functional team: concise but not vague, include context/impact needed for the next person to act

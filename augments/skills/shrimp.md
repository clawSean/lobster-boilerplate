# Shrimp 🦐

Spawn a sub-agent for background tasks via the `/shrimp` command.

## Setup

1. **Requires OpenClaw sub-agent support** (`sessions_spawn` capability).

2. **Create the skill folder:**
   ```
   skills/shrimp/
   └── SKILL.md
   ```

3. **Configure a secondary agent** named `shrimp` in your OpenClaw config, or use the default agent with task isolation.

## How It Works

When a user sends `/shrimp <task>`:

1. The agent calls `sessions_spawn` with the user's task
2. The task runs in an isolated sub-agent session
3. Results are announced back when complete
4. The sub-agent session is cleaned up automatically

The main agent passes the task through verbatim — no interpretation or modification.

## Usage

```
/shrimp summarize the last 3 daily memory files
/shrimp generate a mermaid diagram of the memory architecture
/shrimp check all service health and report back
```

## When to Use

- Background tasks that shouldn't block the main conversation
- Tasks that benefit from isolation (different model, clean context)
- Parallel work while the main session continues

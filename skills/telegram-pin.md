# Telegram Pin

Pin messages in Telegram group chats via the Bot API.

## Setup

1. **Store your bot token** in 1Password or as an environment variable.

2. **Create the skill folder:**
   ```
   skills/telegram-pin/
   ├── SKILL.md
   └── scripts/
       └── pin.js    # Node.js script to call pinChatMessage
   ```

3. **Install Node.js** (if not already available).

## Usage

```bash
node skills/telegram-pin/scripts/pin.js <chat_id> <message_id>
```

The script:
1. Reads the bot token from 1Password or environment
2. Calls the Telegram `pinChatMessage` API
3. Returns success or failure

## How the Agent Uses It

1. User replies to a message and says "pin this"
2. Agent extracts `message_id` from the reply context
3. Agent gets `chat_id` from the conversation metadata
4. Agent runs the pin script

## Getting IDs from Telegram Links

From a link like `https://t.me/c/CHAT_ID/MESSAGE_ID`:
- Extract the chat ID (prepend `-100` for supergroups)
- Extract the message ID from the last path segment

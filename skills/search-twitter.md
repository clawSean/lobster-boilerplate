# Twitter / X Search

Search tweets, fetch timelines, and auto-expand tweet URLs via the Twitter/X API.

## Setup

1. **Get Twitter API access** at [developer.x.com](https://developer.x.com/) and generate a Bearer Token.

2. **Store the Bearer Token in 1Password** (never in local files).

3. **Create the skill folder:**
   ```
   skills/search-twitter/
   └── SKILL.md
   ```
   This skill uses direct `curl` calls — no additional scripts required, though you can add helpers.

## Usage

```bash
# Search tweets
curl -s \
  -H "Authorization: Bearer $(op read 'op://YourVault/Twitter API Key/Bearer Token')" \
  "https://api.twitter.com/2/tweets/search/recent?query=openai&max_results=10"

# Fetch a specific tweet by ID
curl -s \
  -H "Authorization: Bearer $(op read 'op://YourVault/Twitter API Key/Bearer Token')" \
  "https://api.twitter.com/2/tweets/1234567890?tweet.fields=text,author_id,created_at,public_metrics&expansions=author_id&user.fields=name,username"
```

## Auto-Fetch Behavior

Configure the agent to automatically fetch and display tweet content when a user pastes an `x.com` or `twitter.com` URL. Extract the tweet ID from the URL path (`/status/<ID>`) and call the API.

## Security

- Fetch the Bearer Token from 1Password at runtime — never store it in files
- Never log or echo the token value
- Log status codes and error messages, not auth headers

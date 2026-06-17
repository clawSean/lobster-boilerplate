# Sanitization

> Doctor / breakglass agent pattern originally authored by Nick Haener
> ([@nicknmorty](https://github.com/nicknmorty)) as the `claw-doc` project —
> migrated here and adapted onto the lobster-boilerplate `second-gateway` base.

## Purpose

This module is meant to be publishable. That only works if sanitization is
treated as a hard requirement, not a cleanup pass you hope to remember later.

## Never publish these

### Credentials and secrets

- bot tokens
- gateway auth tokens
- API keys
- cookies
- SSH keys
- credential helper output
- `.env` files

### Device and pairing artifacts

- pairing files
- bootstrap tokens
- device identity files
- QR payloads
- local node registration material

### Runtime and user data

- session logs
- transcripts
- exported chats
- attachments from live use
- task databases
- queue state
- checkpoints
- cached tool outputs

### Git and local machine leakage

- `.git/config`
- local remotes
- local usernames or email addresses from git config
- shell history fragments
- hostnames tied to private infrastructure
- absolute paths that reveal personal machine layout

## Safe publication rules

1. Start from templates, not from live files
2. Use placeholders such as `${TELEGRAM_BOT_TOKEN}` and `${PRIMARY_CHAT_ID}`
3. Replace real names and IDs with examples unless they are already public
4. Remove timestamps, transcripts, and operational history
5. Keep runtime directories outside the repo
6. Review diffs before every publish action

## Recommended review checklist

- search for `token`, `secret`, `auth`, `key`, `cookie`
- search for numeric chat IDs and internal URLs
- search for copied logs and transcript fragments
- inspect `.gitignore` coverage for runtime paths
- confirm example config points to generic paths only
- verify no device or pairing files are present

## Public-safe examples

Good:

- `${TELEGRAM_BOT_TOKEN}`
- `${OPENCLAW_GATEWAY_TOKEN}`
- `-1001234567890`
- `/path/to/doctor-agent/workspace`

Bad:

- real bot tokens
- real gateway URLs from a private network
- copied log lines from actual incidents
- any file from `.openclaw/` that came from a live deployment

## Bottom line

If a file came from a real running environment, assume it is unsafe to publish
until proven otherwise.

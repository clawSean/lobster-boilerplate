# 1Password Secrets

Runtime credential access via 1Password CLI. All secrets are fetched at runtime using `op read` — nothing stored on disk except the service account token itself.

## Setup

1. **Install 1Password CLI:**
   ```bash
   curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | tee /etc/apt/sources.list.d/1password-cli.list
   apt update && apt install -y 1password-cli
   ```

2. **Create a service account** in your 1Password dashboard and get the token.

3. **Store the token** in `~/.openclaw/.env`:
   ```
   OP_SERVICE_ACCOUNT_TOKEN=ops_your_token_here
   ```
   OpenClaw loads this automatically on gateway startup.

4. **Verify access:**
   ```bash
   op whoami
   op vault list
   ```

## Usage Pattern

```bash
op read "op://VaultName/ItemName/FieldName"
```

In scripts:
```bash
curl -H "Authorization: Bearer $(op read 'op://MyVault/Twitter/Bearer Token')" \
  "https://api.twitter.com/2/..."
```

## Adding New Secrets

1. Add the secret to your 1Password vault
2. Update the table in your local `SKILL.md` with the `op://` path
3. Use `op read` to fetch at runtime — no local files needed

## Security Rules

- Never log, echo, or paste secrets into output
- Never store fetched secrets in files
- Never commit secrets to git
- Always fetch fresh at runtime with `op read`

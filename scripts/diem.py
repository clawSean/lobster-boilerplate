#!/usr/bin/env python3
import json
import sys
import urllib.request
import urllib.error
from pathlib import Path

auth_path = Path('~/.openclaw/agents/main/agent/auth-profiles.json')
if not auth_path.exists():
    print('Could not find auth-profiles.json (expected at ~/.openclaw/agents/main/agent/auth-profiles.json).', file=sys.stderr)
    sys.exit(2)

auth = json.loads(auth_path.read_text())
profile = (auth.get('profiles') or {}).get('venice:default')
if not profile or not profile.get('key'):
    print('No venice:default key found in auth-profiles.json.', file=sys.stderr)
    sys.exit(2)

api_key = profile['key']

url = 'https://api.venice.ai/api/v1/chat/completions'
# Use a canonical Venice model from the docs; any successful inference
# request should return the balance headers.
payload = {
    'model': 'venice-uncensored',
    'messages': [{'role': 'user', 'content': 'ping'}],
    'max_tokens': 1,
}

req = urllib.request.Request(
    url,
    data=json.dumps(payload).encode('utf-8'),
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_key}',
        # Some Venice endpoints are Cloudflare-protected without a UA.
        'User-Agent': 'openclaw-diem-check/1.0',
        'Accept': 'application/json',
    },
    method='POST',
)

status = None
body = None
headers = None

try:
    with urllib.request.urlopen(req, timeout=20) as resp:
        status = resp.status
        headers = resp.headers
        body = resp.read(1024)
except urllib.error.HTTPError as e:
    status = e.code
    headers = e.headers
    try:
        body = e.read(1024)
    except Exception:
        body = None
except Exception as e:
    print(f'Venice request failed: {e}', file=sys.stderr)
    sys.exit(1)

print(f'HTTP status: {status}')
if body:
    try:
        data = json.loads(body.decode('utf-8', 'replace'))
        if isinstance(data, dict) and 'error' in data:
            print(f'Error: {data["error"]}')
    except Exception:
        # Non-JSON body; ignore.
        pass

if not headers:
    sys.exit(0)

# Show all balance + rate-limit related headers we actually get
print('Venice headers (balance / rate limits):')
found_any = False
for k, v in headers.items():
    kl = k.lower()
    if 'venice-balance' in kl or 'x-venice-balance' in kl or 'x-ratelimit' in kl:
        found_any = True
        print(f'- {k}: {v.strip()}')

if not found_any:
    print('- (No x-venice-balance-* or x-ratelimit-* headers were present.)')
    print('  Per the official docs, successful authenticated requests should include')
    print('  x-venice-balance-diem / usd / vcu headers with your remaining balances.')
    print('  If you are seeing HTTP 402 "Insufficient USD or Diem balance", that means')
    print('  your current remaining balance is effectively 0; once you top up, this')
    print('  script should start printing the balance headers again.')

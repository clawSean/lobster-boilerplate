# CoinGecko

Crypto price data and market info via CoinGecko API.

## Setup

1. **No API key required** for free tier (50 calls/min). For higher limits, get a key at [coingecko.com](https://www.coingecko.com/en/api) and add it to 1Password.

2. **Create the skill folder:**
   ```
   skills/coingecko/
   ├── SKILL.md
   └── scripts/
       ├── price.sh    # Quick price lookup
       └── coin.sh     # Detailed coin info
   ```

3. **Scripts use `curl` + `jq`** — ensure both are installed:
   ```bash
   apt install -y curl jq
   ```

## Usage

```bash
# Single coin price
bash skills/coingecko/scripts/price.sh bitcoin

# Multiple coins
bash skills/coingecko/scripts/price.sh bitcoin,ethereum,solana

# Detailed info (market cap, volume, ATH, etc.)
bash skills/coingecko/scripts/coin.sh solana
```

## Common Coin IDs

`bitcoin`, `ethereum`, `solana`, `cardano`, `polkadot`, `avalanche-2`, `chainlink`, `uniswap`

Find any coin ID:
```bash
curl -s "https://api.coingecko.com/api/v3/search?query=your+coin" | jq '.coins[] | {id, name, symbol}'
```

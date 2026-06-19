# CoinMarketCap

Crypto market data, quotes, metadata, and token/platform mapping via CoinMarketCap API.

## Setup

1. **Get a CMC API key** at [coinmarketcap.com/api](https://coinmarketcap.com/api/) and add it to 1Password.

2. **Create the skill folder:**
   ```
   skills/coinmarketcap/
   ├── SKILL.md
   └── scripts/
       ├── quote.sh          # Latest quote by symbol or ID
       ├── info.sh           # Metadata (name, logo, description)
       └── map-platforms.sh  # Platform/contract address mapping
   ```

3. **Scripts fetch the API key from 1Password** at runtime:
   ```bash
   op read "op://YourVault/CoinMarketCap API Key/password"
   ```

## Usage

```bash
# Latest quote
bash skills/coinmarketcap/scripts/quote.sh BTC
bash skills/coinmarketcap/scripts/quote.sh 1027 USD,BTC

# Metadata
bash skills/coinmarketcap/scripts/info.sh ETH

# Platform mapping (useful for contract addresses)
bash skills/coinmarketcap/scripts/map-platforms.sh USDT
```

## Key Endpoints

- `GET /v1/cryptocurrency/quotes/latest` — price, market cap, volume
- `GET /v1/cryptocurrency/map` — CMC IDs and platform mapping
- `GET /v2/cryptocurrency/info` — rich metadata, contract lookups
- `GET /v1/cryptocurrency/listings/latest` — ranked listings

Full docs: [coinmarketcap.com/api/documentation/v1](https://coinmarketcap.com/api/documentation/v1/)

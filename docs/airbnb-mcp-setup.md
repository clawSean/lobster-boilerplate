# Airbnb MCP Server — Setup Guide

**Last updated:** 2026-03-16

**Goal:** Give your OpenClaw agent the ability to search Airbnb listings and pull detailed property info — no browser automation, no credentials, no Airbnb account needed.

---

## How It Works

```
OpenClaw Agent
    │
    ├── mcporter call airbnb.airbnb_search location="Rome" ...
    │
    ▼
mcporter (stdio)
    │
    ▼
@openbnb/mcp-server-airbnb (npx)
    │
    ├── Scrapes Airbnb's public HTML (Cheerio)
    ├── Parses listings, prices, ratings, coordinates
    └── Returns structured JSON
```

- **Transport:** stdio (MCP standard)
- **Auth:** None — scrapes publicly available data
- **Source:** [openbnb-org/mcp-server-airbnb](https://github.com/openbnb-org/mcp-server-airbnb) (MIT license, 400+ stars)
- **Not affiliated with Airbnb, Inc.**

---

## Prerequisites

- Node.js 18+ (for `npx`)
- mcporter installed (`npm install -g openclaw` includes it, or install standalone)

---

## Step 1: Add the MCP server

```bash
mcporter config add airbnb \
  --command "npx" \
  --arg "-y" \
  --arg "@openbnb/mcp-server-airbnb" \
  --arg "--ignore-robots-txt" \
  --scope home \
  --description "Search Airbnb listings (no credentials needed)"
```

This writes the server definition to `~/.mcporter/mcporter.json`.

### What `--ignore-robots-txt` does

Airbnb's `robots.txt` blocks automated scraping. The server **respects robots.txt by default**, which means searches will return empty results. The `--ignore-robots-txt` flag bypasses this.

> ⚠️ This is technically against Airbnb's ToS. The data is publicly available, and this isn't illegal — but worth knowing.

---

## Step 2: Verify installation

```bash
mcporter list airbnb --schema
```

You should see two tools:

| Tool | Description |
|------|-------------|
| `airbnb_search` | Search listings by location, dates, guests, price range |
| `airbnb_listing_details` | Get full details on a specific listing by ID |

---

## Step 3: Test a search

```bash
mcporter call airbnb.airbnb_search location="Rome, Italy" checkin="2026-06-01" checkout="2026-06-05" adults=2
```

Expected response: JSON with `searchUrl`, `searchResults[]` containing listing names, IDs, URLs, ratings, prices, coordinates.

---

## Available Tools

### `airbnb_search`

Search for listings with filters.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `location` | ✅ | City, state, region (e.g., "San Francisco, CA") |
| `placeId` | | Google Maps Place ID (overrides location) |
| `checkin` | | Check-in date (YYYY-MM-DD) |
| `checkout` | | Check-out date (YYYY-MM-DD) |
| `adults` | | Number of adults (default: 1) |
| `children` | | Number of children (default: 0) |
| `infants` | | Number of infants (default: 0) |
| `pets` | | Number of pets (default: 0) |
| `minPrice` | | Minimum price per night |
| `maxPrice` | | Maximum price per night |
| `cursor` | | Base64 pagination cursor for next page |
| `ignoreRobotsText` | | Override robots.txt per-request |

**Returns:** Search URL, array of listings with name, ID, direct Airbnb URL, rating, review count, price breakdown, coordinates, badges.

### `airbnb_listing_details`

Get full details on a specific property.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `id` | ✅ | Airbnb listing ID (from search results) |
| `checkin` | | Check-in date (YYYY-MM-DD) |
| `checkout` | | Check-out date (YYYY-MM-DD) |
| `adults` | | Number of adults (default: 1) |
| `children` | | Number of children (default: 0) |
| `infants` | | Number of infants (default: 0) |
| `pets` | | Number of pets (default: 0) |
| `ignoreRobotsText` | | Override robots.txt per-request |

**Returns:** Amenities, house rules, policies, property highlights, descriptions, location with coordinates, direct listing link.

---

## Example Workflow

```bash
# 1. Search for places in Amalfi Coast
mcporter call airbnb.airbnb_search \
  location="Amalfi Coast, Italy" \
  checkin="2026-07-10" \
  checkout="2026-07-14" \
  adults=2 \
  maxPrice=300

# 2. Get details on a listing that caught your eye
mcporter call airbnb.airbnb_listing_details \
  id="1356530083006279312" \
  checkin="2026-07-10" \
  checkout="2026-07-14" \
  adults=2
```

---

## Configuration Reference

The server entry in `~/.mcporter/mcporter.json` looks like:

```json
{
  "mcpServers": {
    "airbnb": {
      "command": "npx",
      "args": [
        "-y",
        "@openbnb/mcp-server-airbnb",
        "--ignore-robots-txt"
      ],
      "description": "Search Airbnb listings (no credentials needed)"
    }
  }
}
```

### Alternative: Without `--ignore-robots-txt`

If you want to respect robots.txt globally and only override per-request:

```json
{
  "mcpServers": {
    "airbnb": {
      "command": "npx",
      "args": ["-y", "@openbnb/mcp-server-airbnb"]
    }
  }
}
```

Then pass `ignoreRobotsText=true` on individual calls.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Empty results | Make sure `--ignore-robots-txt` is set (Airbnb blocks scrapers by default) |
| `npx` not found | Install Node.js 18+ and ensure `npx` is in PATH |
| Timeout on first call | First run downloads the package via npx — subsequent calls are faster |
| Listings missing prices | Add `checkin` and `checkout` dates — Airbnb only shows pricing with date context |
| Stale data / structure changes | Airbnb can change their HTML anytime; check the [repo issues](https://github.com/openbnb-org/mcp-server-airbnb/issues) for known breakages |

---

## Legal & Ethical Notes

- This tool scrapes **publicly available** Airbnb listing data
- It is **not affiliated with Airbnb, Inc.**
- Using `--ignore-robots-txt` violates Airbnb's ToS (but is not illegal)
- Be mindful of request frequency — don't hammer their servers
- Use for legitimate personal search and booking research

---

## Further Reading

- [GitHub: openbnb-org/mcp-server-airbnb](https://github.com/openbnb-org/mcp-server-airbnb)
- [npm: @openbnb/mcp-server-airbnb](https://www.npmjs.com/package/@openbnb/mcp-server-airbnb)
- [mcporter docs](https://docs.openclaw.ai)

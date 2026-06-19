# Local Embeddings for OpenClaw (Ollama + nomic-embed-text)

A practical guide for running both OpenClaw memory search and a ChromaDB-backed knowledge search locally through Ollama.

## Overview

This setup keeps embeddings local.

| System | What it searches | Backend | Embedding route |
|---|---|---|---|
| `memory_search` | `MEMORY.md`, `memory/*.md`, optional session transcripts | OpenClaw builtin memory store | Ollama via OpenAI-compatible `/v1/embeddings` |
| `knowledge-search` skill | Configurable knowledge directory, recursively | ChromaDB | Ollama native embedding API |

## What this gives you

- No paid cloud embeddings for memory search
- Shared local embedding model: `nomic-embed-text`
- Recursive semantic indexing for all `.md` and `.txt` files under a configurable knowledge folder
- Hybrid memory retrieval, semantic plus keyword

## Prerequisites

- Ollama running locally on `127.0.0.1:11434`
- `nomic-embed-text` pulled in Ollama
- OpenClaw installed and running
- Python 3 available as `python3`

---

# Part 1: Local memory search

## Working config

Place this under `agents.defaults.memorySearch` in `~/.openclaw/openclaw.json`:

```json
"memorySearch": {
  "enabled": true,
  "sources": ["memory", "sessions"],
  "experimental": {
    "sessionMemory": true
  },
  "provider": "openai",
  "model": "nomic-embed-text",
  "remote": {
    "baseUrl": "http://127.0.0.1:11434/v1",
    "apiKey": "ollama",
    "batch": {
      "timeoutMinutes": 20
    }
  },
  "fallback": "none",
  "sync": {
    "watch": true
  },
  "query": {
    "hybrid": {
      "enabled": true,
      "vectorWeight": 0.7,
      "textWeight": 0.3
    }
  },
  "cache": {
    "enabled": true
  }
}
```

## Why this works

- `provider: "openai"` uses OpenClaw's OpenAI-compatible embedding client
- `remote.baseUrl` points that client at local Ollama instead of OpenAI
- `model: "nomic-embed-text"` requests the local Ollama embedding model
- `fallback: "none"` prevents silent cloud fallback
- hybrid query keeps exact-match help from text search alongside vector retrieval

## Apply and verify

After updating config, reload or restart OpenClaw, then run:

```bash
openclaw memory index --force
openclaw memory status --deep
```

You want to see:

- provider requested as `openai`
- model `nomic-embed-text`
- vector store ready
- 768-dimensional vectors
- indexed files and chunks greater than zero

Then test a real query:

```bash
openclaw memory search "test query"
```

Or from the agent side, run a `memory_search` tool call and confirm the response reports:

- `provider: openai`
- `model: nomic-embed-text`

That means OpenClaw is using the local OpenAI-compatible Ollama route.

## Quick health checks

```bash
ollama list
curl -s http://127.0.0.1:11434/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model":"nomic-embed-text","input":"test"}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d['data'][0]['embedding']))"
openclaw memory status --deep
```

Expected embedding size for `nomic-embed-text` is 768.

## Notes

- Switching from cloud embeddings to `nomic-embed-text` requires a reindex
- `sources: ["memory", "sessions"]` adds transcript recall; use only `"memory"` while debugging if you want a quieter corpus
- A native `provider: "ollama"` path may also be possible in newer OpenClaw versions, but the OpenAI-compatible path above is the proven config covered here

---

# Part 2: Knowledge search skill

## What lives where

This mapping is system-specific and reflects the common workspace layout:

- `knowledge/topics/` — concepts, facts, entities, reference notes
- `knowledge/procedures/` — how-tos, workflows, operational steps
- `knowledge/research/` — deeper investigations and findings
- `knowledge/notes/` — lighter-weight or staging knowledge notes
- `memory/` and `MEMORY.md` — personal and episodic memory, not the knowledge base

Use `memory_search` for memory. Use the `knowledge-search` skill for the knowledge corpus.

## Scope and path behavior

The installed skill indexes:

- all `.md` and `.txt` files
- recursively
- under a configurable root directory

Default source root:

```text
~/.openclaw/workspace/knowledge
```

Override it when needed:

```bash
SOURCE_DIR=/path/to/another-knowledge-folder bash ~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh
```

## Current script behavior

- default Chroma collection: `knowledge`
- Chroma path: `~/.openclaw/chroma/knowledge-search`
- model: `nomic-embed-text`
- chunk size: `1500`
- overlap: `200`
- manifest-based skip of unchanged files
- orphan cleanup for deleted files
- friendly query error if the collection does not exist yet

## Commands

### Ingest

```bash
bash ~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh
```

### Query

```bash
bash ~/.openclaw/workspace/skills/knowledge-search/scripts/query.sh "your question here" 5
```

## OpenClaw-compatible recurring ingest guidance

Prefer an OpenClaw cron job over raw system crontab when you want the agent to own maintenance.

Recommended pattern:

- use an isolated recurring `agentTurn`
- run the ingest command
- optionally report only the final summary line
- keep delivery off unless you actually want notifications

Suggested job message:

```text
Run bash ~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh for the knowledge base and report the final summary line.
```

If you truly want host-level scheduling independent of OpenClaw, system crontab is still fine, but the default recommendation is OpenClaw cron.

## Troubleshooting

### Memory search still looks cloud-backed

Check:

```bash
openclaw config get agents.defaults.memorySearch
openclaw memory status --deep
```

If the model is not `nomic-embed-text` or the remote block is missing, the config did not reload.

### Knowledge search misses expected files

Check the active source root and file types:

- only `.md` and `.txt` are indexed
- indexing is recursive under `SOURCE_DIR`
- rerun ingest after adding or renaming files

### Query says the collection does not exist

Run ingest first:

```bash
bash ~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh
```

### Ollama issues

```bash
ollama list
curl http://localhost:11434/
```

If Ollama is down, both local embedding paths will fail.

## References

- https://docs.openclaw.ai/concepts/memory
- https://docs.openclaw.ai/providers/ollama
- https://ollama.com/library/nomic-embed-text
- https://cookbook.chromadb.dev/integrations/ollama/embeddings/

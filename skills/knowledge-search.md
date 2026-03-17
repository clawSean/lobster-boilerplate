# Knowledge Search (ChromaDB)

Semantic search over your `workspace/knowledge/` directory using ChromaDB + Ollama local embeddings. Separate from OpenClaw's built-in memorySearch (which covers `memory/` files via QMD) — this gives you vector search specifically over your knowledge base.

## Prerequisites

- **Ollama** running locally with `nomic-embed-text` model (see the [Local Embeddings Guide](../docs/local-embeddings-guide.md))
- **Python 3.10+** with `chromadb` and `ollama` packages

## Setup

1. **Install Python dependencies:**
   ```bash
   pip3 install --break-system-packages chromadb ollama
   ```

2. **Ensure Ollama is running** with the embedding model:
   ```bash
   curl http://localhost:11434/   # Should print "Ollama is running"
   ollama pull nomic-embed-text   # If not already pulled
   ```

3. **Create the skill folder:**
   ```
   skills/knowledge-search/
   ├── SKILL.md
   ├── data/               # Optional additional articles
   └── scripts/
       ├── ingest.sh        # Shell wrapper (sets env vars, calls ingest_runner.py)
       ├── ingest_runner.py # Python ingestion logic (chunking + embedding)
       └── query.sh         # Semantic search against the index
   ```

4. **Configure the data source** in `ingest.sh`:
   ```bash
   # Default: indexes workspace/knowledge/ (two levels up from scripts/)
   export DATA_DIR="${DATA_DIR:-$WORKSPACE_DIR/knowledge}"
   ```
   Override with `DATA_DIR=/path/to/your/docs` if needed.

## Usage

```bash
# Index all files from knowledge/
bash skills/knowledge-search/scripts/ingest.sh

# Search
bash skills/knowledge-search/scripts/query.sh "how does the Telegram API work"

# More results
bash skills/knowledge-search/scripts/query.sh "crypto privacy tools" 5
```

Re-run `ingest.sh` after adding or updating files. It upserts by content-addressed ID, so it's safe to re-run.

## Configuration

| Variable | Default | Description |
|---|---|---|
| `DATA_DIR` | `workspace/knowledge/` | Directory to index |
| `CHROMA_PERSIST_DIR` | `~/.openclaw/chroma/knowledge-search` | ChromaDB storage location |
| `CHROMA_COLLECTION` | `knowledge` | Collection name |
| `EMBEDDING_MODEL` | `nomic-embed-text` | Ollama model for embeddings |
| `OLLAMA_URL` | `http://localhost:11434` | Ollama server URL |
| `CHUNK_SIZE` | `1500` | Max characters per chunk |
| `CHUNK_OVERLAP` | `200` | Overlap between chunks |

## How It Fits with OpenClaw's memorySearch

| System | What It Indexes | Backend | Purpose |
|---|---|---|---|
| OpenClaw memorySearch | `memory/` files | QMD (built-in) | Episodic recall (relationships, daily logs) |
| knowledge-search (this) | `knowledge/` files | ChromaDB + Ollama | Semantic knowledge lookup (topics, procedures) |

Both use the same Ollama embedding model (`nomic-embed-text`), producing identical vectors. They cover different tiers of the memory architecture without overlap.

## Output Format

```json
[
  {
    "rank": 1,
    "title": "slack",
    "source": "topics/slack.md",
    "distance": 0.3569,
    "excerpt": "# Topic: Slack Integration..."
  }
]
```

Lower distance = more relevant. Results include source file path for traceability.

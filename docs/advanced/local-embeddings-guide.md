# Local Embeddings for OpenClaw (Ollama + nomic-embed-text)

A guide to setting up fully local semantic search for OpenClaw's memory system and (optionally) a ChromaDB-backed knowledge base. No API keys, no external calls -- everything runs on your machine.

## What this does

- Installs **Ollama** as a lightweight local embedding server
- Pulls **nomic-embed-text**, a 274 MB embedding model that runs on CPU
- Configures OpenClaw's built-in **memorySearch** to use it for semantic recall over `MEMORY.md` and `memory/*.md`
- (Optional) Sets up **ChromaDB** for semantic search over your own article/document collection, using the same model

## Prerequisites

- A Linux VPS or server (tested on Ubuntu 24.04, 2 vCPU / 8 GB RAM / no GPU)
- OpenClaw installed and running as a systemd user service
- Python 3.10+ with pip
- Node.js 18+

## Architecture

```
                  +--------------------------+
                  |   Ollama (:11434)        |
                  |   nomic-embed-text       |
                  |   274 MB, 768-dim, CPU   |
                  +-----+----------+---------+
                        |          |
           /v1/embeddings          /api/embed
           (OpenAI-compat)         (native)
                        |          |
          +-------------+    +-----+---------+
          |                  |               |
  +-------v--------+   +----v----+   +------v------+
  | OpenClaw       |   | ChromaDB|   | ChromaDB    |
  | memorySearch   |   | ingest  |   | query       |
  | (built-in)     |   | script  |   | script      |
  +----------------+   +---------+   +-------------+
```

OpenClaw talks to Ollama via the OpenAI-compatible `/v1/embeddings` endpoint.
ChromaDB talks to Ollama via its native Python SDK.
Both use the same model, producing identical vectors.

---

# Part 1: Ollama + OpenClaw memorySearch

This part gives your OpenClaw agent semantic memory recall. Once set up, the agent's `memory_search` tool will find relevant notes by meaning, not just keywords.

## Step 1: Install Ollama

Ollama doesn't need root. Download the binary and extract to `~/.local`:

```bash
# Download (~1.7 GB compressed, includes all runtimes)
curl -fsSL -o /tmp/ollama.tar.zst "https://ollama.com/download/ollama-linux-amd64.tar.zst"

# Extract to ~/.local (creates ~/.local/bin/ollama)
mkdir -p ~/.local
tar --zstd -xf /tmp/ollama.tar.zst -C ~/.local

# Clean up
rm /tmp/ollama.tar.zst

# Verify
~/.local/bin/ollama --version
```

Make sure `~/.local/bin` is in your PATH. Add to `~/.bashrc` if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Step 2: Create a systemd user service for Ollama

This keeps Ollama running in the background and restarts it automatically.

Create `~/.config/systemd/user/ollama.service`:

```ini
[Unit]
Description=Ollama Embedding Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/ollama serve
Restart=on-failure
RestartSec=5
Environment=OLLAMA_HOST=127.0.0.1:11434

[Install]
WantedBy=default.target
```

Enable and start it:

```bash
systemctl --user daemon-reload
systemctl --user enable ollama.service
systemctl --user start ollama.service
```

Verify it's running:

```bash
curl http://localhost:11434/
# Should print: "Ollama is running"
```

## Step 3: Pull the embedding model

```bash
ollama pull nomic-embed-text
```

This downloads ~274 MB. Verify the embedding endpoint works:

```bash
curl -s http://localhost:11434/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model":"nomic-embed-text","input":"hello world"}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'dims: {len(d[\"data\"][0][\"embedding\"])}')"
# Should print: dims: 768
```

## Step 4: Make the OpenClaw gateway start after Ollama

If your gateway runs as a systemd user service, add an override so it waits for Ollama:

```bash
mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d
```

Edit (or create) `~/.config/systemd/user/openclaw-gateway.service.d/override.conf` and add:

```ini
[Unit]
After=ollama.service
Wants=ollama.service
```

If the file already has a `[Service]` section (e.g. for `EnvironmentFile`), just add the `[Unit]` block above it.

Reload systemd:

```bash
systemctl --user daemon-reload
```

## Step 5: Configure memorySearch in openclaw.json

Add the `memorySearch` block inside `agents.defaults` in `~/.openclaw/openclaw.json`:

```json
"memorySearch": {
  "provider": "openai",
  "model": "nomic-embed-text",
  "remote": {
    "baseUrl": "http://127.0.0.1:11434/v1/",
    "apiKey": "ollama"
  },
  "fallback": "none",
  "query": {
    "hybrid": {
      "enabled": true,
      "vectorWeight": 0.7,
      "textWeight": 0.3
    }
  }
}
```

What each field does:

| Field | Purpose |
|-------|---------|
| `provider: "openai"` | Tells OpenClaw to use an OpenAI-compatible API (Ollama exposes one) |
| `model` | Which model to request from the endpoint |
| `remote.baseUrl` | Points to your local Ollama server |
| `remote.apiKey` | Required by the client but ignored by Ollama (any value works) |
| `fallback: "none"` | Don't silently fall back to a paid remote provider |
| `query.hybrid` | Combines vector similarity (70%) with keyword matching (30%) for better recall |

## Step 6: Restart the gateway and verify

```bash
systemctl --user restart openclaw-gateway
```

Wait a few seconds, then check memory status:

```bash
openclaw memory status
```

You should see:

```
Memory Search (main)
Provider: openai (requested: openai)
Model: nomic-embed-text
...
Vector: ready
Vector dims: 768
FTS: ready
```

Trigger the first index by running a search:

```bash
openclaw memory search "test query"
```

The first search takes 10-20 seconds as it indexes all your memory files. After that, check status again -- you should see all files indexed with chunk counts.

## Why nomic-embed-text?

- 274 MB -- fits easily on a low-spec VPS
- Runs fast on CPU, no GPU needed
- 768-dimensional embeddings, 8192-token context window
- Outperforms OpenAI's `text-embedding-3-small` on standard benchmarks
- Free, open-source, no API key needed

## Why not OpenClaw's built-in "local" provider?

OpenClaw has a `provider: "local"` option that loads a GGUF model directly via node-llama-cpp. We avoid it because:

- Requires `pnpm approve-builds` + native module compilation
- Loads the model inside the gateway process (increases memory footprint)
- Only serves OpenClaw -- if you also want ChromaDB, you'd need a second solution
- Fragile with global npm installs

Ollama is a separate process, handles its own model management, and can serve both OpenClaw and ChromaDB with the same model.

## Resource usage

- Ollama base: ~10 MB idle
- nomic-embed-text loaded: ~300-400 MB
- Ollama auto-unloads models after 5 minutes of inactivity (configurable)
- First query after idle: ~1-2s cold start
- Subsequent queries: sub-second

---

# Part 2: ChromaDB Knowledge Base (Optional)

This is independent of memorySearch. It gives you a semantic search tool over your own collection of documents (support articles, docs, notes, etc.) using the same Ollama server and embedding model.

## Step 1: Install Python dependencies

```bash
pip3 install --break-system-packages chromadb ollama
```

On systems without PEP 668 restrictions, drop `--break-system-packages`:

```bash
pip3 install chromadb ollama
```

Verify:

```bash
python3 -c "import chromadb; print('chromadb', chromadb.__version__)"
```

## Step 2: Create the skill directory structure

```bash
mkdir -p ~/.openclaw/workspace/skills/knowledge-search/{scripts,data}
```

Put your articles (markdown or text files) into `data/`. Subdirectories are fine:

```
knowledge-search/
  SKILL.md
  data/
    getting-started.md
    troubleshooting/
      login-issues.md
      payment-errors.md
  scripts/
    ingest.sh           # Shell wrapper (sets env vars, calls ingest_runner.py)
    ingest_runner.py    # Python ingestion logic (chunking + embedding)
    query.sh
```

## Step 3: Create the ingest scripts

The ingest logic lives in a standalone Python file (`ingest_runner.py`) with a thin shell wrapper (`ingest.sh`). We avoid bash heredocs for the Python code because they can hang in some shell environments (e.g. Cursor IDE terminals, some SSH sessions).

Create `~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export DATA_DIR="${SKILL_DIR}/data"
export CHROMA_PERSIST_DIR="${CHROMA_PERSIST_DIR:-$HOME/.openclaw/chroma/knowledge-search}"
export CHROMA_COLLECTION="${CHROMA_COLLECTION:-support-articles}"
export OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
export EMBEDDING_MODEL="${EMBEDDING_MODEL:-nomic-embed-text}"
export CHUNK_SIZE="${CHUNK_SIZE:-1500}"
export CHUNK_OVERLAP="${CHUNK_OVERLAP:-200}"

exec python3 "${SCRIPT_DIR}/ingest_runner.py" \
    "$DATA_DIR" "$CHROMA_PERSIST_DIR" "$CHROMA_COLLECTION" \
    "$OLLAMA_URL" "$EMBEDDING_MODEL" "$CHUNK_SIZE" "$CHUNK_OVERLAP"
```

Create `~/.openclaw/workspace/skills/knowledge-search/scripts/ingest_runner.py`:

```python
#!/usr/bin/env python3
import sys, os, re, hashlib, pathlib

data_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")
persist_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/.openclaw/chroma/knowledge-search")
collection_name = sys.argv[3] if len(sys.argv) > 3 else "support-articles"
ollama_url = sys.argv[4] if len(sys.argv) > 4 else "http://localhost:11434"
model_name = sys.argv[5] if len(sys.argv) > 5 else "nomic-embed-text"
chunk_size = int(sys.argv[6]) if len(sys.argv) > 6 else 1500
chunk_overlap = int(sys.argv[7]) if len(sys.argv) > 7 else 200

import chromadb
from chromadb.utils.embedding_functions import OllamaEmbeddingFunction

ef = OllamaEmbeddingFunction(model_name=model_name, url=ollama_url, timeout=120)
client = chromadb.PersistentClient(path=persist_dir)
collection = client.get_or_create_collection(name=collection_name, embedding_function=ef)

def strip_frontmatter(text):
    if text.startswith("---"):
        end = text.find("---", 3)
        if end != -1:
            return text[end + 3:].strip()
    return text

def extract_title(text):
    if text.startswith("---"):
        end = text.find("---", 3)
        if end != -1:
            fm = text[3:end]
            m = re.search(r"^title:\s*(.+)$", fm, re.MULTILINE)
            if m:
                return m.group(1).strip().strip("'\"")
    return None

# nomic-embed-text has an 8192 token context window.
# URLs, hashes, and non-English text can tokenize at ~1 char/token,
# so we cap at 2000 chars to stay safely within the limit.
MAX_CHUNK_CHARS = 2000

def hard_split(text, limit):
    """Force-split text that exceeds the embedding model context window."""
    pieces = []
    while len(text) > limit:
        cut = text.rfind(" ", 0, limit)
        if cut <= 0:
            cut = limit
        pieces.append(text[:cut].strip())
        text = text[cut:].strip()
    if text:
        pieces.append(text)
    return pieces

def chunk_text(text, size, overlap):
    paragraphs = re.split(r"\n{2,}", text)
    chunks = []
    current = ""
    for para in paragraphs:
        para = para.strip()
        if not para:
            continue
        if len(current) + len(para) + 2 > size and current:
            chunks.append(current.strip())
            if overlap > 0 and len(current) > overlap:
                current = current[-overlap:] + "\n\n" + para
            else:
                current = para
        else:
            current = current + "\n\n" + para if current else para
    if current.strip():
        chunks.append(current.strip())
    if not chunks:
        chunks = [text.strip()]
    final = []
    for c in chunks:
        if len(c) > MAX_CHUNK_CHARS:
            final.extend(hard_split(c, MAX_CHUNK_CHARS))
        else:
            final.append(c)
    return final

data_path = pathlib.Path(data_dir)
files = sorted(
    p for p in data_path.rglob("*")
    if p.is_file() and p.suffix.lower() in (".md", ".txt") and p.name != ".gitkeep"
)

print(f"Found {len(files)} files in {data_dir}", flush=True)

all_ids = []
all_docs = []
all_metas = []

for fpath in files:
    raw = fpath.read_text(errors="replace")
    title = extract_title(raw) or fpath.stem
    body = strip_frontmatter(raw)
    if not body.strip():
        continue
    rel = str(fpath.relative_to(data_path))
    chunks = chunk_text(body, chunk_size, chunk_overlap)
    for i, chunk in enumerate(chunks):
        doc_id = hashlib.sha256(f"{rel}::{i}".encode()).hexdigest()[:16]
        all_ids.append(doc_id)
        all_docs.append(chunk)
        all_metas.append({"source": rel, "title": title, "chunk_index": i})

print(f"Upserting {len(all_ids)} chunks into '{collection_name}'...", flush=True)

batch = 20
failed = 0
for start in range(0, len(all_ids), batch):
    end = start + batch
    try:
        collection.upsert(
            ids=all_ids[start:end],
            documents=all_docs[start:end],
            metadatas=all_metas[start:end],
        )
    except Exception as e:
        for j in range(start, min(end, len(all_ids))):
            try:
                collection.upsert(ids=[all_ids[j]], documents=[all_docs[j]], metadatas=[all_metas[j]])
            except Exception as e2:
                failed += 1
                print(f"  SKIP chunk {j} ({all_metas[j]['source']}:{all_metas[j]['chunk_index']}, {len(all_docs[j])} chars): {e2}", flush=True)
    done = min(end, len(all_ids))
    print(f"  {done}/{len(all_ids)}", flush=True)

if failed:
    print(f"WARNING: {failed} chunks skipped due to embedding errors.", flush=True)
print(f"Done. Collection '{collection_name}' has {collection.count()} chunks.", flush=True)
```

Key design choices in the ingest script:

- **`hard_split` at 2000 chars**: The paragraph-based chunker can produce oversized chunks when a single paragraph (e.g. a long HTML table or URL list) exceeds `CHUNK_SIZE`. `hard_split` force-breaks these at word boundaries to stay within `nomic-embed-text`'s 8192-token context.
- **Batch size of 20 with fallback**: If a batch fails (usually one chunk exceeding the context window), the script retries each chunk individually and logs/skips failures instead of crashing.
- **Standalone Python file**: Avoids bash heredoc issues that cause hangs in some environments.

## Step 4: Create the query script

Create `~/.openclaw/workspace/skills/knowledge-search/scripts/query.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: bash query.sh \"<question>\" [n_results]"
    exit 1
fi

QUERY="$1"
N_RESULTS="${2:-3}"

CHROMA_PERSIST_DIR="${CHROMA_PERSIST_DIR:-$HOME/.openclaw/chroma/knowledge-search}"
CHROMA_COLLECTION="${CHROMA_COLLECTION:-support-articles}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
EMBEDDING_MODEL="${EMBEDDING_MODEL:-nomic-embed-text}"

python3 - "$QUERY" "$N_RESULTS" "$CHROMA_PERSIST_DIR" "$CHROMA_COLLECTION" "$OLLAMA_URL" "$EMBEDDING_MODEL" <<'PYEOF'
import sys, json

query = sys.argv[1]
n_results = int(sys.argv[2])
persist_dir = sys.argv[3]
collection_name = sys.argv[4]
ollama_url = sys.argv[5]
model_name = sys.argv[6]

import chromadb
from chromadb.utils.embedding_functions import OllamaEmbeddingFunction

ef = OllamaEmbeddingFunction(model_name=model_name, url=ollama_url)
client = chromadb.PersistentClient(path=persist_dir)
collection = client.get_collection(name=collection_name, embedding_function=ef)

results = collection.query(query_texts=[query], n_results=n_results, include=["documents", "metadatas", "distances"])

output = []
for i in range(len(results["ids"][0])):
    meta = results["metadatas"][0][i]
    dist = results["distances"][0][i]
    doc = results["documents"][0][i]
    output.append({
        "rank": i + 1,
        "title": meta.get("title", ""),
        "source": meta.get("source", ""),
        "distance": round(dist, 4),
        "excerpt": doc[:500] + ("..." if len(doc) > 500 else ""),
    })

print(json.dumps(output, indent=2))
PYEOF
```

Make them executable:

```bash
chmod +x ~/.openclaw/workspace/skills/knowledge-search/scripts/*.sh
chmod +x ~/.openclaw/workspace/skills/knowledge-search/scripts/*.py
```

## Step 5: Ingest and query

```bash
# Index all articles from data/
bash ~/.openclaw/workspace/skills/knowledge-search/scripts/ingest.sh

# Search
bash ~/.openclaw/workspace/skills/knowledge-search/scripts/query.sh "how do I reset my password"
```

Re-run `ingest.sh` after adding or updating articles. It upserts by content-addressed ID, so it's safe to re-run.

---

# Troubleshooting

**Ollama not responding:**

```bash
systemctl --user status ollama
curl http://localhost:11434/
```

**memorySearch shows 0 indexed files:**

Run `openclaw memory search "anything"` to trigger the first sync. It indexes lazily.

**ChromaDB error "No module named 'ollama'":**

```bash
pip3 install --break-system-packages ollama
```

**Ollama model not found:**

```bash
ollama list                     # see what's pulled
ollama pull nomic-embed-text    # re-pull if needed
```

**Ingest fails with "input length exceeds the context length":**

This means a chunk is too large for `nomic-embed-text`'s 8192-token context window. Articles with long unbroken paragraphs, URL lists, or embedded hashes can tokenize at ~1 char/token, making even a 1500-char chunk exceed the limit. The `hard_split` safety in `ingest_runner.py` handles this automatically. If you still hit it, lower `MAX_CHUNK_CHARS` in the script (default: 2000).

**Ingest hangs with no output (heredoc issue):**

Some shell environments (Cursor IDE terminals, certain SSH configurations) hang on `python3 - <<'PYEOF'` heredoc invocations. The solution is to use a standalone `.py` file instead. The current `ingest.sh` calls `ingest_runner.py` directly to avoid this.

**Gateway doesn't pick up config changes:**

```bash
systemctl --user restart openclaw-gateway
```

---

# Reference

- [OpenClaw Memory docs](https://docs.openclaw.ai/concepts/memory)
- [Ollama embedding models](https://ollama.com/blog/embedding-models)
- [ChromaDB + Ollama cookbook](https://cookbook.chromadb.dev/integrations/ollama/embeddings/)
- [nomic-embed-text on Ollama](https://ollama.com/library/nomic-embed-text)

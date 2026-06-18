# Memory (augments)

Your agent's memory is just **files in the workspace** — `memory/` (episodic), `knowledge/` (semantic), plus the bootstrap `MEMORY.md` index. A brand-new agent works fine with plain files; you do **not** need a database or embeddings to start. This folder holds *optional upgrades* for when the pile grows.

## Start minimal: the 4-cron curation loop

The lightest maintenance that keeps memory useful over time is a small set of scheduled passes — a "4C" loop, each a cron job at its own cadence:

| Pass | Example cadence | What it does |
|------|-----------------|--------------|
| **Collect** | every couple of hours | sweep recent activity into daily notes |
| **Curate** | daily | promote what matters, prune noise, route to the right file |
| **Compile** | weekly | re-summarize and refresh the hot `MEMORY.md` index |
| **Calibrate** | monthly | audit drift, fix structure, sanity-check the loop itself |

Schedule them with OpenClaw cron (`openclaw cron …`, see [docs.openclaw.ai](https://docs.openclaw.ai)) and run the heavier passes (Compile/Calibrate) on a stronger model. That's it — **most setups never need more than this.** *(This is the exact cron shape Sean's box runs.)*

## Optional: faster retrieval as the pile grows

Once you have a lot of notes and plain keyword search isn't enough, add **semantic** retrieval. These are optional upgrades, not part of the core path:

- **[qmd-setup-guide.md](qmd-setup-guide.md)** — local semantic search over your knowledge base (QMD + Ollama embeddings).
- **[local-embeddings-guide.md](local-embeddings-guide.md)** — local embedding-model setup.

## Going deeper: the full pipeline

For the complete, opinionated memory architecture — the full curation pipeline, schemas, and tooling — see the canonical project:

→ **[Crustacean Cognition](https://github.com/clawSean/crustacean-cognition)** (clawSean) — the advanced memory system this minimal loop graduates into.

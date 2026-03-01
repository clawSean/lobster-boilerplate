# CURATION.md

Instructions for the **curation agent** — a cron job that runs every few hours to extract the most valuable tidbits from recent conversations and organize them into long-term storage.

This is separate from the heartbeat's record-taking (see HEARTBEAT.md). The heartbeat captures raw notes into `memory/daily/YYYY-MM-DD.md` files. **This job decides what's worth keeping and where it belongs.**

**Trigger:** Every 5 hours  
**Model:** Haiku (cheap, sufficient for routing)

---

## How This Works

1. Read the latest daily memory files (`memory/daily/`) and recent session transcripts
2. For each interesting item, run through the **Routing Decision Tree**
3. Check existing files before writing — **no duplicates**
4. Promote anything that's outgrown its home (see Entity Promotion)

---

## Is It Worth Curating?

Ask: *"Would I want to remember this in 3 months?"*

If recalling it later would meaningfully improve a conversation or decision, curate it.

**Skip:** routine task completions, transient troubleshooting, vague statements, anything already captured.

**When in doubt:** capture it. Easier to prune later than recover lost context.

---

## Routing Decision Tree

When you encounter something worth keeping, ask these questions **in order**:

### 1. Is it about a specific person?
→ **`memory/by-contact/<channel>-<id>.md`**

Relationship context, preferences, communication style, life updates, running jokes, special dates.

**Also update:** "Current People" table in MEMORY.md if this is a new person.

---

### 2. Is it about a specific group/channel?
→ **`memory/by-channel/<channel>-g-<name>.md`**

Group dynamics, inside jokes, recurring topics, vibe, power dynamics, notable events.

---

### 3. Is it a lesson learned or prescriptive rule?
→ **`knowledge/lessons/<domain>.md`**

Something that teaches "do X, not Y" — mistakes made, gotchas discovered, patterns that work.

**Domains:**
- `security.md` — Credentials, access, safety rules
- `communication.md` — Messaging, relays, group behavior
- `technical.md` — APIs, configs, debugging patterns
- `social.md` — Per-person interaction lessons
- `skills.md` — Tool and skill usage patterns

**Format:**
```markdown
## Lesson Title
**Learned:** [date] (incident reference if applicable)
**Context:** What happened
**Rule:** What to do / not do
```

**Key:** Include provenance (when/why learned) so lessons can be validated during reevaluation.

---

### 4. Is it factual reference info about a named entity?
→ **`knowledge/entities/<Name>.md`**

Companies, places, products, blockchains, restaurants, organizations — specific named things.

**What to capture:**
- What it is, what it does
- Why it matters to us
- Key facts, updates, changes
- Our interactions or experiences with it

**Threshold:** Create a file when the entity has **5+ facts** or has come up **5+ times**. Below that, mention it in a relevant topic file.

---

### 5. Is it factual reference info about a subject area?
→ **`knowledge/topics/<topic>.md`**

Stable, factual information about how things work. Would be useful to anyone, not just us.

**Examples:**
- How an API works, config patterns, technical mechanics
- Protocol explanations, tool comparisons
- Best practices, standard approaches

**Test:** *Would this help a stranger with no relationship context?* → Knowledge.

---

### 6. Is it experiential/temporal topic memory?
→ **`memory/by-topic/<topic>.md`**

Our journey with a subject — opinions, preferences, evolving understanding, "we tried X and it didn't work."

**Examples:**
- "JPop prefers X style of movies"
- "We've been exploring crypto privacy tools"
- "Our San Diego favorites"
- "How my persona has evolved"

**Test:** *Does it matter who experienced this or when?* → Memory.

---

### 7. Is it a raw idea or brainstorm?
→ **`memory/ideas/<slug>.md`** or tag with `[idea]` in daily file

Unvetted concepts, "what if we..." thoughts, things to explore later.

Ideas are inherently temporal — they need regular review to see if they're still relevant.

**Quick capture:** Tag in daily file: `[idea] Auto-generate changelogs from commit messages`

**Fleshed out:** Create `memory/ideas/<slug>.md` when the idea has substance.

---

### 8. Is it hot/current and needs quick access?
→ **MEMORY.md** (appropriate section)

Working memory — things that are actively relevant right now.

**But:** If it exceeds **10 lines** or is clearly reference material, route to the specific file instead and leave a one-liner pointer in MEMORY.md.

---

## Routing Summary Table

| Question | Destination |
|----------|-------------|
| About a person? | `memory/by-contact/` |
| About a group? | `memory/by-channel/` |
| A lesson/rule? | `knowledge/lessons/` |
| Named entity (factual)? | `knowledge/entities/` |
| Subject area (factual)? | `knowledge/topics/` |
| Topic (experiential)? | `memory/by-topic/` |
| Raw idea? | `memory/ideas/` |
| Hot/current? | MEMORY.md |

---

## Conflict Resolution

When information seems to fit multiple places:

- **Fresher wins** — if sources disagree, the more recent entry is correct
- **Specific wins** — by-contact file overrides MEMORY.md for that person
- **Primary home** — put the full content in one place, leave pointers elsewhere
- **When uncertain** — capture it somewhere (easier to move than recover)

---

## Memory vs Knowledge: The Test

Not sure which bucket? Ask:

| Question | Memory | Knowledge |
|----------|--------|-----------|
| Does it matter *when* this happened? | ✓ | |
| Does it matter *who* said/did this? | ✓ | |
| Is it an opinion or preference? | ✓ | |
| Would it go stale in a few months? | ✓ | |
| Would it help a stranger? | | ✓ |
| Is it factual/verifiable? | | ✓ |
| Is it a stable reference? | | ✓ |
| Is it "how X works"? | | ✓ |

---

## Entity Promotion

Keeps MEMORY.md from becoming a monster (~500 line cap).

**Rule:** If any entity in MEMORY.md reaches **5 mentions** or **10 lines**, promote it:

| Type | Destination |
|------|-------------|
| People | `memory/by-contact/` |
| Groups | `memory/by-channel/` |
| Named entities | `knowledge/entities/` |
| Subject areas (factual) | `knowledge/topics/` |
| Subject areas (experiential) | `memory/by-topic/` |
| Lessons | `knowledge/lessons/` |

**Steps:**
1. Create file from relevant template (see `_EXAMPLE-*.md` files)
2. Move content to new file
3. Leave one-liner reference in MEMORY.md
4. Update Memory Structure Map in MEMORY.md

---

## Category-Specific Guidance

### People & Relationships (`memory/by-contact/`)
- Life updates, preferences, routines, pet peeves
- Relationship signals — who they mentioned, connections
- Communication style — emoji use, sarcasm, preferred reply length
- Running jokes, inside references, memes that land
- Mood patterns — stressed, excited, going through something
- Special dates — birthdays, anniversaries, events mentioned

### Groups & Channels (`memory/by-channel/`)
- Group culture and vibe
- Recurring topics or debates
- Power dynamics, roles people play
- Shared references and memes
- Notable events or milestones

### Lessons (`knowledge/lessons/`)
- Always include provenance (when learned, what triggered it)
- Be prescriptive — "do X" not just "X happened"
- Group by domain (security, communication, technical, social, skills)

### Topics (`knowledge/topics/` or `memory/by-topic/`)
- Factual/reference → knowledge/
- Experiential/preferential → memory/
- When mixed, put in primary bucket, cross-reference the other

### Entities (`knowledge/entities/`)
- Focus on what it IS, not our feelings about it
- Note connections to people/projects (for relevance)
- Keep updated as things change

---

## Operational Notes

- **Be concise.** One clear sentence beats three vague ones.
- **Date your additions.** Prefix entries so we can track when things were learned.
- **Preserve voice.** Jokes, quotes, personality — keep the original flavor.
- **No sensitive info.** No medical details, financial specifics, or credentials.
- **Don't over-organize.** If something doesn't fit neatly, put it in the closest section.
- **Check before writing.** Scan the target file for duplicates or near-duplicates.

---

*Last updated: 2026-03-01*

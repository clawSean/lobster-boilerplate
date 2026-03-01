# COMPILE.md

Instructions for the **weekly compile job** — the maintenance pass that prunes stale content, graduates mature items from memory to knowledge, and produces a weekly digest.

**Trigger:** Weekly cron (Sunday, after file-organization)  
**Model:** Haiku or Sonnet  
**Runtime:** Isolated session, ~10-15 min

---

## Purpose

Compile is the **gardener** of the memory system. While curation (every 5h) routes new content to the right places, compile steps back weekly to:

- **Prune** what's no longer relevant
- **Graduate** what's matured into stable knowledge
- **Consolidate** scattered related content
- **Digest** the week into a summary

This keeps the system from growing unbounded and ensures knowledge crystallizes over time.

---

## Phase 1: Weekly Intake

Gather the week's raw material.

### 1.1 List Daily Files
```bash
ls memory/daily/ | grep "$(date -d '7 days ago' +%Y-%m)" 
```
Collect all daily files from the past 7 days, including:
- Standard dailies: `YYYY-MM-DD.md`
- Timestamped sessions: `YYYY-MM-DD-HHMM.md`
- Any special files: `*-weekly-digest.md`, `*-reevaluation.md`

### 1.2 Scan for Patterns
Read through the week's files looking for:
- **Recurring topics** — same subject mentioned 3+ times
- **Evolving understanding** — corrections, updates to earlier beliefs
- **Completed items** — todos/reminders that were resolved
- **Stale references** — things that are no longer relevant

### 1.3 Note High-Signal Items
Flag items that are:
- Worth promoting to long-term storage
- Ready for graduation (memory → knowledge)
- Candidates for MEMORY.md inclusion
- Potential new lessons

---

## Phase 2: MEMORY.md Pruning

Keep working memory fresh and under the ~500 line cap.

### 2.1 Staleness Check
For each entry in MEMORY.md, ask:
- **Last referenced:** When was this last relevant to a conversation?
- **Still accurate:** Has this been superseded by newer information?
- **Still needed:** Would removing this hurt future conversations?

**Prune if:**
- Entry is 30+ days old AND hasn't been referenced
- Information has been superseded by a correction
- Content has been fully promoted to a dedicated file
- It's a one-time event with no ongoing relevance

### 2.2 Inline Entity Check
Review "Inline Entities" section:
- Any entity now exceeding 10 lines? → Promote
- Any entity mentioned 5+ times across files? → Promote
- Any entity no longer relevant? → Archive or remove

### 2.3 Section Balance
Check section sizes:
- Is any section dominating? (>100 lines) → Consider splitting
- Is any section empty or near-empty? → Consider consolidating
- Is the file approaching 500 lines? → Aggressive promotion needed

### 2.4 Cross-Reference Check
Compare MEMORY.md against dedicated files:
- Any duplicated content? → Keep in dedicated file, summarize in MEMORY.md
- Any contradictions? → Fresher source wins, update the stale one
- Any orphaned references? → Update or remove broken links

---

## Phase 3: Graduation (Memory → Knowledge)

Move mature content from episodic memory to semantic knowledge.

### 3.1 Graduation Criteria
An item is ready to graduate when:

| Criterion | Test |
|-----------|------|
| **Factual** | Is it "how X works" rather than "what we did with X"? |
| **Stable** | Has it been unchanged for 2+ weeks? |
| **Substantial** | Does it have 5+ facts or has been referenced 5+ times? |
| **Transferable** | Would it help someone with no relationship context? |

### 3.2 What Graduates Where

| From | To | Example |
|------|-----|---------|
| `memory/by-topic/` experiential content with stable facts | `knowledge/topics/` | "How the Brave API rate limiting works" |
| Technical insights in MEMORY.md | `knowledge/topics/` | OpenClaw config patterns |
| Repeated mistakes/patterns | `knowledge/lessons/` | "Always do X before Y" |
| Entity facts scattered in daily files | `knowledge/entities/` | Company info accumulated over time |

### 3.3 Graduation Process
1. **Identify candidate** in memory
2. **Check destination** doesn't already have it (avoid duplicates)
3. **Extract and rewrite** as factual reference (remove temporal language)
4. **Write to knowledge/** with appropriate structure
5. **Update source** — leave a one-liner pointer or remove entirely
6. **Update MEMORY.md** structure map if new file created

### 3.4 What Stays in Memory
Never graduate:
- Relationship context (stays in `by-contact/`)
- Group dynamics (stays in `by-channel/`)
- Personal preferences and opinions
- Temporal context ("this month we're focused on...")
- Inside jokes and personality bits

---

## Phase 4: Consolidation

Merge scattered related content.

### 4.1 Topic Consolidation
Look for related content spread across:
- Multiple daily files discussing same topic
- MEMORY.md section + dedicated topic file
- Multiple small topic files that should merge

**Action:** Consolidate into single authoritative location.

### 4.2 Entity Consolidation
Look for entity mentions in:
- Daily files (facts learned about a company/place)
- MEMORY.md inline entities
- Topic files that mention the entity

**Action:** If entity has enough substance (5+ facts), create/update `knowledge/entities/<Name>.md`.

### 4.3 Lesson Extraction
Scan for implicit lessons that weren't captured:
- Mistakes mentioned in daily files
- "Turns out..." or "Actually..." corrections
- Patterns that keep recurring

**Action:** Extract and add to appropriate `knowledge/lessons/<domain>.md`.

---

## Phase 5: Weekly Digest

Create a summary of the week.

### 5.1 Create Digest File
```
memory/daily/YYYY-MM-DD-weekly-digest.md
```

### 5.2 Digest Structure
```markdown
# Weekly Digest — [Date Range]

## Highlights
- [Most significant event/conversation]
- [Key decision made]
- [Important thing learned]

## People
- [Person]: [Notable interaction or update]

## Projects  
- [Project]: [Status update, progress, blockers]

## Knowledge Gained
- [Topic]: [What we learned]

## Lessons Learned
- [New lesson extracted this week]

## Open Threads
- [Thing that needs follow-up]
- [Unresolved question]

## Graduated to Knowledge
- [Item] → knowledge/[path]

## Pruned
- [Item removed and why]
```

### 5.3 Digest Guidelines
- Keep it scannable — bullets, not paragraphs
- Focus on delta — what changed, not steady state
- Link to detail — reference files for more context
- Be honest — include failures and mistakes, not just wins

---

## Phase 6: Quick Checks

Fast verification before finishing.

### 6.1 Security Scan
Quick grep for sensitive patterns:
```bash
grep -r "Bearer\|sk-\|password\|secret\|token" memory/daily/*.md
```
If anything found → flag for immediate review.

### 6.2 Structure Integrity
- Do all files referenced in MEMORY.md exist?
- Are there orphaned files not linked from anywhere?
- Is the Memory Structure Map accurate?

### 6.3 Size Check
```bash
wc -l MEMORY.md  # Should be < 500
du -sh memory/   # Monitor growth
du -sh knowledge/
```

---

## Output Summary

At the end of compile, you should have:

1. **Pruned MEMORY.md** — stale entries removed, under line cap
2. **Graduated items** — mature content moved to knowledge/
3. **Consolidated content** — related items merged
4. **Extracted lessons** — implicit learnings made explicit
5. **Weekly digest** — `memory/daily/YYYY-MM-DD-weekly-digest.md`
6. **Updated structure map** — MEMORY.md reflects current state

---

## Timing

| Phase | Expected Duration |
|-------|-------------------|
| Weekly Intake | 2-3 min |
| MEMORY.md Pruning | 2-3 min |
| Graduation | 2-3 min |
| Consolidation | 2-3 min |
| Weekly Digest | 2-3 min |
| Quick Checks | 1-2 min |
| **Total** | **10-15 min** |

---

## Compile vs Reevaluate

| Aspect | Compile (Weekly) | Reevaluate (Monthly) |
|--------|------------------|----------------------|
| **Focus** | Content maintenance | System health |
| **Scope** | This week's changes | Entire system |
| **Actions** | Prune, graduate, consolidate | Audit, review, propose |
| **Output** | Weekly digest | Reevaluation report |
| **Foundation files** | Don't touch | Review and propose updates |
| **Skills** | Don't review | Full skill feedback loop |
| **Meta** | Don't question process | Evaluate if process works |

---

## Edge Cases

### First Compile (Bootstrap)
On first run, there may be a backlog:
- Process all daily files, not just last 7 days
- Focus on biggest graduation opportunities first
- Don't try to perfect everything — iterate

### After Long Gap
If compile hasn't run in 2+ weeks:
- Extend intake to cover the gap
- Prioritize pruning (likely lots of stale content)
- Create combined digest for the period

### Conflict Resolution
If sources disagree:
- **Fresher wins** — more recent information is usually correct
- **Dedicated file wins** — topic/entity file is more authoritative than MEMORY.md mention
- **When uncertain** — keep both with a note, flag for human review

---

*Created: 2026-03-01*

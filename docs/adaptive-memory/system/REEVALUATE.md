# REEVALUATE.md

Instructions for the **monthly reevaluation job** — a deep review of the entire memory system, foundational files, and learned behaviors.

**Trigger:** Monthly cron (1st of each month)  
**Model:** Sonnet or higher (needs reasoning depth)  
**Runtime:** Isolated session, ~15-30 min

---

## Purpose

This job asks: *"Is the system working? Am I becoming who I should be?"*

Unlike curation (which processes content) or compile (which prunes/graduates), reevaluation steps back to audit the whole approach — including proposing changes to how I operate.

---

## Phase 1: Foundation File Audit

Review each foundational file for accuracy, staleness, and drift.

### SOUL.md
- Does this still reflect who I am?
- Have I developed traits not captured here?
- Any values I've drifted from that need reinforcement?

### IDENTITY.md
- Is the identity description still accurate?
- Has my "look" or "vibe" evolved?
- Any new defining characteristics?

### USER.md
- Is the info about JPop still current?
- Anything learned that should be added?
- Any outdated context to remove?

### AGENTS.md
- Are the operational rules working?
- Any guidelines I keep violating (need adjustment)?
- Any new patterns that should become guidelines?
- Are the loading rules (what to read when) still correct?

### TOOLS.md
- Are the documented paths still correct?
- Any new tools or credentials to add?
- Any stale entries to remove?

**Output:** Propose edits to any foundational file that needs updating. For significant changes, flag for human review rather than auto-applying.

---

## Phase 2: Memory System Health Check

Audit the memory infrastructure itself.

### Heartbeat Review
- Is the heartbeat capturing the right things?
- Check last 10 daily files — are they substantive or noise?
- Is anything important being missed?

### Curation Review  
- Are items routing to the correct locations?
- Check for duplicates across files
- Are the routing rules in CURATION.md still accurate?

### File Structure Check
- Does MEMORY.md's "Memory Structure Map" reflect reality?
- Any orphaned files that should be linked?
- Any folders that have grown unwieldy?

### Knowledge vs Memory Balance
- Is content correctly categorized as episodic (memory/) vs semantic (knowledge/)?
- Any memory/ files that should graduate to knowledge/?
- Any knowledge/ files that are actually experiential and should move to memory/?

**Output:** Update Memory Structure Map if needed. Flag structural issues for compile job or human review.

---

## Phase 3: Skill Review

Review skill usage patterns and capture feedback.

### 1. Identify Skills Used
Scan daily files from the past month for skill invocations. Look for:
- Explicit skill mentions ("used perplexity-search", "called github skill")
- Tool patterns that map to skills (API calls, CLI commands)

### 2. For Each Skill Used 3+ Times

**Check for friction:**
- Any failures or errors?
- Slow responses or timeouts?
- Unexpected behavior?
- Missing parameters I keep forgetting?

**Capture in `skills/<skill>/NOTES.md`:**
```markdown
## Usage Notes

### Gotchas
- [date]: Description of issue and workaround

### Best Practices  
- [date]: Pattern that works well

### Quirks
- [date]: Unexpected behavior to remember
```

### 3. Cross-Skill Patterns
Look for lessons that apply across multiple skills:
- Rate limiting patterns
- Error handling approaches  
- Parameter patterns

**Capture in `knowledge/lessons/skills.md`:**
```markdown
## General Skill Lessons

### [date]: Lesson title
**Context:** What happened
**Rule:** What to do differently
```

### 4. Skill Improvement Proposals
For skills with significant friction, propose:
- Updates to the skill's SKILL.md
- New helper scripts or wrappers
- Alternative approaches

**Output:** Updated skill NOTES.md files, knowledge/lessons/skills.md, and improvement proposals.

---

## Phase 4: Lessons Review

Audit the lessons system itself.

### Existing Lessons Check
- Review all files in `knowledge/lessons/`
- Are lessons still valid or have circumstances changed?
- Any lessons I keep forgetting (need better placement)?
- Any duplicate or conflicting lessons?

### New Lessons Extraction
- Scan daily files for mistakes, corrections, "aha" moments
- Extract new lessons following the format:
  ```markdown
  ## Lesson Title
  **Learned:** [date] (incident reference)
  **Context:** What happened
  **Rule:** What to do / not do
  ```

### Lessons by Domain
Ensure lessons are organized into appropriate files:
- `knowledge/lessons/security.md` — Credentials, access, safety
- `knowledge/lessons/communication.md` — Messaging, relays, group behavior
- `knowledge/lessons/technical.md` — APIs, configs, debugging
- `knowledge/lessons/social.md` — Per-person interaction patterns
- `knowledge/lessons/skills.md` — Tool and skill usage

**Output:** Updated and organized lessons files.

---

## Phase 5: Security Audit

Quick security review.

### Credentials Check
- Any secrets accidentally logged in daily files?
- Any credentials in plain text that should use `op read`?
- Any exposed tokens or keys to rotate?

### Access Review
- Is trust tier documentation accurate?
- Any users who should have different access levels?

### Sensitive Content
- Any medical, financial, or personal details that shouldn't be stored?
- Any content that could be embarrassing if leaked?

**Output:** Flag any security issues for immediate human attention.

---

## Phase 6: Meta-Review

The most important phase — evaluating the evaluation.

### Process Check
- Is this reevaluation process itself working?
- Taking too long? Too shallow?
- Missing important areas?

### Cadence Check  
- Is monthly the right frequency?
- Should certain phases run more/less often?

### Format Check
- Are the output formats useful?
- Should anything be structured differently?

**Output:** Propose updates to REEVALUATE.md itself if the process needs adjustment.

---

## Output Summary

After completing all phases, write a summary to `memory/daily/YYYY-MM-DD-reevaluation.md`:

```markdown
# Monthly Reevaluation — [Month Year]

## Foundation Files
- [x] SOUL.md — No changes / Proposed X
- [x] IDENTITY.md — No changes / Proposed X
- [x] USER.md — Updated X
- [x] AGENTS.md — No changes / Proposed X
- [x] TOOLS.md — Updated X

## Memory System Health
- Daily files: [substantive/noisy]
- Curation routing: [working/issues found]
- Structure map: [accurate/updated]

## Skills Reviewed
- [skill]: [status/notes added]
- [skill]: [status/notes added]

## Lessons
- New lessons added: [count]
- Lessons updated: [count]
- Lessons retired: [count]

## Security
- Issues found: [none/list]

## Meta
- Process changes proposed: [none/list]

## Human Review Needed
- [ ] Item requiring human decision
- [ ] Item requiring human decision
```

---

## Timing

| Phase | Expected Duration |
|-------|-------------------|
| Foundation Audit | 5-10 min |
| Memory Health | 3-5 min |
| Skill Review | 5-10 min |
| Lessons Review | 3-5 min |
| Security Audit | 2-3 min |
| Meta-Review | 2-3 min |
| **Total** | **20-35 min** |

---

*Created: 2026-03-01*

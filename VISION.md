# Vision — lobster-boilerplate

**lobster-boilerplate is a setup _assistant_ — not a framework, and not a frozen copy-paste kit.**

It takes a newcomer from a fresh VPS to a running OpenClaw + Telegram agent on one readable path, and its durable value is **judgment + a map**: it explains the *why* behind each good-default config choice (and its failure mode), then routes you to the right sibling project for anything beyond the core. The templates exist for convenience; the point is the guidance and the pointers.

## Tenets

The docs should satisfy all eight:

1. **Explain the _why_, not just the _what_.** Every key, flag, and choice ships with its rationale *and* its failure mode.
2. **One readable fresh-VPS → running-agent path.** The core flow stays single-gateway, linear, beginner-safe. Advanced material never interrupts the happy path.
3. **Be a map, not a monolith.** Prefer linking siblings (living registries/repos) over absorbing them. Only *vendor* content when single-clone friction clearly beats drift — and when you do, track provenance + credit. (The doctor-agent consolidation is the precedent and the exception, not the default.)
4. **Sanitized by default.** Never ship real secrets, identities, host paths, or bot handles. Placeholders everywhere; secret handling is a first-class topic.
5. **Credit upstream visibly.** Migrated or adapted material keeps its author's name.
6. **Don't collide with OpenClaw's own vocabulary.** Distinguish built-in mechanics from project concepts (e.g. the `openclaw doctor` CLI vs a "doctor" *agent*).
7. **Progressive disclosure.** Core → Multi-gateway setups → Advanced deep-dives. Optional stays clearly optional; readers self-select depth.
8. **Stay current and verifiable.** Point to canonical upstream (`docs.openclaw.ai`) rather than freezing facts that rot; flag superseded sections; distinguish verified behavior from operator inference.

## What this repo is / isn't

| It IS | It ISN'T |
|-------|----------|
| A guided setup path + the *why* behind each step | A framework or library |
| An opinionated "good default" config | The only way to configure OpenClaw |
| A map to the ecosystem (SkillReef, ClawHub, …) | A monorepo that absorbs every sibling |
| Sanitized, public-safe examples | A place for real secrets or identities |

See the [README](README.md) for the user-facing intro, and [Ecosystem & See-also](README.md#ecosystem--see-also) for the sibling projects.

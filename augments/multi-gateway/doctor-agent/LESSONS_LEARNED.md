# Lessons Learned

> Doctor / breakglass agent pattern originally authored by nicknmorty
> ([@nicknmorty](https://github.com/nicknmorty)) as the `claw-doc` project —
> migrated here and adapted onto the lobster-boilerplate `second-gateway` base.

## 1. Isolation is cheaper than cleanup

A dedicated gateway feels like extra ceremony until you compare it with the cost
of scrubbing a mixed personal and operational environment for publication.

## 2. Docs beat memory

If the operating model only lives in one person's head, the breakglass path will
be brittle exactly when it matters most.

## 3. Templates should be obviously fake

Public examples should look unmistakably redacted. Clear placeholders are safer
than values that look almost real.

## 4. Runtime data is not documentation

Logs, transcripts, queue state, and task databases may be useful internally, but
they are terrible source material for a public template.

## 5. Narrow scope makes trust easier

A breakglass agent earns trust by being predictable. Limit the mission, define
the boundary, and keep the prompts opinionated.

Powerful access like `exec=full` is easiest to justify when the role is narrow
and clearly operational. If the role is broad or chatty, the same access becomes
much harder to defend.

## 6. Publication should be a deliberate act

Treat publishing like a release process. Review every file, every example value,
and every ignored path before anything goes public.

## 7. Advisor mode is a valid variant

Not every operator wants a doctor that can intervene directly.

A restricted or advisory deployment may be the better fit for some environments.
That version is less capable, but also less risky. The important thing is to
describe the tradeoff honestly instead of pretending both modes are equivalent.

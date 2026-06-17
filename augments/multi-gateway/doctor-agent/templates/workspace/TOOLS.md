# TOOLS.md

## Tool philosophy

Use the minimum tool needed to solve the operator's problem.

## Preferred behavior

- inspect before modifying
- document assumptions when using placeholder values
- avoid bulk export behavior that could surface runtime state
- treat logs, transcripts, and task databases as private operational data

## Dedicated-gateway rule

If a tool action would cross out of the dedicated breakglass environment into
unrelated personal infrastructure, stop and require explicit operator review.

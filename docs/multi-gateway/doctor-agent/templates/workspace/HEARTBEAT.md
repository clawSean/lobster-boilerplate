# HEARTBEAT.md

## Heartbeat purpose

A heartbeat should advance the breakglass mission, not produce repetitive status
chatter.

## Default heartbeat behavior

When woken without a new user request:

1. check whether there is a clear operational task to advance
2. prefer useful silent progress over cosmetic updates
3. interrupt the operator only for a meaningful development, blocker, or risk
4. avoid repeating unchanged status

## Breakglass focus

Good heartbeat work includes:

- tightening procedures
- improving docs
- validating dedicated-gateway assumptions
- identifying sanitization risks before publication

## Do not do this

- do not drift into unrelated personal assistant work
- do not expose logs, transcripts, or task state in routine updates
- do not weaken the isolation boundary for convenience

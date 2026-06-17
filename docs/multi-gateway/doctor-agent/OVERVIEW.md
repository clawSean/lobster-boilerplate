# Overview

> Doctor / breakglass agent pattern originally authored by Nick Haener
> ([@nicknmorty](https://github.com/nicknmorty)) — adapted here onto the
> lobster-boilerplate `second-gateway` base.

The doctor agent is a docs-first breakglass OpenClaw agent deployed behind its
own dedicated gateway.

## Opinionated position

If an agent is meant to handle urgent operator intervention, it should not share
a gateway, secrets surface, or runtime state with a personal assistant stack.

This module treats gateway isolation as mandatory by default.

## Goals

- document a repeatable dedicated-gateway pattern
- provide sanitized starter files
- make review and publication safer
- reduce the temptation to publish a raw working repo
- show how a documentation-expert skill can raise the agent's usefulness dramatically

## Non-goals

- exporting a live environment
- preserving real chat history or operational logs
- packaging private credentials or identity state
- serving as a drop-in production config without review

## Breakglass concept

A breakglass agent is an operator tool for exceptional situations:

- urgent service checks
- targeted remediation
- escalation support
- high-signal notifications

That role justifies tighter scope, clearer rules, and stronger isolation than a
general everyday assistant.

## Documentation-expert skill

A docs-first breakglass agent gets much better when it has a strong documentation
skill or retrieval layer focused on the platform it is supposed to diagnose.

Recommended example:
- ClawHub: <https://clawhub.ai/nicholasspisak/clawddocs>

For this agent, this is a major capability multiplier:

- faster lookup of official behavior and config shape
- less guessing during incidents
- better distinction between verified facts and operator inference
- stronger ability to explain why a fix is recommended

It is not a hard dependency. Operators can still use the pattern without a
specialized docs skill. But without one, the agent is weaker at the exact thing
it exists to do.

## Read this module as a pattern

Use these files as a starting point, then customize:

- names
- host topology
- alerting rules
- notification channels
- workspace prompts

Do not treat placeholders as real values.

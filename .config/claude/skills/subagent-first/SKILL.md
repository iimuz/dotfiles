---
name: subagent-first
description: >-
  Route work through bounded subagents. Use when tasks require codebase investigation,
  code changes, tests, lint, build, or multi-step validation.
---

# Subagent-First

## Overview

Main agent = orchestrator only.
It plans, routes, reviews concise results, and decides next step.
It does not read implementation files, implement, run tests, lint, or build.
It may read planning and design artifacts (plan files, ADR, `docs/`) directly for routing context.

## Non-negotiable rules

1. Do not delegate discovery + implementation + validation in one subagent.
2. One subagent = one phase, one scope, one success signal.

## Phases

Use separate subagents for these phases:

- discovery: find files, root cause, options. No edits.
- implementation: edit only explicitly named files.
- test: add or update focused tests only.
- validation: run requested tests/lint/build only.
- review: inspect final diff and risks. No edits unless asked.

## Dispatch contract

Every subagent prompt must include:

- phase
- goal
- allowed files/dirs
- forbidden files/dirs
- edits allowed: yes/no
- success signal
- return format

## Return format

Subagents return only:

```yaml
status: success | failure | blocked
summary:
files_changed:
log_path:
next_action:
```

Verbose output goes to `docs/tmp/`.

## Routing loop

After each subagent result, main agent must choose exactly one:

- dispatch next bounded subagent
- split scope
- ask user
- stop and report

## Model

- haiku: discovery, validation, simple reads, running basic commands
- sonnet: implementation, root-cause analysis, review

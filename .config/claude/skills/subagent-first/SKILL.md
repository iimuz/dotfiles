---
name: subagent-first
description: >-
  Dispatch contract for subagents. Use when investigating or changing code across
  multiple files, or whenever dispatching a subagent, regardless of which workflow
  asked for it.
---

# Subagent-First

## Overview

Main agent = orchestrator and verifier.
It plans, dispatches, evaluates returns, verifies decisive evidence, and decides the next step.

This skill defines the contract for every subagent dispatch. It does not assign roles.
If another process skill assigns roles to subagents, keep those roles and apply this
contract to each dispatch.

Subagents are either read-only or edit-allowed. Nothing else distinguishes them.

## Delegate or do it yourself

The main agent does it directly when:

- The target files are already known and the work takes a few tool calls.
- The work needs conversation context: idea generation, design discussion, clarifying requirements.
- The input is a planning or design artifact (plans, ADRs, `docs/`).

Delegate when:

- The target files are unknown and need broad exploration.
- The change spans multiple files.
- Independent pieces of work can run in parallel.
- A command would flood the main context with output. Prefer sandbox execution when
  available; otherwise use a read-only subagent.

## Dispatch contract

Every subagent prompt must include:

- goal: one question or one change. For a change, state the purpose: defect fix, spec
  change, or refactoring.
- evidence: required when the goal is a defect fix. One of: a reproducible failure, a
  failing test, a direct code reference (file:line), or a clear mismatch with the spec.
- edits: yes or no.
- allowed files/dirs and forbidden files/dirs.
- success signal: what must be true for the work to count as done.
- return format: paste the template below into the prompt.

One subagent gets one goal and one scope.
An edit-allowed subagent may add and run focused tests for its own change.
A defect fix without evidence cannot be dispatched. Identify the cause with a read-only
subagent first, or ask the user.

## Return format

Subagents do not read this skill. The main agent pastes this template into every
dispatch prompt. A fixed format keeps the returned volume bounded and preserves
counter-evidence that a free-form summary would drop.

```yaml
status: success | failure | blocked
summary: # a few lines
evidence: # file:line plus a short excerpt; only what supports the conclusion
confirmed: # verified facts (required for read-only subagents)
hypotheses: # ideas not yet verified
rejected: # hypotheses ruled out, with the reason
unverified: # checks that could not be run
files_changed: # edit-allowed subagents only
next_action:
```

If another process skill requires extra report items, add them to this template; do not
replace it.
Do not return raw output (grep results, command logs). If it must be kept, write it to the
temporary directory the harness provides and return only the path.

## Verification before completion

Before declaring work done, the main agent confirms:

- Facts and hypotheses are separated.
- Every change is explained by evidence or a stated purpose.
- The decisive evidence (file:line) was read directly.
- The final diff was read directly.
- Required tests and lint passed. Checks that could not run are recorded.
- Nothing changed outside the goal.

## Routing loop

After each subagent return, choose exactly one:

- dispatch the next bounded subagent
- split the scope
- ask the user
- stop and report

## Model

- haiku: locating files, extracting information, running commands and summarizing results
- sonnet: implementation with a clear scope, ordinary investigation, limited review
- opus: ambiguous root-cause analysis, implementation involving design decisions, review
  of high-risk diffs

---
name: subagent-first
description: >-
  Orchestrate work by delegating to sub-agents. Main agent handles only
  planning, judgment, and user communication. Always active for multi-step work.
user-invocable: true
disable-model-invocation: false
---

# Subagent-First

## Overview

Preserve main agent context by delegating all investigation, analysis,
and execution to sub-agents. Main agent acts solely as orchestrator:
planning, judgment, user communication, and state tracking.

## Main Agent Boundaries

- DO: plan, dispatch, judge sub-agent results, communicate with user
- DO NOT: read or edit codebase files directly (only planning/session files)
- Use the `ask_user` tool only when the user alone can answer. If investigation
  could resolve ambiguity, dispatch a sub-agent first.

## Dispatch Rules

- Always provide to each sub-agent:
  - Exact file paths (not contents)
  - Specific scope: what to do AND what NOT to do
  - Expected output format or signal
  - Decision authority: decide-and-act, or report-only
- Dispatch independent sub-agents in parallel; chain dependent tasks sequentially.
- When a skill is available, load it with the `skill` tool and delegate per its instructions.
  Sub-agents may also invoke skills directly.

## Model Selection

- `claude-haiku-4.5`: Trivial tasks: status checks, simple formatting, simple file reads
- `claude-sonnet-4.6`: Default. General implementation, refactoring, analysis, code generation
- `claude-opus-4.7` (fallback: `claude-opus-4.6`): Complex reasoning, design decisions, code review
- `gpt-5.5` (fallback: `gpt-5.4`): Second opinions, alternative perspectives

Keep the same model within a multi-step subtask.

## State Tracking

Track state via `sql` and `report_intent`.

## Failure Handling

1. If a sub-agent fails, refine the prompt once and retry.
2. If it fails again, report the failure and context to the user via the `ask_user` tool.

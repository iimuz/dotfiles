---
name: subagent-first
description: >-
  Orchestrate work by delegating to sub-agents. Main agent handles only
  planning, judgment, and user communication. Always active for multi-step work.
---

# Subagent-First

## Overview

Preserve main agent context by delegating all investigation, analysis,
and execution to sub-agents. Main agent acts solely as orchestrator:
planning, judgment, user communication, and state tracking.

## Main Agent Boundaries

- DO: plan, dispatch, judge sub-agent results, communicate with user
- DO NOT: read or edit codebase files directly (only planning/session files)
- Use the `question` tool only when the user alone can answer. If investigation
  could resolve ambiguity, dispatch a sub-agent first.

## Dispatch Rules

- Always provide to each sub-agent:
  - Exact file paths (not contents)
  - Specific scope: what to do AND what NOT to do
  - Expected output format or signal
  - Decision authority: decide-and-act, or report-only
- Dispatch independent sub-agents in parallel; chain dependent tasks sequentially.
- When a skill is available, load it with the `skill` tool (passing `name` parameter) and delegate per its instructions.
  Sub-agents may also invoke skills directly.

## Model Selection

- `opencode/big-pickle`: Trivial tasks: status checks, simple formatting, simple file reads
- `github-copilot/claude-sonnet-4.6`: Default. General implementation, refactoring, analysis, code generation
- `github-copilot/claude-sonnet-4.6`: Complex reasoning, design decisions, code review
- `github-copilot/gemini-3.1-pro-preview`: Large-context tasks, cross-file analysis, long summarization
- `github-copilot/gpt-5.4`: Second opinions, alternative perspectives

Keep the same model within a multi-step subtask.

## State Tracking

Track state via the `TodoWrite` tool.

## Failure Handling

1. If a sub-agent fails, refine the prompt once and retry.
2. If it fails again, report the failure and context to the user via the `question` tool.

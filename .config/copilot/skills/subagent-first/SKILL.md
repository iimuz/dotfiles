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

Preserve the main agent's context window by delegating all investigation, analysis, execution, and validation
to sub-agents.
The main agent acts strictly as an orchestrator: planning, high-level judgment, user communication, and state tracking.

## Main Agent Boundaries

- DO NOT read or edit codebase files directly.
  All file modifications, tests, and analysis must be done via sub-agents.
- Exception: Small, self-contained inline tasks (under 50 lines of expected output) that are directly needed for the
  next immediate decision may be handled by the main agent. However, `lint`, `test`, and `build` commands must ALWAYS
  be delegated to a sub-agent regardless of size.

## Dispatch Rules

- Minimize Return Context: Sub-agents must write verbose outputs (e.g., test logs, lint results, raw search results) to
  `{session_dir}/` and return ONLY:
  1. Success or failure status
  2. File path to the full log in `{session_dir}/`
  3. A concise summary of items requiring action (e.g., specific test failures)
- Explicit Context: Always provide each sub-agent with:
  - Exact file paths (never let them guess)
  - Specific scope: what to do AND what NOT to do
  - Expected output format or success signal

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.

## Model Selection

When invoking the subagent, select the appropriate model based on the task complexity to optimize cost and speed:

- `claude-haiku-4.5`: Default for trivial tasks. Use for status checks, simple file reads, file searching, or running basic
  commands.
- `claude-sonnet-4.6`: Use for actual code generation, complex refactoring, test implementations, or deep architecture analysis.
- `gpt-5.5`: Second opinions, alternative perspectives

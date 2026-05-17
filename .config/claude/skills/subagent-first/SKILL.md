---
name: subagent-first
description: >-
  Orchestrate work by delegating to sub-agents. Main agent handles only
  planning, judgment, and user communication.
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

## Dispatch & Execution Rules

- Minimize Return Context: Sub-agents must write verbose outputs (e.g., test logs, lint results, raw search results) to
  `docs/tmp/` and return ONLY:
  1. Success or failure status
  2. File path to the full log in `docs/tmp/`
  3. A concise summary of items requiring action (e.g., specific test failures)
- Explicit Context: Always provide each sub-agent with:
  - Exact file paths (never let them guess)
  - Specific scope: what to do AND what NOT to do
  - Expected output format or success signal

## Model Selection

When invoking the subagent, select the appropriate model based on the task complexity to optimize cost and speed:

- `haiku`: Default for trivial tasks. Use for status checks, simple file reads, file searching, or running basic
  commands.
- `sonnet`: Use for actual code generation, complex refactoring, test implementations, or deep architecture analysis.

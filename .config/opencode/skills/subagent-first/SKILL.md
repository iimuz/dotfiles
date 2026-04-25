---
name: subagent-first
description: >-
  Use when delegating tasks to sub-agents or coordinating multi-step workflows.
---

# Subagent-First

## Principles

- Delegate investigation, decomposition, and execution to sub-agents. Use `read`
  and `edit` only for the planning file and session files, never for codebase files.
- Use `ask_user` only when the user alone can answer. If investigation could resolve
  the ambiguity, dispatch a sub-agent first.
- Track state via `sql` and `report_intent`.
- Dispatch independent sub-agents in parallel. Chain dependent tasks sequentially
  using previous results.
- When dispatching a sub-agent, always provide:
  - Exact file paths (not full contents)
  - Specific scope: what to do AND what NOT to do
  - Expected output format or signal
  - Decision authority: whether the sub-agent decides and acts, or only reports facts
  - Both `agent_type` and `model` on every dispatch
- When a skill is available and relevant, load it with `skill()`, then delegate
  execution to sub-agents per the skill's instructions. Sub-agents may also invoke
  skills directly when their task requires it.
- If a sub-agent fails, refine the prompt once and retry. If it fails again, report
  the failure and context to the user via `ask_user`.

## Agent Type

| Subtask Requirement                               | Agent Type            |
| :------------------------------------------------ | :-------------------- |
| Factual lookup needed ONLY for a routing decision | `explore`             |
| Running builds, tests, lints, or installs         | `task`                |
| Multi-step implementation requiring code edits    | `general-purpose`     |
| Reviewing changes without modifying code          | `code-review`         |
| Work matching a domain-specific custom agent      | use that custom agent |

Always prefer the narrowest-scoped agent that can complete the subtask.

`explore` returns raw data without judgment. Use ONLY when one fact is needed to
choose which sub-agent to dispatch next. For analysis, decomposition, or planning,
use `general-purpose`.

## Model

| Model                                                   | Best For                                             |
| :------------------------------------------------------ | :--------------------------------------------------- |
| `claude-opus-4.7` (fallback: `opus-4.6` → `sonnet-4.6`) | Default. Nuanced reasoning, review, complex refactor |
| `claude-sonnet-4.6`                                     | Mechanical ops: git, file writes, template expansion |
| `claude-haiku-4.5`                                      | Trivial ops: single commands, simple file reads      |
| `gpt-5.4`                                               | Alternative perspective, second opinions             |

Prefer consistency: keep the same model within a multi-step subtask.

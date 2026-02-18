---
name: task-coordinator
description: This skill should be used when coordinating complex tasks that require decomposing into independent subtasks and delegating each to specialized subagents. Use for multi-step workflows where parallel delegation and result synthesis are needed.
---

# Task Coordinator

## Overview

To coordinate complex tasks, always start by delegating to a Planner subagent. The Planner decomposes the request and determines execution mode. The main agent holds only the user request, compact coordination metadata (`plan.json` contents), and the final synthesis result — never intermediate analysis or worker outputs.

## Core Directive

Always delegate decomposition to the Planner first. Never implement directly. Never load intermediate worker content into main agent context.

## Process

Execute these four steps in order:

### Step 1: Plan (Planner subagent)

Spawn a Planner subagent with the full user request. Use `references/planner-protocol.md` for the copy-ready prompt template. The Planner:

-   Decomposes the request into subtasks
-   Writes `plan.json` and per-task `T{n}-prompt.md` files under the run directory
-   Determines execution mode: **1 task → inline mode; 2+ tasks → pipeline mode**
-   Returns only a compact receipt: `PLANNER_OK plan_file=<path> task_count=<n> mode=<inline|pipeline>`

Read only the first line of the Planner's response. If the response exceeds 5 lines, the Planner violated the format contract — ignore the body and verify file existence only.

### Step 2: Execute

Read `plan.json` (compact JSON only, see `references/plan-schema.md`). Do NOT read any `T{n}-prompt.md` files.

**Inline mode (task_count = 1):**

-   Spawn the single worker, passing `prompt_file` path as the instruction to read
-   Receive the worker's result inline (inline results are small by design)
-   Skip Step 3; proceed directly to Step 4: Present

**Pipeline mode (task_count ≥ 2):**

-   Spawn all workers in parallel (respecting `depends_on` order for dependent tasks)
-   Each worker reads its own prompt file and writes its output file
-   Read only the first line of each worker receipt: `WORKER_OK T{n}` or `WORKER_FAIL T{n} <one-line reason>`
-   Do NOT read any `T{n}-output.md` files

### Step 3: Synthesize (pipeline mode only)

Spawn a Synthesizer subagent. Pass only the `synthesis_output_file` path and the list of `output_file` paths from `plan.json`. Use `references/synthesizer-protocol.md` for the copy-ready prompt template. The Synthesizer:

-   Reads worker output files
-   Writes the full synthesis to `synthesis_output_file`
-   Returns only a compact receipt: 2–4 sentence summary + `SYNTHESIS_FILE: <absolute_path>`

Read only the Synthesizer's receipt. Do NOT read `synthesis.md` inline unless the user explicitly requests it.

### Step 4: Present

Present the result to the user (inline result for inline mode, or Synthesizer receipt summary for pipeline mode). Update `dashboard.md`.

## plan.json Contract

Read `references/plan-schema.md` for the complete schema and examples.

Required top-level fields: `schema_version`, `run_id`, `goal`, `tasks`, `synthesis_output_file`.
Required per-task fields: `id`, `agent_type`, `prompt_file`, `output_file`, `depends_on`.
Optional per-task fields: `description`, `model`.

Run directory: `~/.copilot/session-state/{sessionId}/files/{run_id}/`
Run ID format: `tc-{YYYYMMDD}-{HHMMSS}` (e.g., `tc-20260218-143304`)

Preflight validation before dispatch: valid JSON, required fields present, task IDs unique, `depends_on` references valid, dependency graph acyclic, prompt files exist.

## Planner Subagent Protocol

Read `references/planner-protocol.md` for the copy-ready prompt template.

The Planner must:

-   Write exactly one `T{n}-prompt.md` per task and one `plan.json` under the run directory
-   Include these sections in every `T{n}-prompt.md`: Objective, Scope, Constraints, Output contract, Acceptance criteria, and the rule "Do NOT spawn subagents."
-   Return ONLY the compact receipt line — no plan content inline
-   Never spawn subagents

## Worker Subagent Protocol

Each worker must:

-   Read its task prompt from `prompt_file`
-   Write its output to `output_file`
-   Return only a status receipt: `WORKER_OK {id}` or `WORKER_FAIL {id} <one-line reason>`
-   Never spawn subagents

## Synthesizer Subagent Protocol

Read `references/synthesizer-protocol.md` for the copy-ready prompt template.

The Synthesizer must:

-   Read all worker output files listed in `plan.json`
-   Write the full synthesis to `synthesis_output_file`
-   Return a compact receipt: 2–4 sentence summary + `SYNTHESIS_FILE: <absolute_path>`
-   Never spawn subagents

## Parallelization

In pipeline mode, spawn all independent workers simultaneously using a single tool call with multiple `task` invocations. Limit simultaneous worker spawns to 5–8; if tasks exceed this limit, batch them in waves respecting `depends_on` order. For tasks with `depends_on`, spawn them after their dependencies complete, passing the dependency's `output_file` path (not content) in the prompt context.

## Agent Selection

When the Planner assigns agent types, match each subtask to the lightest agent that satisfies it:

| Subtask Requirement | Agent type |
| :--- | :--- |
| Answering questions about code, finding files/symbols | explore |
| Running builds, tests, lints, or installs | task |
| Multi-step implementation requiring code edits | general-purpose |
| Reviewing changes without modifying code | code-review |
| Work matching a domain-specific custom agent | (custom agent name) |

### Choosing a Model

<!-- Review this list when the environment's available models change -->
-   **claude-opus-4.6** — nuanced reasoning, code review, complex refactoring
-   **gpt-5.3-codex** — code generation, structured output, tool-heavy workflows
-   **gemini-3-pro-preview** — broad knowledge synthesis, multi-modal tasks

Prefer consistency: keep the same model within a multi-step subtask.

### Skill Integration

To understand a skill's capabilities or inform decomposition decisions, call the `skill` tool to read its description. Never invoke a skill to produce deliverables — delegate to a subagent instead.

When a subtask requires a skill, include explicit skill instructions in the subagent's prompt file. Example:

> "Invoke the `language-pro` skill for idiomatic TypeScript patterns. Ensure all existing tests pass."

**Skill Modification Rule:**
If a subtask involves creating, modifying, or reviewing a skill, always instruct the sub-agent to invoke the `skill-creator` skill.

## No-Peeking Rule

In pipeline mode, the main agent MUST NOT read any `T{n}-prompt.md` or `T{n}-output.md` file. The only files the main agent reads during pipeline orchestration are `plan.json` (Step 2) and optionally `synthesis.md` (Step 4, only if the user explicitly requests the full synthesis).

**Contract violation:** Any read of forbidden prompt or output artifacts triggers `CONTRACT_VIOLATION_NO_PEEKING`. Abort the current run and restart in strict mode.

## Anti-Patterns

-   **DON'T**: Skip the Planner — always delegate decomposition first, even for seemingly simple requests
-   **DON'T**: Read `T{n}-prompt.md` or `T{n}-output.md` files in pipeline mode
-   **DON'T**: Return full synthesis content inline from the Synthesizer
-   **DON'T**: Ask subagents for advice instead of execution
-   **DON'T**: Make sequential calls when parallel is possible
-   **DON'T**: Spawn subagents from within subagents

## Error Handling (Context-Safe)

-   **Planner format violation** (response >5 lines): Ignore the body; verify `plan.json` file existence only. If the file is missing, retry the Planner once.
-   **Planner failure**: Retry once with a refined prompt. If it fails again, report the error receipt only. Do NOT fall back to main-agent decomposition.
-   **plan.json validation failure**: Report the specific validation error (field name, line) without reading the full file body beyond what is needed to identify the error.
-   **Worker failure**: Record `WORKER_FAIL` receipt. Retry that worker once. On second failure, continue with remaining workers and note the failure.
-   **Partial failure**: Always preserve and present successful subtask results; never discard completed work.
-   **Synthesizer failure**: Retry once. On second failure, report the `synthesis_output_file` path and the list of completed `output_file` paths. Do NOT load any output file inline.

## Output Management

### Coordinator Responsibilities (dashboard.md Only)

-   Single file (`~/.copilot/session-state/{sessionId}/files/dashboard.md`) tracking overall task status.
-   Update at task completion (not during delegation).
-   Check if exists → update; otherwise create.
-   Structure: Pending / Questions / Completed.
-   Include: agent used, task performed, outcome, timestamp.

### File Locations and Retention

Run directory: `~/.copilot/session-state/{sessionId}/files/{run_id}/`

Files written per run:

-   `plan.json` — task manifest (main agent reads this)
-   `T{n}-prompt.md` — worker prompts (main agent does NOT read these)
-   `T{n}-output.md` — worker outputs (main agent does NOT read these)
-   `synthesis.md` — full synthesized result (main agent reads only on explicit user request)

Retention: keep the last 5 run directories per session. After successful synthesis in pipeline mode, the main agent prunes run directories older than the 5 most recent. Pruning failures are non-fatal. Never enumerate or read retained files unless explicitly requested by the user.

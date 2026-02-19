---
name: task-coordinator
description: >
  Coordinate complex tasks by decomposing them into subtasks and delegating each
  to specialized subagents in parallel. Use for multi-step workflows requiring
  parallel execution and result synthesis.
---

# Task Coordinator

## Overview

Delegate all decomposition to the Planner subagent first; never implement directly.
The coordinator holds only `plan.json` and the final receipt—never worker prompts
or outputs. Protocol templates and the plan schema live in `@references/`.

## Interface

```typescript
/**
 * @skill task-coordinator
 * @input  { request: string }
 * @output { result: InlineResult | SynthesisReceipt }
 */

type Plan = {
  schema_version: string;
  run_id:         string;          // format: tc-{YYYYMMDD}-{HHMMSS}
  goal:           string;
  tasks:          Task[];
  synthesis_output_file: string;
  // run_dir = ~/.copilot/session-state/{sessionId}/files/{run_id}/ — see @references/plan-schema.md
};

type Task = {
  id:           string;
  agent_type:   AgentType;
  prompt_file:  string;
  output_file:  string;
  depends_on:   string[];
  description?: string;
  model?:       string;
};

type AgentType        = "explore" | "task" | "general-purpose" | "code-review";
type WorkerReceipt    = { status: "WORKER_OK" | "WORKER_FAIL"; id: string; reason?: string };
type InlineResult     = WorkerReceipt;
type SynthesisReceipt = { status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL"; output_file: string; summary: string; /* 2-4 sentences */ reason?: string };

/**
 * @invariants
 * 1. Zero_Verbosity:      imperative step-list instructions => remove entirely
 * 2. Signature_Integrity: every op => typed (input: T) -> U
 * 3. Minimal_Token:       prose descriptions => symbolic/typespec notation
 * 4. Planner_First:       (direct_implementation_attempt) => abort("Delegate to Planner first")
 * 5. No_Peeking:          (reads T{n}-prompt.md | T{n}-output.md in pipeline_mode) => CONTRACT_VIOLATION_NO_PEEKING
 * 6. No_Recursion:        (subagent_spawns_subagent) => abort("Subagents must not spawn subagents")
 * 7. Execution_Only:      (subagent_prompt_is_advisory_not_actionable) => convert_to_execution_directive
 */
```

## Operations

```typespec
op plan(request: string) -> Plan {
  // Generate run_id (tc-{YYYYMMDD}-{HHMMSS}); spawn Planner via @references/planner-protocol.md
  invariant: (planner_response_lines > 5)  => ignore_body("verify plan.json on disk");
  invariant: (plan_json_missing)           => retry_once("refined prompt");
  invariant: (plan_json_missing_on_retry)  => abort("Planner failed; report error receipt only");
}

op validate_plan(p: Plan) -> Plan {
  // Validate per @references/plan-schema.md: JSON, required fields, IDs, acyclicity, paths
  invariant: (json_parse_error)       => abort("plan.json: parse failure");
  invariant: (missing_required_field) => abort("plan.json: missing field");
  invariant: (duplicate_task_id)      => abort("plan.json: duplicate task ID");
  invariant: (circular_dependency)    => abort("plan.json: dependency cycle");
  invariant: (path_escapes_run_dir)   => abort("plan.json: path traversal rejected");
  invariant: (prompt_file_absent)     => abort("plan.json: prompt file not found");
  invariant: (tasks_length > 15)      => abort("plan.json: exceeds 15-task limit");
}

op execute_inline(p: Plan) -> InlineResult {
  // Exactly 1 task: spawn worker passing prompt_file path; receive result inline; skip synthesize
  invariant: (worker_fails)       => retry_once(p.tasks[0].id);
  invariant: (worker_fails_again) => abort("Worker failed after retry");
}

op execute_pipeline(p: Plan) -> WorkerReceipt[] {
  // 2+ tasks: spawn independent workers in parallel (cap 5-8); batch waves per depends_on
  invariant: (reads_T_n_prompt or reads_T_n_output) => CONTRACT_VIOLATION_NO_PEEKING("abort; restart strict mode");
  invariant: (worker_fails(receipt))         => retry_once(receipt.id);
  invariant: (worker_fails_again(receipt))   => record(WORKER_FAIL, receipt.id, "continue; preserve completed results");
  invariant: (tasks_length > 8)     => batch_in_waves("respecting depends_on order");
}

op synthesize(p: Plan, receipts: WorkerReceipt[]) -> SynthesisReceipt {
  // Pipeline mode only; spawn Synthesizer via @references/synthesizer-protocol.md
  invariant: (synthesizer_fails)       => retry_once("refined prompt");
  invariant: (synthesizer_fails_again) => report_paths("synthesis_output_file + output_files; do not load inline");
  invariant: (reads_synthesis_file and !explicit_user_request) => warn("synthesis.md: load only on explicit request");
}

op present(result: InlineResult | SynthesisReceipt) -> void {
  // Show inline result or receipt summary to user; write dashboard.md
  invariant: (dashboard_missing)  => create(dashboard_path, "Pending/Questions/Completed structure");
  invariant: (dashboard_exists)   => update(dashboard_path);
  invariant: (run_dirs_count > 5) => prune_oldest("after successful synthesis; retain last 5 runs");
  invariant: (enumerates_retained_run_files and !explicit_user_request) => abort("Do not enumerate retained run files without user request");
}
```

## Execution

```
plan -> validate_plan -> [execute_inline | execute_pipeline] -> synthesize? -> present
```

Symbol legend: `|` = XOR branch (gated by `plan.tasks.length`); `?` = pipeline mode only.

## Agent Selection

Match subtasks to the lightest capable agent:

| Requirement | Agent type |
| :--- | :--- |
| Code investigation, symbol/file search | `explore` |
| Build, test, lint, install | `task` |
| Multi-step implementation, code edits | `general-purpose` |
| Review without modifying code | `code-review` |
| Domain-specific work | `<custom-agent-name>` |

Model guidance: `claude-opus-4.6` — nuanced reasoning; `gpt-5.3-codex` — structured output, tool-heavy workflows; `gemini-3-pro-preview` — broad knowledge synthesis. Prefer the same model within a multi-step subtask.
<!-- Review this list when the environment's available models change -->

## Skill Integration

Use the `skill` tool to read a skill's description before decomposition decisions. Never invoke a skill to produce deliverables—delegate to a subagent instead. Embed explicit skill instructions in the worker's prompt file. If a subtask creates, modifies, or reviews a skill, instruct the subagent to invoke `skill-creator`.

## References

- `@references/planner-protocol.md` — Planner prompt template (copy-ready)
- `@references/plan-schema.md` — `plan.json` schema, validation rules, examples
- `@references/synthesizer-protocol.md` — Synthesizer prompt template (copy-ready)

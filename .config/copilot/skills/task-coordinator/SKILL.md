---
name: task-coordinator
description: >
  Coordinate complex tasks by decomposing them into subtasks and delegating each
  to specialized subagents in parallel. Use for multi-step workflows requiring
  parallel execution and result synthesis.
user-invocable: true
disable-model-invocation: false
---

# Task Coordinator

## Overview

Coordinate planning, execution, synthesis, and presentation by delegating each phase
to a dedicated sub-skill. Keep orchestration state minimal and route all actionable
work through stage actions.

All stage artifacts use `{session_dir}` which resolves to
`~/.copilot/session-state/{session_id}/files/` for the current session.
The orchestrator auto-generates internal context values for each run: `run_id` uses
format `tc-{timestamp}` (for example `tc-20260308143022`), `run_dir` resolves to
`{session_dir}/{run_id}/`.

## Schema

```typescript
type CoordinatorResult = {
  status: "ok" | "failed";
  mode: "inline" | "pipeline";
  result_file: string;
  summary: string;
};
```

## Constraints

- Delegate all actionable work through sub-skills and do not execute those tasks directly in the orchestrator.
- Abort immediately without fallback when the request is invalid.
- Abort execution when Stage 1 plan output is missing or invalid.
- Abort execution when Stage 2 task execution fails.
- Fall back to `task-coordinator-present` with `mode` and `result_file` and continue when Stage 3 synthesis fails.
- Abort execution when Stage 4 presentation fails.

## Input

- request: user request text

## Output

- status: orchestration completion status
- mode: inline for single task, pipeline for multi-task plan
- result_file: final artifact to present
- summary: short operator-facing summary

## Execution

```python
run_id = "tc-{timestamp}"  # e.g. tc-20260308143022
run_dir = f"{session_dir}/{run_id}/"

plan = stage1_plan(request, run_dir)
if len(plan["tasks"]) == 1:
    exec_result = stage2_execute_inline(plan)
    final_result = stage4_present(
        mode="inline",
        result_file=exec_result["inline_result_file"],
    )
else:
    receipts = stage2_execute_pipeline(plan)
    synthesis = stage3_synthesize(
        plan,
        receipts,
        protocol_file="references/synthesizer-protocol.md",
    )
    final_result = stage4_present(
        mode="pipeline",
        result_file=synthesis["synthesis_file"],
    )
return final_result
```

### Stage 1: Plan

- Purpose: Produce a validated execution plan from the request.
- Inputs: `request: string`, `run_id: string`, `run_dir: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: "Use the skill tool to invoke 'task-coordinator-plan' with input: { request: '{request}', run_id: '{run_id}', run_dir: '{run_dir}' }. The values `run_id` and `run_dir` are internal orchestrator-generated context values, not user input. Persist all outputs as specified by the skill's Session Files."
  ```

- Outputs: `plan_file: string`
- Guards: `plan.json` exists and has at least one task.
- Faults:
  - If `plan.json` is missing or invalid, use no fallback and abort execution.

### Stage 2: Execute

- Purpose: Run planned tasks using inline or pipeline dispatch.
- Inputs: `plan: object`
- Actions:

  ```yaml
  # Inline mode (plan.tasks length == 1):
  - tool: task
    agent_type: "{plan.tasks[0].agent_type}"
    model: "{plan.tasks[0].model}"
    prompt: "Read {plan.tasks[0].prompt_file}. Write your complete output to {plan.tasks[0].output_file}."
  # Pipeline mode (plan.tasks length > 1) - spawn one task per dependency wave:
  # Waves are determined by depends_on ordering; tasks with no pending dependencies run in parallel within the same wave.
  - tool: task
    agent_type: "{task.agent_type}"
    model: "{task.model}"
    prompt: "Read {task.prompt_file}. Write your complete output to {task.output_file}."
  ```

- Outputs: `inline_result_file: string`, `worker_receipts_file: string`
- Guards: every produced receipt has `status`; inline result exists for single-task runs.
- Faults:
  - If task execution fails, use no fallback and abort execution.

### Stage 3: Synthesize

- Purpose: Merge pipeline worker outputs into one synthesis artifact.
- Inputs: `plan: object`, `worker_receipts: array`, `protocol_file: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: "Use the skill tool to invoke 'task-coordinator-synthesize' with input: { plan: '{plan}', receipts: '{worker_receipts}', protocol_file: '{protocol_file}' }. Persist all outputs as specified by the skill's Session Files."
  ```

- Outputs: `synthesis_file: string`, `synthesis_receipt_file: string`
- Guards: run only when pipeline mode is active.
- Faults:
  - If synthesis fails, invoke `task-coordinator-present` with `mode` and `result_file` set to an
    empty string, then continue execution; the present sub-skill emits a degraded receipt when
    `result_file` is unreadable.

### Stage 4: Present

- Purpose: Present the synthesized or inline result to the user.
- Inputs: `mode: string`, `result_file: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: "Use the skill tool to invoke 'task-coordinator-present' with input: { mode: '{mode}', result_file: '{result_file}' }. Persist all outputs as specified by the skill's Session Files."
  ```

- Outputs: `result_file: string`, `presentation_receipt_file: string`
- Guards: `result_file` is provided by Stage 2 inline output or Stage 3 synthesis output.
- Faults:
  - If presentation fails, use no fallback and abort execution.

## Session Files

| File                                                                             | Written by | Read by          |
| -------------------------------------------------------------------------------- | ---------- | ---------------- |
| `~/.copilot/session-state/{session_id}/files/{run_id}/plan.json`                 | Stage 1    | Stage 2, Stage 3 |
| `~/.copilot/session-state/{session_id}/files/{run_id}/worker-receipts.json`      | Stage 2    | Stage 3          |
| `~/.copilot/session-state/{session_id}/files/{run_id}/synthesis.md`              | Stage 3    | Stage 4          |
| `~/.copilot/session-state/{session_id}/files/{run_id}/synthesis-receipt.json`    | Stage 3    | task-coordinator |
| `~/.copilot/session-state/{session_id}/files/{run_id}/presentation-receipt.json` | Stage 4    | task-coordinator |
| `~/.copilot/session-state/{session_id}/files/{run_id}/plan-errors.json`          | Stage 1    | task-coordinator |

## Examples

### Happy Path

- Request yields three independent tasks.
- Stage 2 runs pipeline dispatch, Stage 3 creates `synthesis.md`.
- Stage 4 presents `synthesis.md` and returns success.

### Failure Path

- Stage 1 returns malformed plan.
- fault(invalid_request) => fallback: none; abort

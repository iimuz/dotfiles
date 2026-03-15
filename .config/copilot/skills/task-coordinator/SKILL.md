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

Coordinate complex work by planning tasks first, then choosing inline execution
for exactly one task or pipeline execution for two or more tasks. Keep
orchestration logic in prose, delegate all actionable work, abort on invalid
planning or execution failures, and synthesize only when pipeline mode produces
multiple worker results.

- `run_dir`: `{session_dir}/{timestamp}-task-coordinator/`
- `final_output`: `{session_dir}/{timestamp}-task-coordinator-synthesis.md`

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`, and
`{timestamp}` is generated once at execution start in `YYYYMMDDHHMMSS` format.
Inline mode runs the single planned task and passes its output directly to
presentation. Pipeline mode groups planned tasks into dependency waves, runs
ready tasks in the same wave in parallel, then synthesizes the combined results
before presentation. Abort on invalid planning or execution failures. If
synthesis fails in pipeline mode, continue to presentation with degraded
pipeline context. If presentation fails, abort.

## Input

- `request: string`

## Execution Flow

### Stage 1: Plan

Turn the request into a validated execution plan that names tasks,
dependencies, prompts, output paths, and dispatch metadata. This stage decides
whether the workflow runs in inline mode or pipeline mode by counting the
planned tasks, and the workflow must stop immediately if the plan artifact is
missing, malformed, or empty.

task(general-purpose, model=claude-opus-4.6):

> Use the skill tool to invoke `task-coordinator-plan` with `request: {request}`
> and `run_dir: {run_dir}`. Treat `run_dir` as orchestrator-provided context,
> not user input. Persist the planning artifacts required for downstream
> execution.

- Output: `{run_dir}/plan.json`
- Fault: Abort if `{run_dir}/plan.json` is missing, invalid, or defines zero
  tasks.

### Stage 2: Execute

Execute the plan without rewriting it. In inline mode, run the one planned task
and use its output directly as the result for Stage 4. In pipeline mode,
resolve dependency waves from the plan, run every ready task in the same wave
in parallel, wait for the wave to complete, then continue until all planned
tasks have produced receipts or outputs. Use `{task.model}` from the plan for
all dispatched tasks instead of hardcoding a model in this stage.

task({task.agent_type}, model={task.model}):

> Read `{task.prompt_file}` and execute exactly the work assigned to that task.
> Write the complete task result to `{task.output_file}` and any execution
> receipt to the plan-defined receipt path.

- Output: `{run_dir}/inline-result.md` in inline mode, or
  `{run_dir}/worker-receipts.json` in pipeline mode
- Fault: Abort if any required task fails, a wave cannot complete, or the
  expected inline result or worker receipts are missing.

### Stage 3: Synthesize

Run this stage only in pipeline mode. Combine the plan and the completed worker
outputs into one coherent artifact at `{final_output}` so Stage 4 can present a
single result. Skip this stage entirely for inline mode because Stage 2 already
produced the result that presentation should use directly.

task(general-purpose, model=claude-opus-4.6):

> Use the skill tool to invoke `task-coordinator-synthesize` with the pipeline
> plan, worker receipts, `run_dir: {run_dir}`, and `output_file:
{final_output}`. Persist the synthesis artifact and any receipt needed for
> presentation.

- Output: `{final_output}`
- Fault: Continue to Stage 4 with degraded pipeline context if synthesis fails
  or `{final_output}` cannot be produced.

### Stage 4: Present

Present the final result to the user. In inline mode, read the direct Stage 2
output. In pipeline mode, read the synthesized artifact when available, or
report the degraded pipeline context if Stage 3 could not produce the final
synthesis file.

task(general-purpose, model=gpt-5.4):

> Use the skill tool to invoke `task-coordinator-present` with `mode: {mode}`
> and `result_file: {result_file}`. Present the best available orchestration
> result for that mode and persist the presentation receipt.

- Output: `{run_dir}/presentation-receipt.json`
- Fault: Abort if presentation fails.

## Session Files

- `{run_dir}/plan.json`
- `{run_dir}/inline-result.md`
- `{run_dir}/worker-receipts.json`
- `{run_dir}/presentation-receipt.json`
- `{session_dir}/{timestamp}-task-coordinator-synthesis.md`

## Output

- `mode: "inline" | "pipeline"`
- `result_file: string`
- `summary: string`

## Examples

- Happy: one planned task yields inline mode, Stage 2 runs it once, and Stage 4
  presents that direct result without synthesis.
- Happy: four planned tasks form dependency waves, Stage 2 runs each wave in
  parallel, Stage 3 writes `{final_output}`, and Stage 4 presents the
  synthesized result.
- Failure: Stage 1 produces no valid plan, so the workflow aborts before any
  execution begins.
- Failure: a required Stage 2 task fails inside a pipeline wave, so the
  workflow aborts without synthesis or presentation.

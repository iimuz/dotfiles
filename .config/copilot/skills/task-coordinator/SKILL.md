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

## Role

Thin orchestrator that delegates all phase work to specialized sub-skills. The coordinator
holds only `plan.json` and the final receipt — never worker prompts, outputs, or reference
files. Each phase is executed by spawning an agent that invokes the corresponding sub-skill.

Use the `skill` tool to read a skill's description before decomposition decisions. Never invoke
a skill to produce deliverables — delegate to a subagent instead. Embed explicit skill
instructions in the worker's prompt file. If a subtask creates, modifies, or reviews a skill,
instruct the subagent to invoke `skill-creator`.

Phase-specific references reside in sub-skill directories:

- Planning: `task-coordinator-plan/references/`
- Synthesis: `task-coordinator-synthesize/references/`

## Interface

```typescript
/**
 * @skill task-coordinator
 * @input  { request: string }
 * @output { result: InlineResult | SynthesisReceipt }
 *
 * @param request  User's task request (required)
 * @returns result  Final result for inline or pipeline execution
 */

// Types: Plan, Task, AgentType, WorkerReceipt, InlineResult, SynthesisReceipt

type InlineResult = {
  task_id: string;
  output: string;
};

/**
 * @invariants
 * - invariant: (imperative_step_list_detected) => abort("replace imperative steps with typed ops");
 * - invariant: (op_lacks_typed_signature) => abort("All ops must be typed (input: T) -> U");
 * - invariant: (prose_in_op_body) => abort("convert prose to symbolic notation");
 * - invariant: (subagent_spawns_subagent) => abort("Subagents must not spawn subagents");
 * - invariant: (main_agent_reads_reference_file) => abort("Pass reference paths to subagents only; do not load in coordinator context");
 */
```

> **Severity model**
>
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

## Operations

```typespec
op orchestrate(request: string) -> InlineResult | SynthesisReceipt {
  // Compute run_id (tc-{YYYYMMDD}-{HHMMSS}), session_id, run_dir
  // Delegate each phase to its sub-skill via spawned agents
  invariant: (main_reads_intermediate_files) => abort("Main agent reads only final receipt");
  invariant: (main_invokes_skill_tool) => abort("Main agent must not call skill() tool; sub-agents invoke skills themselves");
  invariant: (main_explores_codebase) => abort("Main agent must not run glob/grep/view on codebase; pass request to sub-agents");
}
```

## Execution

Compute `run_id` and `run_dir` before starting the pipeline.

### Phase 1: Plan

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-plan' with input: { request, session_id, run_id, run_dir }")
```

Read `plan.json` from `{run_dir}/plan.json` after the agent completes.

### Phase 2: Execute

Branch by `plan.tasks.length`:

- **Inline** (1 task):

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-execute' with input: { plan } -- call execute_inline")
```

- **Pipeline** (2+ tasks):

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-execute' with input: { plan } -- call execute_pipeline")
```

### Phase 3: Synthesize (pipeline only)

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-synthesize' with input: { plan, receipts }")
```

### Phase 4: Present

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-present' with input: { result }")
```

### Pipeline Summary

```text
plan -> validate_plan -> [execute_inline | execute_pipeline] -> synthesize? -> present
```

Symbol legend: `|` = XOR branch (gated by `plan.tasks.length`); `?` = pipeline mode only.

| dependent   | prerequisite | description                                             |
| ----------- | ------------ | ------------------------------------------------------- |
| _(col key)_ | _(col key)_  | _(dependent requires prerequisite first)_               |
| execute     | plan         | execute consumes validated `plan.json` from plan phase  |
| synthesize  | execute      | synthesize unifies worker receipts (pipeline mode only) |
| present     | synthesize   | present displays final result or synthesis receipt      |

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

Thin orchestrator that delegates all phase work to specialized sub-skills. The coordinator
holds only `plan.json` and the final receipt -- never worker prompts, outputs, or reference
files. Each phase is executed by spawning an agent that invokes the corresponding sub-skill.

## Interface

```typescript
/**
 * @skill task-coordinator
 * @input  { request: string }
 * @output { result: InlineResult | SynthesisReceipt }
 */

// Canonical type definitions -- sub-skills mirror these verbatim
type Plan = {
  schema_version: string;
  run_id: string; // format: tc-{YYYYMMDD}-{HHMMSS}
  goal: string;
  tasks: Task[];
  synthesis_output_file: string;
  // run_dir = ~/.copilot/session-state/{sessionId}/files/{run_id}/
};

type Task = {
  id: string;
  agent_type: AgentType;
  prompt_file: string;
  output_file: string;
  depends_on: string[];
  description?: string;
  model?: string;
};

type AgentType = "explore" | "task" | "general-purpose" | "code-review";
type WorkerReceipt = {
  status: "WORKER_OK" | "WORKER_FAIL";
  id: string;
  reason?: string;
};
type InlineResult = WorkerReceipt;
type SynthesisReceipt = {
  status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL";
  output_file: string;
  summary: string;
  /* 2-4 sentences */ reason?: string;
};

/**
 * @invariants (orchestrator-level)
 * 1. Zero_Verbosity:      imperative step-list instructions => remove entirely
 * 2. Signature_Integrity: every op => typed (input: T) -> U
 * 3. Minimal_Token:       prose descriptions => symbolic/typespec notation
 * 4. No_Recursion:        (subagent_spawns_subagent) => abort("Subagents must not spawn subagents")
 * 5. No_Main_Ref_Load:    (main_agent_reads_reference_file) => abort("Pass reference file paths to subagents only; do not load references in coordinator context")
 *
 * @invariants (delegated to sub-skills)
 * - Planner_First, No_Pre_Investigation => task-coordinator-plan
 * - No_Peeking, Execution_Only          => task-coordinator-execute
 */
```

## Operations

```typespec
op orchestrate(request: string) -> InlineResult | SynthesisReceipt {
  // Compute run_id (tc-{YYYYMMDD}-{HHMMSS}), session_id, run_dir
  // Delegate each phase to its sub-skill via spawned agents

  invariant: (main_reads_intermediate_files) => abort("Main agent reads only final receipt");
  invariant: (main_invokes_skill_tool)       => abort("Main agent must not call skill() tool; sub-agents invoke skills themselves");
  invariant: (main_explores_codebase)        => abort("Main agent must not run glob/grep/view on codebase; pass request to sub-agents");
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

Skip this phase for inline mode.

### Phase 4: Present

```text
task(agent_type: "general-purpose", prompt: "Use the skill tool to invoke 'task-coordinator-present' with input: { result }")
```

### Pipeline Summary

```text
plan -> validate_plan -> [execute_inline | execute_pipeline] -> synthesize? -> present
```

Symbol legend: `|` = XOR branch (gated by `plan.tasks.length`); `?` = pipeline mode only.

## Skill Integration

Use the `skill` tool to read a skill's description before decomposition decisions. Never invoke a skill to produce
deliverables -- delegate to a subagent instead. Embed explicit skill instructions in the worker's prompt file. If a
subtask creates, modifies, or reviews a skill, instruct the subagent to invoke `skill-creator`.

## References

Phase-specific references are co-located with their owning sub-skills:

- Planning: `task-coordinator-plan/references/planner-protocol.md`, `task-coordinator-plan/references/plan-schema.md`
- Synthesis: `task-coordinator-synthesize/references/synthesizer-protocol.md`

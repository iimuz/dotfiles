---
name: implementation-plan
description: Multi-model parallel implementation plan orchestrator.
user-invocable: true
disable-model-invocation: false
---

# Implementation Plan Generator

## Role

Thin orchestrator that delegates all planning work to specialized sub-skills. Launch 3 parallel
analyses, 3 parallel plan drafts, 3 parallel cross-reviews, parallel aggregation and validation,
conflict resolution, and final synthesis into a single authoritative plan.

## Interface

```typescript
/**
 * @skill implementation-plan
 * @input  { user_request: string }
 * @output { plan_filepath: string }
 *
 * @param user_request  The implementation task or feature request to plan (required)
 * @returns plan_filepath  Path to the final authoritative plan file
 */

/**
 * @invariants
 * - invariant: (main_reads_intermediate_files) => abort("Main agent reads only final plan filepath");
 * - invariant: (main_invokes_skill_tool) => abort("Main agent must not call skill() tool; sub-agents invoke skills themselves");
 * - invariant: (main_explores_codebase) => abort("Main agent must not run glob/grep/view on codebase; pass user_request to sub-agents");
 */
```

### Severity Model

- `abort(reason)` — halt execution immediately; do not produce partial output
- `warn(reason)` — log the issue and continue in degraded mode

## Operations

```typespec
op orchestrate(session_id: string, user_request: string) -> string {
  // Stage 1: Launch 3 parallel analysis sub-skill calls
  // Stage 2: Launch 3 parallel plan draft sub-skill calls
  // Stage 3: Launch 3 parallel cross-review sub-skill calls
  // Stage 4: Launch aggregate + validate in parallel
  // Stage 5: Resolve conflicts
  // Stage 6: Synthesize final plan

  invariant: (main_reads_intermediate_files) => abort("Main agent reads only final plan filepath");
  invariant: (main_invokes_skill_tool) => abort("Main agent must not call skill() tool; sub-agents invoke skills themselves");
  invariant: (main_explores_codebase) => abort("Main agent must not run glob/grep/view on codebase; pass user_request to sub-agents");
}
```

## Execution

Generate a `timestamp` in YYYYMMDDHHMMSS format before starting the pipeline.

### Stage 1: Parallel Analysis (3x)

Launch 3 sub-skill calls in parallel -- one per model:

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'implementation-plan-analyze' with input: { session_id, model_name: 'claude-opus-4.6', user_request, timestamp }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'implementation-plan-analyze' with input: { session_id, model_name: 'gemini-3-pro-preview', user_request, timestamp }")
task(agent_type: "general-purpose", model: "gpt-5.3-codex",        prompt: "Use the skill tool to invoke 'implementation-plan-analyze' with input: { session_id, model_name: 'gpt-5.3-codex', user_request, timestamp }")
```

Fault tolerance: require at least 2 of 3 to succeed; abort if fewer.

### Stage 2: Parallel Plan Drafting (3x)

After Stage 1 completes, launch 3 sub-skill calls in parallel:

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'implementation-plan-draft' with input: { session_id, model_name: 'claude-opus-4.6', timestamp }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'implementation-plan-draft' with input: { session_id, model_name: 'gemini-3-pro-preview', timestamp }")
task(agent_type: "general-purpose", model: "gpt-5.3-codex",        prompt: "Use the skill tool to invoke 'implementation-plan-draft' with input: { session_id, model_name: 'gpt-5.3-codex', timestamp }")
```

Fault tolerance: require at least 2 of 3 to succeed; abort if fewer.

### Stage 3: Parallel Cross-Review (3x)

After Stage 2 completes, launch 3 sub-skill calls in parallel:

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'implementation-plan-review' with input: { session_id, model_name: 'claude-opus-4.6', timestamp }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'implementation-plan-review' with input: { session_id, model_name: 'gemini-3-pro-preview', timestamp }")
task(agent_type: "general-purpose", model: "gpt-5.3-codex",        prompt: "Use the skill tool to invoke 'implementation-plan-review' with input: { session_id, model_name: 'gpt-5.3-codex', timestamp }")
```

Fault tolerance: if all fail, abort; if 1 fails, continue with note.

### Stage 4: Parallel Consolidation

After Stage 3 completes, launch 2 sub-skill calls in parallel:

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'implementation-plan-aggregate' with input: { session_id, timestamp }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'implementation-plan-validate' with input: { session_id, timestamp }")
```

If aggregate fails: passthrough (forward reviews directly to synthesize with fallback notice).
If validate fails: passthrough (skip unique insights in synthesis).

### Stage 5: Conflict Resolution

After Stage 4 completes:

```text
task(agent_type: "general-purpose", model: "gpt-5.3-codex", prompt: "Use the skill tool to invoke 'implementation-plan-resolve' with input: { session_id, timestamp }")
```

If no conflicts found (empty step3b), proceed to Stage 6.

### Stage 6: Synthesis

After Stage 5 completes, determine the output filepath:

- Ask user to provide a preferred plan name, OR derive from user_request: `{purpose}-{component}-1.md`
- `output_filepath = ~/.copilot/session-state/{session_id}/files/{purpose}-{component}-1.md`

```text
task(agent_type: "general-purpose", model: "gpt-5.3-codex", prompt: "Use the skill tool to invoke 'implementation-plan-synthesize' with input: { session_id, user_request, timestamp, output_filepath }")
```

Return the `output_filepath` to the caller.

### Pipeline Summary

```text
stage1_analyze (3x parallel) -> stage2_draft (3x parallel) -> stage3_review (3x parallel) -> [stage4_aggregate + stage4_validate] (parallel) -> stage5_resolve -> stage6_synthesize -> return plan_filepath
```

| dependent         | prerequisite     | description                                 |
| ----------------- | ---------------- | ------------------------------------------- |
| _(column key)_    | _(column key)_   | _(dependent requires prerequisite first)_   |
| stage2_draft      | stage1_analyze   | drafts consume stage 1 analysis files       |
| stage3_review     | stage2_draft     | reviews consume stage 2 draft files         |
| stage4_aggregate  | stage3_review    | consensus aggregates stage 3 reviews        |
| stage4_validate   | stage2_draft     | validation reads stage 2 drafts and reviews |
| stage5_resolve    | stage4_aggregate | resolution consumes consensus artifact      |
| stage6_synthesize | stage5_resolve   | synthesis requires resolved conflicts       |

## Session Artifacts

All intermediate files are saved to `~/.copilot/session-state/{session_id}/files/`:

| File                                      | Content                                      |
| ----------------------------------------- | -------------------------------------------- |
| `step1-{model}-{timestamp}.md`            | Model-specific analysis output (Stage 1)     |
| `step2-{model}-plan-draft-{timestamp}.md` | Model-specific plan draft (Stage 2)          |
| `step2-{model}-review-{timestamp}.md`     | Model-specific cross-review (Stage 3)        |
| `step3a-consensus-{timestamp}.md`         | Aggregated consensus and conflicts (Stage 4) |
| `step3c-insights-{timestamp}.md`          | Validated unique insights (Stage 4)          |
| `step3b-resolutions-{timestamp}.md`       | Conflict resolutions (Stage 5)               |
| `{purpose}-{component}-{version}.md`      | Final authoritative plan (Stage 6)           |

The main agent reads only the final `plan_filepath` returned by Stage 6.

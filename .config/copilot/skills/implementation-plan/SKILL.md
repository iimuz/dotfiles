---
name: implementation-plan
description: Multi-model parallel implementation plan orchestrator. Use when creating implementation plans, breaking down features into tasks, or when the user asks to plan code changes, architecture decisions, or feature development.
user-invocable: true
disable-model-invocation: false
---

# Implementation Plan Generator

## Overview

Thin orchestrator that delegates all planning work to specialized sub-skills. Launch 3 parallel
analyses, 3 parallel plan drafts, 3 parallel cross-reviews, parallel aggregation and validation,
conflict resolution, and final synthesis into a single authoritative plan.

All stage artifacts use `{session_dir}` which resolves to
`~/.copilot/session-state/{session_id}/files/` for the current session.

## Schema

```typescript
interface OrchestrateInput {
  user_request: string;
}

interface OrchestrateOutput {
  plan_filepath: string;
}
```

## Constraints

- If user_request is missing or empty, abort immediately with no fallback.
- The main agent reads only the final plan filepath.
- The main agent must not call skill() directly.
- The main agent must not run glob/grep/view on the codebase.
- Generate timestamp in YYYYMMDDHHMMSS format, then execute Stage 1 through Stage 6 in order.

## Execution

```python
timestamp = now("YYYYMMDDHHMMSS")
session_dir = "~/.copilot/session-state/{session_id}/files"
stage1_analyze()
stage2_draft()
stage3_review()
stage4_artifact_paths = stage2_draft_paths + stage3_review_paths
stage4_consolidate()
stage5_resolve()
stage6_reference_filepaths = stage2_draft_paths + stage3_review_paths + [stage4_consensus_path, stage4_insights_path, stage5_resolutions_path]
stage6_synthesize()
return plan_filepath
```

### Stage 1: Parallel Analysis

- Purpose: Produce three independent codebase analyses from distinct models
- Inputs: `session_dir: string`, `user_request: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-analyze with
      user_request={user_request},
      output_filepath={session_dir}/step1-claude-opus-4.6-analysis-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      Invoke skill implementation-plan-analyze with
      user_request={user_request},
      output_filepath={session_dir}/step1-gemini-3-pro-preview-analysis-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: >
      Invoke skill implementation-plan-analyze with
      user_request={user_request},
      output_filepath={session_dir}/step1-gpt-5.3-codex-analysis-{timestamp}.md
  ```

- Outputs: `stage1_analysis_paths: string[]`
- Guards: at least two analysis artifacts are written
- Faults:
  - If fewer than 2 analysis models complete, abort immediately.
  - If a single model fails, note degraded mode and continue.

### Stage 2: Parallel Plan Drafting

- Purpose: Draft three complete implementation plans from Stage 1 analyses
- Inputs: `session_dir: string`, `stage1_analysis_paths: string[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-draft with
      analysis_paths={stage1_analysis_paths},
      output_filepath={session_dir}/step2-claude-opus-4.6-plan-draft-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      Invoke skill implementation-plan-draft with
      analysis_paths={stage1_analysis_paths},
      output_filepath={session_dir}/step2-gemini-3-pro-preview-plan-draft-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: >
      Invoke skill implementation-plan-draft with
      analysis_paths={stage1_analysis_paths},
      output_filepath={session_dir}/step2-gpt-5.3-codex-plan-draft-{timestamp}.md
  ```

- Outputs: `stage2_draft_paths: string[]`
- Guards: Stage 1 artifacts exist and at least two drafts complete
- Faults:
  - If fewer than 2 draft models complete, abort immediately.
  - If a single model fails, note degraded mode and continue.

### Stage 3: Parallel Cross-Review

- Purpose: Cross-review all draft plans from three model perspectives
- Inputs: `session_dir: string`, `stage2_draft_paths: string[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-review with
      draft_paths={stage2_draft_paths},
      output_filepath={session_dir}/step3-claude-opus-4.6-review-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      Invoke skill implementation-plan-review with
      draft_paths={stage2_draft_paths},
      output_filepath={session_dir}/step3-gemini-3-pro-preview-review-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: >
      Invoke skill implementation-plan-review with
      draft_paths={stage2_draft_paths},
      output_filepath={session_dir}/step3-gpt-5.3-codex-review-{timestamp}.md
  ```

- Outputs: `stage3_review_paths: string[]`
- Guards: Stage 2 drafts exist and at least one review succeeds
- Faults:
  - If all reviews fail, abort immediately.
  - If a single review fails, note the missing reviewer and continue.

### Stage 4: Parallel Consolidation

- Purpose: Aggregate consensus and validate unique insights in parallel
- Inputs: `session_dir: string`, `stage3_review_paths: string[]`, `stage4_artifact_paths: string[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-aggregate with
      review_paths={stage3_review_paths},
      output_filepath={session_dir}/step4-consensus-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-validate with
      artifact_paths={stage4_artifact_paths},
      output_filepath={session_dir}/step4-insights-{timestamp}.md
  ```

- Outputs: `stage4_consensus_path: string`, `stage4_insights_path: string`
- Guards: Stage 3 reviews are available
- Faults:
  - If aggregation fails, forward reviews to synthesize with a fallback notice and continue.
  - If validation fails, skip unique insights in synthesis and continue.

### Stage 5: Conflict Resolution

- Purpose: Resolve conflicts from consensus into definitive decisions
- Inputs: `session_dir: string`, `stage4_consensus_path: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-resolve with
      consensus_path={stage4_consensus_path},
      output_filepath={session_dir}/step5-resolutions-{timestamp}.md
  ```

- Outputs: `stage5_resolutions_path: string`
- Guards: Stage 4 completed; empty conflicts still permit Stage 6
- Faults:
  - If resolution fails, proceed to Stage 6 without resolutions and continue.

### Stage 6: Synthesis

- Purpose: Produce the final authoritative plan and return plan_filepath
- Inputs: `session_dir: string`, `user_request: string`, `stage6_reference_filepaths: string[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill implementation-plan-synthesize with
      reference_filepaths={stage6_reference_filepaths},
      user_request={user_request},
      output_filepath={session_dir}/implementation-plan-{timestamp}.md
  ```

- Outputs: `plan_filepath: string`
- Guards: output filepath is `{session_dir}/implementation-plan-{timestamp}.md`
- Faults:
  - If synthesis fails, abort immediately with no fallback.

## Session Files

| File                                                    | Written by | Read by                   |
| ------------------------------------------------------- | ---------- | ------------------------- |
| `{session_dir}/step1-{model}-analysis-{timestamp}.md`   | Stage 1    | Stage 2                   |
| `{session_dir}/step2-{model}-plan-draft-{timestamp}.md` | Stage 2    | Stage 3, Stage 4, Stage 6 |
| `{session_dir}/step3-{model}-review-{timestamp}.md`     | Stage 3    | Stage 4, Stage 6          |
| `{session_dir}/step4-consensus-{timestamp}.md`          | Stage 4    | Stage 5, Stage 6          |
| `{session_dir}/step4-insights-{timestamp}.md`           | Stage 4    | Stage 6                   |
| `{session_dir}/step5-resolutions-{timestamp}.md`        | Stage 5    | Stage 6                   |
| `{session_dir}/implementation-plan-{timestamp}.md`      | Stage 6    | Final output              |

## Examples

### Happy Path

- Input: { user_request: "Add user auth to the API" }
- Stages 1–6 all succeed; final plan written to step artifacts and output_filepath
- Output: { plan_filepath: "{session_dir}/implementation-plan-{timestamp}.md" }

### Failure Path

- Input: { user_request: "" }
- Orchestration aborts immediately because user_request is missing.
- No fallback is available; the workflow aborts.

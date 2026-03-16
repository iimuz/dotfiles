---
name: implementation-plan
description: Multi-model parallel implementation plan orchestrator. Use when creating implementation plans, breaking down features into tasks, or when the user asks to plan code changes, architecture decisions, or feature development.
user-invocable: true
disable-model-invocation: false
---

# Implementation Plan Generator

## Overview

Thin orchestrator that delegates all planning work to specialized sub-skills. Run Stage 1
through Stage 6 in order to produce independent analyses, competing plan drafts, cross-reviews,
consensus and insight artifacts, conflict resolutions, and one final authoritative plan.

All stage artifacts use `{session_dir}`, which resolves to
`~/.copilot/session-state/{session_id}/files/` for the current session.

- Generate `{timestamp}` in `YYYYMMDDHHMMSS` format at execution start.
- Derive `{run_dir}` as `{session_dir}/{timestamp}-implementation-plan/` for intermediate artifacts.
- Derive `{final_output}` as `{session_dir}/{timestamp}-implementation-plan.md`.
- Abort immediately if `user_request` is missing or empty.
- Read only `{final_output}` when returning the result to the caller.
- Do not call `skill()` directly from the main agent.
- Do not inspect the codebase with `glob`, `rg`, or `view`; all planning work must flow through delegated stages.

## Input

- `user_request: string` - Non-empty implementation planning request.

## Output

- `plan_filepath: string` - Final path written to `{final_output}`.

## Execution Flow

### Stage 1: Parallel Analysis

Launch three independent analyses in parallel with `claude-opus-4.6`,
`gemini-3-pro-preview`, and `gpt-5.4`. Each analysis should interpret the same
`user_request` without seeing the others so later drafting starts from distinct perspectives.

task(general-purpose, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> Invoke skill implementation-plan-analyze with
> user_request={user_request},
> output_filepath={run_dir}/step1-{model}-analysis.md

- Output: `{run_dir}/step1-{model}-analysis.md` (3 files expected; read by Stage 2)
- Fault: Fewer than 2 analysis artifacts: abort. Exactly 2 analysis artifacts: continue in degraded mode.

### Stage 2: Parallel Plan Drafting

Use the successful Stage 1 analyses to draft three complete implementation plans in parallel.
This stage turns exploratory analysis into concrete execution options that can later be compared
and reviewed.

task(general-purpose, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> Invoke skill implementation-plan-draft with
> analysis_paths={stage1_analysis_paths},
> output_filepath={run_dir}/step2-{model}-plan-draft.md

- Output: `{run_dir}/step2-{model}-plan-draft.md` (3 files expected; read by Stage 3, Stage 4, and Stage 6)
- Fault: Fewer than 2 draft artifacts: abort. Exactly 2 draft artifacts: continue in degraded mode.

### Stage 3: Parallel Cross-Review

Ask the same three models to cross-review the Stage 2 draft set in parallel. These reviews are
used both to identify consensus and to surface disagreements or missing ideas before synthesis.

task(general-purpose, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> Invoke skill implementation-plan-review with
> draft_paths={stage2_draft_paths},
> output_filepath={run_dir}/step3-{model}-review.md

- Output: `{run_dir}/step3-{model}-review.md` (1-3 files expected; read by Stage 4 and Stage 6)
- Fault: All reviews fail: abort. Partial review success: continue with available reviewers.

### Stage 4: Parallel Consolidation

Run consolidation in parallel to extract consensus from the reviews and validate unique insights
across the draft and review artifacts. This stage separates shared recommendations from novel but
credible ideas so later resolution and synthesis can weigh both.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill implementation-plan-aggregate with
> review_paths={stage3_review_paths},
> output_filepath={run_dir}/step4-consensus.md

task(general-purpose, model=claude-opus-4.6):

> Invoke skill implementation-plan-validate with
> artifact_paths={stage4_artifact_paths},
> output_filepath={run_dir}/step4-insights.md

- Output: `{run_dir}/step4-consensus.md`, `{run_dir}/step4-insights.md` (`step4-consensus.md`
  is read by Stage 5 and Stage 6; `step4-insights.md` is read by Stage 6)
- Fault: Missing consensus: continue with reviews forwarded to synthesis. Missing insights: continue without unique insights.

### Stage 5: Conflict Resolution

Resolve conflicts identified in the consensus artifact into a definitive set of planning
decisions. Even when there are no substantive conflicts, this stage normalizes the decision set
so synthesis receives a stable input.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill implementation-plan-resolve with
> consensus_path={stage4_consensus_path},
> output_filepath={run_dir}/step5-resolutions.md

- Output: `{run_dir}/step5-resolutions.md` (optional; read by Stage 6)
- Fault: Resolution failure: continue to Stage 6 without resolutions.

### Stage 6: Synthesis

Produce the final authoritative implementation plan from the plan drafts, reviews, consensus,
validated insights, and optional conflict resolutions. This stage is the only stage allowed to
write the final artifact returned to the caller.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill implementation-plan-synthesize with
> reference_filepaths={stage6_reference_filepaths},
> user_request={user_request},
> output_filepath={final_output}

- Output: `{final_output}`
- Fault: Synthesis failure: abort with no fallback.

## Session Files

Intermediate files are saved under `{run_dir}/`. The final output is saved directly under
`{session_dir}/`.

| File                                               | Written by | Read by                   |
| -------------------------------------------------- | ---------- | ------------------------- |
| `{run_dir}/step1-{model}-analysis.md`              | Stage 1    | Stage 2                   |
| `{run_dir}/step2-{model}-plan-draft.md`            | Stage 2    | Stage 3, Stage 4, Stage 6 |
| `{run_dir}/step3-{model}-review.md`                | Stage 3    | Stage 4, Stage 6          |
| `{run_dir}/step4-consensus.md`                     | Stage 4    | Stage 5, Stage 6          |
| `{run_dir}/step4-insights.md`                      | Stage 4    | Stage 6                   |
| `{run_dir}/step5-resolutions.md`                   | Stage 5    | Stage 6                   |
| `{session_dir}/{timestamp}-implementation-plan.md` | Stage 6    | Final output              |

## Examples

- Happy: `user_request: "Add user auth to the API"` -- all six stages succeed and write `{plan_filepath}`.
- Failure: `user_request: ""` -- abort because the required request is empty.

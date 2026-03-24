---
name: implementation-plan
description: Multi-model parallel implementation plan orchestrator. Use when creating implementation plans, breaking down features into tasks, or when the user asks to plan code changes, architecture decisions, or feature development.
user-invocable: true
disable-model-invocation: false
---

# Implementation Plan Generator

## Overview

Thin orchestrator that delegates all planning work to specialized sub-skills. Run Stage 1
through Stage 4 in order to produce competing plan drafts, cross-reviews, a resolution document,
and one final authoritative plan.

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

### Stage 1: Parallel Draft

Launch three independent drafts in parallel with `claude-opus-4.6`,
`gemini-3-pro-preview`, and `gpt-5.4`. Each model explores the codebase and produces a
complete draft plan without seeing the others.

task(implementation-plan-draft, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> user_request={user_request},
> output_filepath={run_dir}/step1-{model}-draft.md

- Output: `{run_dir}/step1-{model}-draft.md` (3 files expected; read by Stage 2 and Stage 4)
- Fault: Fewer than 2 draft artifacts: abort. Exactly 2 draft artifacts: continue in degraded mode.

### Stage 2: Parallel Cross-Review

Ask three models to cross-review the Stage 1 draft set in parallel. Reviews surface consensus,
conflicts, gaps, and unique insights for downstream resolution.

task(implementation-plan-review, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> draft_paths={stage1_draft_paths},
> output_filepath={run_dir}/step2-{model}-review.md

- Output: `{run_dir}/step2-{model}-review.md` (1-3 files expected; read by Stage 3)
- Fault: All reviews fail: abort. Partial review success: continue with available reviews.

### Stage 3: Resolve

A single model reads all cross-reviews, aggregates consensus, resolves conflicts, and evaluates
unique insights into one authoritative resolution document.

task(implementation-plan-resolve, model=claude-opus-4.6):

> review_paths={stage2_review_paths},
> output_filepath={run_dir}/step3-resolution.md

- Output: `{run_dir}/step3-resolution.md` (read by Stage 4)
- Fault: Resolution failure: abort.

### Stage 4: Synthesis

Produce the final authoritative implementation plan from the resolution document and the
original draft plans. This stage is the only stage allowed to write the final artifact
returned to the caller.

Collect `{run_dir}/step1-*-draft.md` and `{run_dir}/step3-resolution.md` as
`{stage4_reference_filepaths}`.

task(implementation-plan-synthesize, model=claude-opus-4.6):

> reference_filepaths={stage4_reference_filepaths},
> user_request={user_request},
> output_filepath={final_output}

- Output: `{final_output}`
- Fault: Synthesis failure: abort with no fallback.

## Session Files

Intermediate files are saved under `{run_dir}/`. The final output is saved directly under
`{session_dir}/`.

| File                                               | Written by | Read by          |
| -------------------------------------------------- | ---------- | ---------------- |
| `{run_dir}/step1-{model}-draft.md`                 | Stage 1    | Stage 2, Stage 4 |
| `{run_dir}/step2-{model}-review.md`                | Stage 2    | Stage 3          |
| `{run_dir}/step3-resolution.md`                    | Stage 3    | Stage 4          |
| `{session_dir}/{timestamp}-implementation-plan.md` | Stage 4    | Final output     |

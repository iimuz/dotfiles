---
name: code-review
description: >-
  Use when reviewing code changes, analyzing staged/unstaged diffs, or when the
  user asks to review code quality, security, performance, or design compliance.
user-invocable: true
disable-model-invocation: false
---

# Code Review

## Overview

Orchestrator that runs parallel multi-model, multi-aspect code reviews, then performs
gap analysis, cross-checks, and final consolidation into a single report.

At execution start, generate a `YYYYMMDDHHMMSS` timestamp and derive:

- Intermediate artifacts: `{session_dir}/{timestamp}-code-review/` (referred to as `run_dir`)
- Final output: `{session_dir}/{timestamp}-code-review-consolidated-review.md`

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.

## Input

- `target`: Mentioned by the user in conversation. One of: commit SHA, branch name,
  PR number, `"staged"`, or `"unstaged"`. Ask the user if not specified.
- `design_info`: Design reference text, if mentioned by the user.
- `design_info_filepath`: Design reference file path, if mentioned. Takes precedence
  over `design_info`.

Skip the design-compliance aspect when design_info is unspecified or unresolvable.
Resolved design_info must not exceed 8000 characters.

## Output

The final report includes:

- Files reviewed `files_reviewed: number`
- Total issues `total_issues: number`
- Severity counts `critical: number`, `warnings: number`, `suggestions: number`
- Cross-check results `cross_checks: { valid: number, invalid: number, uncertain: number }`

## Execution Flow

### Stage 1: Parallel Aspect Reviews

Launch parallel subagents for each (model, aspect) pair:
3 models (claude-opus-4.6, gemini-3-pro-preview, gpt-5.4) x
4 mandatory aspects (security, quality, performance, best-practices).
Add design-compliance when design_info is resolved (up to 15 parallel).
Adapt the prompt template below with the actual aspect, model, target, and run_dir.

task(code-review-{aspect}, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4):

> target={target},
> output_filepath={run_dir}/review-{aspect}-{model}.md

For design-compliance, add `design_info={resolved_design_info}`.

- Output: `{run_dir}/review-{aspect}-{model}.md` (read by Stage 2, 4)
- Fault: Retry failed model once. Fewer than 2 successes per aspect: abort.
  Exactly 2 successes: note degraded mode in final report and continue.

### Stage 2: Gap Analysis

Compare findings across models to identify concerns missed by specific reviewers.
Adapt the prompt template below with the collected review file paths.

task(code-review-gap-analysis):

> review_file_paths={review_file_paths},
> output_filepath={run_dir}/gap-list.yml

- Output: `{run_dir}/gap-list.yml` (read by Stage 3, 4). Returns `gaps_found: {N}`.
- Fault: Abort immediately on failure.

### Stage 3: Cross-Check (only when gaps_found > 0)

For each gap entry, launch the model named in `missed_by` to verify the concern.
Group entries by model and aspect into a single invocation. Adapt the prompt template
below with the actual aspect, concerns, and model.

task(code-review-cross-check, model={missed_by_model}):

> aspect={aspect}, concerns={concerns},
> output_filepath={run_dir}/crosscheck-{aspect}-{model}.md

- Output: `{run_dir}/crosscheck-{aspect}-{model}.md` (read by Stage 4)
- Fault: Note failure in the final report and continue.

### Stage 4: Consolidation and Delivery

Merge all artifacts from Stages 1-3 into the final report. Adapt the prompt template
below with the collected file paths and the final output path.

task(code-review-consolidate):

> review_file_paths={review_file_paths},
> gap_list_path={run_dir}/gap-list.yml,
> crosscheck_paths={crosscheck_paths},
> output_filepath={final_output}

- Output: `{final_output}` (final output path)
- Fault: Abort immediately on failure.

## Examples

- Happy: `target: "HEAD"`, `design_info: "API must return JSON"` --
  all 5 aspects reviewed, final report delivered.
- Failure: `design_info_filepath: "/missing.md"` with no `design_info` --
  design-compliance skipped, 4 aspects reviewed.

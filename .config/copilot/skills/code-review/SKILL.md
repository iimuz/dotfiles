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

Runs parallel multi-model, multi-aspect code reviews, then performs
gap analysis, cross-checks, consolidation, and triage into a final prioritized report.

At execution start, generate a `YYYYMMDDHHMMSS` timestamp and derive:

- Intermediate artifacts: `{session_dir}/{timestamp}-code-review/` (referred to as `run_dir`)
- Final output: `{session_dir}/{timestamp}-code-review-consolidated-review.md`
- Skill criteria directory: `{skill_base_dir}/references/` (referred to as `refs_dir`)

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.
`skill_base_dir` is the `Base directory` value from the skill-context header.

## Input

- `target`: Mentioned by the user in conversation. One of: commit SHA, branch name,
  PR number, `"staged"`, or `"unstaged"`. Ask the user if not specified.
- `design_info`: Design reference text, if mentioned by the user.
- `design_info_filepath`: Design reference file path, if mentioned. Takes precedence
  over `design_info`.

Skip the design-compliance aspect when design_info is unspecified or unresolvable.
Resolved design_info must not exceed 8000 characters.

## Output

The final triage report includes:

- Files reviewed `files_reviewed: number`
- Total findings `total_findings: number`
- Triage counts `recommended: number`, `consider: number`
- Severity counts `critical: number`, `high: number`, `medium: number`, `low: number`
- Cross-check results `cross_checks: { valid: number, invalid: number, uncertain: number }`

## Aspect Review Template

When dispatching an aspect reviewer in Stage 1, pass the following prompt (fill in
`{aspect}`, `{target}`, `{criteria_path}`, and `{output_filepath}`):

> Read the change target (`target={target}`) and analyze strictly for `{aspect}` issues.
> Read the criteria from `{criteria_path}` first, then apply them.
>
> Rules:
>
> - Write findings to a new file at `{output_filepath}` using a file-writing tool call.
> - Do not include findings in the response text.
> - Return only: file path and finding count (e.g., "Written to /path/to/file.md (3 findings)").
> - If there are no findings, still create the file with an empty review body.
> - Abort if findings drift outside `{aspect}` scope.
> - Abort if the output file already exists.
> - Critical findings must include file and line number.
>
> Output format:
>
> ```markdown
> ## CRITICAL
>
> ### Brief description
>
> File: `path/to/file.ext:42`
>
> Detailed explanation.
>
> **Fix**: How to resolve it.
>
> ## HIGH
>
> ## MEDIUM
>
> ## LOW
> ```

For the `design-compliance` aspect, add to the Rules section:

> - Abort if `design_info` is missing or empty.
> - Each finding must cite the relevant design reference point.

And add a `Design Ref:` field after the `File:` line in the output format.

## Execution Flow

### Pre-Flight

Create `run_dir` before launching any agents:

```bash
mkdir -p {run_dir}
```

### Stage 1: Parallel Aspect Reviews

Launch parallel subagents for each (model, aspect) pair:
3 models (claude-opus-4.6, claude-sonnet-4.6, gpt-5.4) x
4 mandatory aspects (security, quality, performance, best-practices).
Add design-compliance when design_info is resolved (up to 15 parallel).

For each pair, dispatch:

task(general-purpose, model=claude-opus-4.6 / claude-sonnet-4.6 / gpt-5.4):

> [Aspect Review Template prompt with:
>
> > aspect={aspect},
> > target={target},
> > criteria_path={refs_dir}/{aspect}-criteria.md,
> > output_filepath={run_dir}/review-{aspect}-{model}.md]

For design-compliance, include `design_info={resolved_design_info}` in the prompt and
use `criteria_path={refs_dir}/design-compliance-criteria.md`.

- Output: `{run_dir}/review-{aspect}-{model}.md` (read by Stage 2, 4)
- Fault: Retry failed model once. Fewer than 2 successes per aspect: abort.
  Exactly 2 successes: note degraded mode in final report and continue.
- File verification: After each agent completes, check that `output_filepath`
  exists. If missing, write the agent's response text to `output_filepath` as
  fallback using a file-writing tool call. Log a warning that the agent did not write
  the file directly.

### Stage 2: Gap Analysis

Compare findings across models to identify concerns missed by specific reviewers.

task(general-purpose, model=claude-opus-4.6):

> Read the rules from `{refs_dir}/gap-analysis-rules.md` first, then execute with:
> review_file_paths={review_file_paths},
> output_filepath={run_dir}/gap-list.yml

- Output: `{run_dir}/gap-list.yml` (read by Stage 3, 4). Returns `gaps_found: {N}`.
- Fault: Abort immediately on failure.
- File verification: After agent completes, check that `output_filepath`
  exists. If missing, write the agent's response text to `output_filepath` as
  fallback.

### Stage 3: Cross-Check (only when gaps_found > 0)

For each gap entry, launch the model named in `missed_by` to verify the concern.
Group entries by model and aspect into a single invocation.

task(general-purpose, model={missed_by_model}):

> Read the rules from `{refs_dir}/cross-check-rules.md` first, then execute with:
> aspect={aspect}, concerns={concerns},
> output_filepath={run_dir}/crosscheck-{aspect}-{model}.md

- Output: `{run_dir}/crosscheck-{aspect}-{model}.md` (read by Stage 4)
- Fault: Note failure in the final report and continue.
- File verification: After each agent completes, check that `output_filepath`
  exists. If missing, write the agent's response text to `output_filepath` as
  fallback.

### Stage 4: Consolidation

Merge all artifacts from Stages 1-3 into the consolidated report.

task(general-purpose, model=claude-opus-4.6):

> Read the rules from `{refs_dir}/consolidate-rules.md` first, then execute with:
> review_file_paths={review_file_paths},
> gap_list_path={run_dir}/gap-list.yml,
> crosscheck_paths={crosscheck_paths},
> output_filepath={run_dir}/consolidated-review.md

- Output: `{run_dir}/consolidated-review.md` (read by Stage 5)
- Fault: Abort immediately on failure.
- File verification: After agent completes, check that `output_filepath`
  exists. If missing, write the agent's response text to `output_filepath` as
  fallback.

### Stage 5: Triage

Classify all findings from the consolidated report into Recommended and Consider
tiers using source code context.

task(general-purpose, model=claude-opus-4.6):

> Read the rules from `{refs_dir}/triage-rules.md` first, then execute with:
> consolidated_report_path={run_dir}/consolidated-review.md,
> target={target},
> output_filepath={final_output}

- Output: `{final_output}` (final output path)
- Fault: On failure, copy `{run_dir}/consolidated-review.md` to `{final_output}`.
  Prepend a header note: `> Triage stage failed - showing untriaged consolidated report.`
- File verification: After agent completes, check that `{final_output}` exists.
  If missing, apply the same fallback as Fault (copy consolidated report with
  degraded-mode note).

## Examples

- Happy: `target: "HEAD"`, `design_info: "API must return JSON"` --
  all 5 aspects reviewed, triaged final report delivered with Recommended and Consider tiers.
- Degraded triage: Stage 5 fails -- consolidated (untriaged) report delivered
  with degraded-mode note.
- Failure: `design_info_filepath: "/missing.md"` with no `design_info` --
  design-compliance skipped, 4 aspects reviewed.

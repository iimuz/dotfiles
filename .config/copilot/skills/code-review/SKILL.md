---
name: code-review
description: Multi-model parallel code review orchestrator. Use when reviewing code changes, analyzing staged/unstaged diffs, or when the user asks to review code quality, security, performance, or design compliance.
user-invocable: true
disable-model-invocation: false
---

# Code Review

## Overview

Thin orchestrator that delegates review work to specialized sub-skills.
It runs parallel aspect reviews across three models, then gap analysis, optional cross-checks, and final consolidation.

All stage artifacts use `{session_dir}` which resolves to
`~/.copilot/session-state/{session_id}/files/` for the current session.

## Schema

```typescript
type OrchestrateInput = {
  session_dir: string;
  target: string;
  design_info?: string;
  design_info_filepath?: string;
};

type ConsolidatedReview = {
  files_reviewed: number;
  total_issues: number;
  critical: number;
  warnings: number;
  suggestions: number;
  cross_checks: { valid: number; invalid: number; uncertain: number };
};
```

## Constraints

- If design_info is not provided or unresolvable, skip design-compliance.
- design_info_filepath takes precedence over design_info when both are provided.
- Resolved design_info must not exceed 8000 characters.

## Input

| Field                  | Type     | Required | Description                                                |
| ---------------------- | -------- | -------- | ---------------------------------------------------------- |
| `session_dir`          | `string` | yes      | Session files directory placeholder path                   |
| `target`               | `string` | yes      | Commit SHA, branch, PR number, `"staged"`, or `"unstaged"` |
| `design_info`          | `string` | no       | Design reference text for compliance review                |
| `design_info_filepath` | `string` | no       | Design reference file path, used when present              |

## Output

Delivery file: `{session_dir}/consolidated-review.md`

| Field            | Type                                                    | Description                  |
| ---------------- | ------------------------------------------------------- | ---------------------------- |
| `files_reviewed` | `number`                                                | Number of files evaluated    |
| `total_issues`   | `number`                                                | Total merged findings        |
| `critical`       | `number`                                                | Count of critical findings   |
| `warnings`       | `number`                                                | Count of warning findings    |
| `suggestions`    | `number`                                                | Count of suggestion findings |
| `cross_checks`   | `{ valid: number; invalid: number; uncertain: number }` | Cross-check summary counts   |

## Execution

```python
def run_code_review(session_dir, target, design_info=None, design_info_filepath=None):
    stage1_parallel_aspect_reviews(session_dir, target, design_info, design_info_filepath)
    stage2_gap_analysis(session_dir)
    if read_gaps_found(session_dir) > 0:
        stage3_cross_check(session_dir)
    stage4_consolidate_and_deliver(session_dir)
```

### Stage 1: Parallel Aspect Reviews

- Purpose: Launch 12-15 parallel subagents (3 models x 4 mandatory aspects,
  plus design-compliance when design_info is provided) to generate per-aspect review files.
- Inputs: `session_dir: string`, `target: string`, `design_info?: string`, `design_info_filepath?: string`
- Actions:

  ```yaml
  # Launch 12-15 parallel subagents (3 models x 4-5 aspects)
  # Models: claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex
  # Aspects: security, quality, performance, best-practices
  # Conditional aspect: design-compliance (only when design_info resolved)
  # For each (model, aspect) pair, launch one subagent:
  - tool: task
    agent_type: "general-purpose"
    model: "{model}"
    prompt: >
      Invoke skill code-review-{aspect} with
      target={target},
      output_filepath={session_dir}/review-{aspect}-{model}-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "{model}"
    prompt: >
      Invoke skill code-review-design-compliance with
      target={target},
      design_info={resolved_design_info},
      output_filepath={session_dir}/review-design-compliance-{model}-{timestamp}.md
  ```

- Outputs: `{session_dir}/review-{aspect}-{model}-{timestamp}.md`
- Guards: Each non-design aspect must have at least two model outputs;
  include design-compliance only when design info is resolved.
- Faults:
  - If a model fails, retry once and continue.
  - If fewer than 2 models succeed for any aspect, abort immediately.
  - If exactly 2 models succeed for an aspect, note degraded mode in the final report and continue.

### Stage 2: Gap Analysis

- Purpose: Compare per-aspect findings across models and produce gap routing data.
- Inputs: `session_dir: string`,
  `review_file_paths: string[]`,
  `aspects: ("security" | "quality" | "performance" | "best-practices" | "design-compliance")[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill code-review-gap-analysis with
      review_file_paths={review_file_paths},
      output_filepath={session_dir}/gap-list.yml.
      Return exactly: gaps_found: <N>.
  ```

- Outputs: `{session_dir}/gap-list.yml`
- Guards: Stage 1 review files exist for every included aspect.
- Faults:
  - If gap analysis fails, abort immediately.

### Stage 3: Cross-Check

- Purpose: Validate concerns that one or more reviewers missed according to `gap-list.yml`.
- Inputs: `session_dir: string`, `gap_list_path: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      From {gap_list_path}, for entries where missed_by=claude-opus-4.6,
      group by aspect and invoke code-review-cross-check with
      aspect={aspect},
      concerns={concerns},
      output_filepath={session_dir}/crosscheck-{aspect}-claude-opus-4.6.md.
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      From {gap_list_path}, for entries where missed_by=gemini-3-pro-preview,
      group by aspect and invoke code-review-cross-check with
      aspect={aspect},
      concerns={concerns},
      output_filepath={session_dir}/crosscheck-{aspect}-gemini-3-pro-preview.md.
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: >
      From {gap_list_path}, for entries where missed_by=gpt-5.3-codex,
      group by aspect and invoke code-review-cross-check with
      aspect={aspect},
      concerns={concerns},
      output_filepath={session_dir}/crosscheck-{aspect}-gpt-5.3-codex.md.
  ```

- Outputs: `{session_dir}/crosscheck-{aspect}-{model}.md`
- Guards: Run only when `gaps_found > 0`; skip when `gaps_found == 0`.
- Faults:
  - If cross-check fails, note the failure in the final report and continue.

### Stage 4: Consolidation and Delivery

- Purpose: Merge all review artifacts and produce the final user-facing summary.
- Inputs: `session_dir: string`,
  `review_file_paths: string[]`,
  `gap_list_path: string`,
  `crosscheck_paths: string[]`,
  `aspects: ("security" | "quality" | "performance" | "best-practices" | "design-compliance")[]`,
  `models: ("claude-opus-4.6" | "gemini-3-pro-preview" | "gpt-5.3-codex")[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill code-review-consolidate with
      review_file_paths={review_file_paths},
      gap_list_path={gap_list_path},
      crosscheck_paths={crosscheck_paths},
      output_filepath={session_dir}/consolidated-review.md.
      Return the consolidated review file path.
  ```

- Outputs: `{session_dir}/consolidated-review.md`
- Guards: Consolidation must include available review files and available cross-check files.
- Faults:
  - If consolidation fails, abort immediately.

## Session Files

All files are saved under `{session_dir}/`.

| File                                     | Written by | Read by          |
| ---------------------------------------- | ---------- | ---------------- |
| `review-{aspect}-{model}-{timestamp}.md` | Stage 1    | Stage 2, Stage 4 |
| `gap-list.yml`                           | Stage 2    | Stage 3, Stage 4 |
| `crosscheck-{aspect}-{model}.md`         | Stage 3    | Stage 4          |
| `consolidated-review.md`                 | Stage 4    | Stage 4          |

## Examples

### Happy Path

- Input: `{ session_dir: "{session_dir}", target: "HEAD", design_info: "API must return JSON" }`
- Stage 1 runs aspect reviews, Stage 2 writes `gap-list.yml`, Stage 3 cross-checks gaps, Stage 4 consolidates.
- Output: `consolidated-review.md` is delivered with blocking and non-blocking findings.

### Failure Path

- Input: `{ session_dir: "{session_dir}", target: "HEAD", design_info_filepath: "/missing.md" }`
- Stage 1 cannot resolve design info because the file is missing or unreadable.
- If design_info is not provided or unresolvable, skip design-compliance.

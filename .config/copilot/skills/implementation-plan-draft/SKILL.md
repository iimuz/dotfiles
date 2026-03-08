---
name: implementation-plan-draft
description: Draft one implementation plan from analyses.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Draft

## Overview

Read 2+ analysis files to understand multi-perspective findings. Before drafting, read
`references/plan-template.md` for the required output structure. Synthesize analyses into a
complete implementation plan using TASK-### identifiers.

## Constraints

- If fewer than 2 analysis files are found, abort immediately.
- If output contains placeholder text (TODO, TBD), abort immediately.
- If output filepath is missing, abort immediately.

## Input

| Field             | Type       | Required | Description                                    |
| ----------------- | ---------- | -------- | ---------------------------------------------- |
| `analysis_paths`  | `string[]` | yes      | Absolute paths to analysis files (2+ required) |
| `output_filepath` | `string`   | yes      | Absolute path for saving the plan draft        |

## Output

Output written to `output_filepath`.

The draft must follow the template structure defined in `@references/plan-template.md`.

## Examples

### Happy Path

- Input: { analysis_paths: ["/tmp/a1.md", "/tmp/a2.md"], output_filepath: "/tmp/draft.md" }
- Output: draft written to `output_filepath`.

### Failure Path

- Input: { analysis_paths: ["/tmp/a1.md"], output_filepath: "/tmp/draft.md" }; only 1 file
- Abort: fewer than 2 analysis files available.

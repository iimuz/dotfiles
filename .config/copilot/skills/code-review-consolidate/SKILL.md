---
name: code-review-consolidate
description: Merge aspect reviews into unified report.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Consolidate

## Overview

Read review files, gap list results, and cross-check outputs, then deduplicate findings
and apply cross-check assessments. Synthesize a unified report from the remaining findings
and write it to `output_filepath`.

## Constraints

- Abort immediately if review input files are missing.
- Abort immediately if the output report shape is invalid.
- Abort immediately if the consolidated report is missing when delivering.
- Read only the consolidated report for formatting the final response.

## Input

| Field               | Type       | Required | Description                                    |
| ------------------- | ---------- | -------- | ---------------------------------------------- |
| `review_file_paths` | `string[]` | yes      | Absolute paths to aspect review files          |
| `gap_list_path`     | `string`   | no       | Absolute path to gap analysis results          |
| `crosscheck_paths`  | `string[]` | no       | Absolute paths to cross-check assessment files |
| `output_filepath`   | `string`   | yes      | Absolute path for saving consolidated report   |

## Output

Output written to `output_filepath`.

Delivery template sections:

- `## Code Review Summary`
- `### Critical Issues (Blocking)`
- `### Improvements (Non-Blocking)`
- `### Positive Observations`

## Examples

### Happy Path

- Input: `{ review_file_paths: ["/tmp/sec.md", "/tmp/qual.md"], output_filepath: "/tmp/consolidated.md" }`
- Output: consolidated report written to `/tmp/consolidated.md` with 5 findings.

### Failure Path

- Input: `{ review_file_paths: [], output_filepath: "/tmp/consolidated.md" }`
- Abort: missing review files.

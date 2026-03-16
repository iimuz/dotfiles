---
name: code-review-consolidate
description: Merge aspect reviews into unified report.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Consolidate

## Overview

Read review files, gap list results, and cross-check outputs. Deduplicate findings,
apply cross-check assessments, and synthesize a unified report.
Write the result to `output_filepath`.

Abort if review input files are missing.
Abort if the consolidated report shape is invalid.
Read only the consolidated report for formatting the final response.

## Input

- `review_file_paths: string[]` (required): Absolute paths to aspect review files
- `gap_list_path: string` (optional): Absolute path to gap analysis results
- `crosscheck_paths: string[]` (optional): Absolute paths to cross-check assessment files
- `output_filepath: string` (required): Absolute path for saving consolidated report

## Output

Written to `output_filepath`. Sections:

- `## Code Review Summary`
- `### Critical Issues (Blocking)`
- `### Improvements (Non-Blocking)`
- `### Positive Observations`

## Examples

- Happy: 2 review files provided -- consolidated report with 5 findings.
- Failure: empty review_file_paths -- abort: missing review files.

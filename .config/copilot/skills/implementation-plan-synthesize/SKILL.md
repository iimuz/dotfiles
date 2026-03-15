---
name: implementation-plan-synthesize
description: Synthesize artifacts into the final plan.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Synthesize

## Overview

Read all files listed in `reference_filepaths` and consolidate the artifacts into a single
authoritative plan written to `output_filepath`.

Ensure the plan is complete and contains no TODO or TBD placeholders. Write only to
`output_filepath` and confirm the file exists after writing. Abort if fewer than 2 input files
are found. Abort if `output_filepath` is missing. Abort if the final plan is incomplete.

## Input

- `user_request: string` (required): The original implementation request.
- `reference_filepaths: string[]` (required): Absolute paths to all input artifacts.
- `output_filepath: string` (required): Absolute path to write the final synthesized plan.

## Output

- `output_filepath: string`: The written final plan file path.

For the required output structure, see
[output-format.md](references/output-format.md).

## Examples

- Happy: `user_request="Add auth"`,
  `reference_filepaths=["/tmp/d1.md", "/tmp/d2.md"]`,
  `output_filepath="/tmp/final-plan.md"` -- final plan written.
- Failure: `reference_filepaths=["/tmp/d1.md"]`,
  `output_filepath="/tmp/final-plan.md"` -- abort because fewer than 2 draft files
  were found.

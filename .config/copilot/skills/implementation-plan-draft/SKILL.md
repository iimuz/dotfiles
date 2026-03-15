---
name: implementation-plan-draft
description: Draft one implementation plan from analyses.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Draft

## Overview

Read 2 or more analysis files to understand multi-perspective findings. Before drafting, read
`references/plan-template.md` for the required structure. Synthesize the analyses into a complete
implementation plan that uses TASK-### identifiers and write it to `output_filepath`.

Abort if fewer than 2 analysis files are provided. Abort if `output_filepath` is missing. Abort
if the draft contains placeholder text such as TODO or TBD.

## Input

- `analysis_paths: string[]` (required): Absolute paths to the analysis files;
  2 or more are required.
- `output_filepath: string` (required): Absolute path to write the plan draft.

## Output

- `output_filepath: string`: The written draft file path.
- `structure: string`: The draft follows `references/plan-template.md`.

## Examples

- Happy: `analysis_paths=["/tmp/a1.md", "/tmp/a2.md"]`, `output_filepath="/tmp/draft.md"` -- draft written.
- Failure: `analysis_paths=["/tmp/a1.md"]`,
  `output_filepath="/tmp/draft.md"` -- abort because fewer than 2 analysis files
  were provided.

---
name: implementation-plan-validate
description: Validate unique insights for feasibility.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Validate Insights

## Overview

Read artifacts from multiple drafts and reviews, identify unique insights, and assess each one
for technical feasibility, incremental value, and risk profile. Write the validated insights to
`output_filepath`.

Analyze only substantive artifact content. Never modify source code. If feasibility assessment is
blocked, include a partial assessment and continue. Abort if fewer than 2 artifact files are
found. Abort if writing the output fails.

## Input

- `artifact_paths: string[]` (required): Absolute paths to the draft and review
  files; 2 or more are required.
- `output_filepath: string` (required): Absolute path to write the insights output.

## Output

- `output_filepath: string`: The written insights file path.

## Examples

- Happy: `artifact_paths=["/tmp/d1.md", "/tmp/r1.md"]`, `output_filepath="/tmp/insights.md"` -- insights written.
- Failure: `artifact_paths=["/tmp/d1.md"]`,
  `output_filepath="/tmp/insights.md"` -- abort because fewer than 2 artifact files
  were found.

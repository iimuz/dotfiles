---
name: implementation-plan-aggregate
description: Aggregate consensus and enumerate conflicts.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Aggregate Consensus

## Overview

Read all cross-review outputs, extract insights shared across reviewers, identify conflicts with
supporting evidence, and write the consensus document to `output_filepath`.

Analyze only substantive review content. Abort if no review files are found. Abort if writing
the output fails.

## Input

- `review_paths: string[]` (required): Absolute paths to the cross-review files.
- `output_filepath: string` (required): Absolute path to write the consensus output.

## Output

- `output_filepath: string`: The written consensus file path.

## Examples

- Happy: `review_paths=["/tmp/r1.md", "/tmp/r2.md"]`, `output_filepath="/tmp/consensus.md"` -- consensus written.
- Failure: `review_paths=[]`, `output_filepath="/tmp/consensus.md"` -- abort because no review files were found.

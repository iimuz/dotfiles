---
name: implementation-plan-aggregate
description: Aggregate consensus and enumerate conflicts.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Aggregate Consensus

## Overview

Read all cross-review outputs, extract insights shared across reviewers, identify distinct
conflicts with supporting evidence, and write the consensus document.

## Constraints

- If no review files are found, abort immediately.
- Never attempt source code modification.
- Analyze only substantive content from review artifacts.
- If output write fails, abort immediately.

## Input

| Field             | Type       | Required | Description                               |
| ----------------- | ---------- | -------- | ----------------------------------------- |
| `review_paths`    | `string[]` | yes      | Absolute paths to cross-review files      |
| `output_filepath` | `string`   | yes      | Absolute path for saving consensus output |

## Output

Output written to `output_filepath`.

Output structure: Consensus Insights, Conflicts, and Isolated Insights with reviewer attribution.

## Examples

### Happy Path

- Input: { review_paths: ["/tmp/r1.md", "/tmp/r2.md"], output_filepath: "/tmp/consensus.md" }
- Output: consensus written to `output_filepath`.

### Failure Path

- Input: { review_paths: [], output_filepath: "/tmp/consensus.md" }; no review files
- Abort: no review files found.

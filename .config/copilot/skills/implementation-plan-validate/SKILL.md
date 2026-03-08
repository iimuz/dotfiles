---
name: implementation-plan-validate
description: Validate unique insights for feasibility.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Validate Insights

## Overview

Read artifacts from multiple drafts and reviews, identify model-specific unique insights, and
assess each for technical feasibility, incremental value, and risk profile.

## Constraints

- If fewer than 2 artifact files are found, abort immediately.
- Never attempt source code modification.
- Analyze only substantive artifact content.
- If feasibility assessment is blocked, include a partial assessment and continue.
- If output write fails, abort immediately.

## Input

| Field             | Type       | Required | Description                                            |
| ----------------- | ---------- | -------- | ------------------------------------------------------ |
| `artifact_paths`  | `string[]` | yes      | Absolute paths to draft and review files (2+ required) |
| `output_filepath` | `string`   | yes      | Absolute path for saving insights output               |

## Output

Output written to `output_filepath`.

Output contains Feasible Unique Insights and Rejected Insights with source model and rationale.

## Examples

### Happy Path

- Input: { artifact_paths: ["/tmp/d1.md", "/tmp/r1.md"], output_filepath: "/tmp/insights.md" }
- Output: insights written to `output_filepath`.

### Failure Path

- Input: { artifact_paths: ["/tmp/d1.md"], output_filepath: "/tmp/insights.md" }; only 1 file
- Abort: fewer than 2 artifact files available.

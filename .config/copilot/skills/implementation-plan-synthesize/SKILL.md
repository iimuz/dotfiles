---
name: implementation-plan-synthesize
description: Synthesize artifacts into the final plan.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Synthesize

## Overview

Discover input files from the reference path list, select the most recent file per prefix when
duplicates exist, and consolidate collective analysis into a single authoritative plan following
the 9-section output structure.

## Constraints

- If fewer than 2 draft files are found, abort immediately.
- If the final plan is incomplete, abort immediately.
- Ensure the final plan has all required sections and no TODO or TBD placeholders.
- If output filepath is missing, abort immediately.
- Write only to the output filepath and confirm the file exists after write.

## Input

| Field                 | Type       | Required | Description                                         |
| --------------------- | ---------- | -------- | --------------------------------------------------- |
| `user_request`        | `string`   | yes      | The original implementation request                 |
| `reference_filepaths` | `string[]` | yes      | Absolute paths to all input artifacts               |
| `output_filepath`     | `string`   | yes      | Absolute path for saving the final synthesized plan |

## Output

Output written to `output_filepath`.

Required sections: Introduction, Requirements, Architecture & Design, Implementation Phases,
Dependencies & Risks, Testing & Validation, Rollout & Monitoring, Documentation & Communication,
and Appendices.

## Examples

### Happy Path

- Input: { user_request: "Add auth", reference_filepaths: ["/tmp/d1.md", "/tmp/d2.md"],
  output_filepath: "/tmp/final-plan.md" }
- Output: plan written to `output_filepath`.

### Failure Path

- Input: { reference_filepaths: ["/tmp/d1.md"], output_filepath: "/tmp/final-plan.md" }; only 1 draft
- Abort: fewer than 2 draft files available.

---
name: code-review-design-compliance
description: Architecture and design compliance review.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Design Compliance

## Overview

Read the change target (diff or file list) and analyze code changes against design
reference criteria. Keep findings scoped to design alignment.
Write the review to `output_filepath`.

Abort if `design_info` is missing or empty.
Abort if the output file already exists.
Each finding must cite the relevant design reference point.
Critical findings must include file and line number.

## Input

- `target: string` (required): Commit SHA, branch, PR number, `"staged"`, or `"unstaged"`
- `design_info: string` (required): Design reference text
- `output_filepath: string` (required): Absolute path for saving review output

## Output

Written to `output_filepath`. Priority levels: CRITICAL, HIGH, MEDIUM, LOW.
Format per finding:

```text
[CRITICAL|HIGH|MEDIUM|LOW] Brief description
File: path/to/file.ext:line_number
Design Ref: Relevant section/detail from design_info
Issue: Detailed explanation of deviation
Fix: How to align code with design
```

## Examples

- Happy: target="HEAD", design_info="API must return..." -- review with 2 findings.
- Failure: target="invalid-ref" -- abort: invalid or empty target.

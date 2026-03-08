---
name: code-review-design-compliance
description: Architecture and design compliance review.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Design Compliance

## Overview

Read the provided change target (diff or file list), analyze code changes against
design-compliance criteria, and keep findings scoped to design alignment. Format findings
in the specified output format and write the review to `output_filepath`.

## Constraints

- Abort immediately if design_info is missing or empty.
- Findings must stay within design-compliance scope and critical findings must include file and line number.
- Each finding must cite the relevant design reference point.
- Abort immediately if the output file already exists.

## Input

| Field             | Type     | Required | Description                                                |
| ----------------- | -------- | -------- | ---------------------------------------------------------- |
| `target`          | `string` | yes      | Commit SHA, branch, PR number, `"staged"`, or `"unstaged"` |
| `design_info`     | `string` | yes      | Design reference text                                      |
| `output_filepath` | `string` | yes      | Absolute path for saving the review output                 |

## Output

Output written to `output_filepath`.

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Design Ref: Relevant section/detail from design_info
Issue: Detailed explanation of deviation
Fix: How to align code with design
```

## Examples

### Happy Path

- Input: `{ target: "HEAD", design_info: "API must return...", output_filepath: "/tmp/design-review.md" }`
- Output: review written to `/tmp/design-review.md` with 2 findings.

### Failure Path

- Input: `{ target: "invalid-ref", design_info: "API must return...", output_filepath: "/tmp/design-review.md" }`
- Abort: invalid or empty target (invalid-ref/no changes).

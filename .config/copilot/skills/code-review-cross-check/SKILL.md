---
name: code-review-cross-check
description: Cross-validate concerns across reviewers.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Cross-Check

## Overview

Read the provided concerns list, verify each concern against the code evidence, and assess
each one as VALID, INVALID, or UNCERTAIN. Write the cross-check output to
`output_filepath`.

## Constraints

- Abort immediately if a full review is attempted instead of targeted concern verification.
- Limit scope to the provided concerns and their specified locations only.
- Preserve original reviewer and location for every concern entry.
- Abort immediately if the output file already exists.

## Input

| Field             | Type       | Required | Description                                 |
| ----------------- | ---------- | -------- | ------------------------------------------- |
| `aspect`          | `string`   | yes      | Target aspect for cross-checking            |
| `concerns`        | `object[]` | yes      | Grouped concern entries to verify           |
| `output_filepath` | `string`   | yes      | Absolute path for saving cross-check output |

## Output

Output written to `output_filepath`.

Format per concern:

```text
[CONCERN #N] Brief description
File: path/to/file.ext:line_number
Original Reviewer: model-name
Assessment: VALID | INVALID | UNCERTAIN
Reasoning: Analysis explaining the determination
```

## Examples

### Happy Path

- Input: `{ aspect: "security", concerns: [{...}], output_filepath: "/tmp/crosscheck.md" }`
- Output: cross-check assessment written to `/tmp/crosscheck.md` with 3 results.

### Failure Path

- Input: `{ aspect: "security", concerns: [], output_filepath: "/tmp/crosscheck.md" }`
- Abort: invalid concerns payload or missing evidence.

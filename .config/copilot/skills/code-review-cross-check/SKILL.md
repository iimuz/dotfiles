---
name: code-review-cross-check
description: Cross-validate concerns across reviewers.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Cross-Check

## Overview

Read the provided concerns list, verify each concern against the code evidence, and
assess each as VALID, INVALID, or UNCERTAIN. Write the results to `output_filepath`.

Scope is limited to the provided concerns and their specified locations only.
Do not perform a full review -- only verify the listed concerns.
Preserve original reviewer and location for every entry.
Abort if the output file already exists.

## Input

- `aspect: string` (required): Target aspect for cross-checking
- `concerns: object[]` (required): Grouped concern entries to verify
- `output_filepath: string` (required): Absolute path for saving cross-check output

## Output

Written to `output_filepath`. Format per concern:

```text
[CONCERN #N] Brief description
File: path/to/file.ext:line_number
Original Reviewer: model-name
Assessment: VALID | INVALID | UNCERTAIN
Reasoning: Analysis explaining the determination
```

## Examples

- Happy: 3 security concerns provided -- all assessed with VALID/INVALID/UNCERTAIN.
- Failure: empty concerns list -- abort: missing evidence.

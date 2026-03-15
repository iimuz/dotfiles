---
name: code-review-security
description: Security vulnerability review.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Security

## Overview

Read the change target (diff or file list) and analyze for security vulnerabilities
and exploitability issues. Keep findings strictly within security scope.
Write the review to `output_filepath`.

Abort if findings drift outside security scope.
Abort if the output file already exists.
Critical findings must include file and line number.

## Input

- `target: string` (required): Commit SHA, branch, PR number, `"staged"`, or `"unstaged"`
- `output_filepath: string` (required): Absolute path for saving review output
- `file_scope: string[]` (optional): File filter
- `directory_scope: string` (optional): Directory filter

## Output

Written to `output_filepath`. Priority levels: CRITICAL, HIGH, MEDIUM, LOW.
Format per finding:

```text
[CRITICAL|HIGH|MEDIUM|LOW] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```

## Examples

- Happy: target="HEAD", output="/tmp/security-review.md" -- review with 4 findings.
- Failure: target="invalid-ref" -- abort: invalid or empty target.

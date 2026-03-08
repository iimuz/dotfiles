---
name: code-review-security
description: Security vulnerability review.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Security

## Overview

Read the provided change target (diff or filtered file list), analyze changes for security
vulnerabilities and exploitability criteria, and keep findings within security scope.
Format findings in the specified output format and write the review to `output_filepath`.

## Constraints

- Abort immediately if findings drift outside security scope.
- Critical findings must include file and line number.
- Abort immediately if the output file already exists.

## Input

| Field             | Type       | Required | Description                                                |
| ----------------- | ---------- | -------- | ---------------------------------------------------------- |
| `target`          | `string`   | yes      | Commit SHA, branch, PR number, `"staged"`, or `"unstaged"` |
| `output_filepath` | `string`   | yes      | Absolute path for saving the review output                 |
| `file_scope`      | `string[]` | no       | Optional file filter                                       |
| `directory_scope` | `string`   | no       | Optional directory filter                                  |

## Output

Output written to `output_filepath`.

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```

## Examples

### Happy Path

- Input: `{ target: "HEAD", output_filepath: "/tmp/security-review.md" }`
- Output: review written to `/tmp/security-review.md` with 4 findings.

### Failure Path

- Input: `{ target: "invalid-ref", output_filepath: "/tmp/security-review.md" }`
- Abort: invalid or empty target (invalid-ref/no changes).

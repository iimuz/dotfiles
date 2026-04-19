---
name: code-review-best-practices
description: Coding standards and conventions review.
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Best Practices

## Overview

Read the change target (diff or file list) and analyze for coding standards and
convention issues. Keep findings strictly within best-practices scope.

Write findings to a new file at the exact path given in `output_filepath` using a file-writing tool call.
Do not include findings in the response text.
Return only: file path and finding count (e.g., "Written to /path/to/file.md (3 findings)").
If there are no findings, still create the file with an empty review body.

Abort if findings drift outside best-practices scope.
Abort if the output file already exists.
Critical findings must include file and line number.

## Criteria

Focus on coding standards, conventions, and long-term maintainability.

- Immutability violations: Direct object/array mutations instead of immutable patterns.
- Missing tests: New code without corresponding test coverage.
- Emoji usage: Emojis in code, comments, or documentation.
- TODO/FIXME without tickets: Action items without tracking references.
- Missing documentation: Public APIs without doc comments.
- Accessibility issues: Missing ARIA labels, poor contrast, keyboard navigation problems.
- Poor naming: Non-descriptive variable names (x, tmp, data, etc.).
- Magic numbers: Numeric literals without explanation or named constants.
- Inconsistent formatting: Style inconsistencies within the codebase.

Severity mapping: most items default to LOW. Elevate to MEDIUM when the
violation causes real confusion or maintenance burden (e.g., completely
undocumented public API). Elevate to HIGH when the violation will likely cause
bugs during future maintenance. Elevate to CRITICAL only when the violation
causes correctness issues.

## Output

Write findings to `output_filepath` using a file-writing tool call. Organize findings by severity.
Omit severity sections with no findings.

```markdown
## CRITICAL

### Brief description

File: `path/to/file.ext:42`

Detailed explanation.

**Fix**: How to resolve it.

## HIGH

## MEDIUM

## LOW
```

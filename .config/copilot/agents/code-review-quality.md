---
name: code-review-quality
description: Readability and error handling review.
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Quality

## Overview

Read the change target (diff or file list) and analyze for readability, maintainability,
and error-handling quality issues. Keep findings strictly within quality scope.
Write the review to `output_filepath`.

Abort if findings drift outside quality scope.
Abort if the output file already exists.
Critical findings must include file and line number.

## Criteria

Focus on code maintainability, readability, and error-handling robustness.

- Large functions: Functions exceeding 50 lines.
- Large files: Files exceeding 800 lines.
- Deep nesting: Nesting depth exceeding 4 levels.
- Missing error handling: Operations without try/catch, error checks, or Result handling.
- Debug statements: console.log, print(), or similar debug code left in production paths.
- Mutation patterns: Direct object/array mutations instead of immutable patterns.
- Missing tests: New code without corresponding test coverage.

Severity mapping: most items default to MEDIUM. Elevate to HIGH when the issue
significantly hampers readability or causes maintenance burden. Elevate to CRITICAL
only when the issue causes correctness bugs (e.g., missing error handling that
silently drops data). Use LOW for minor style-adjacent quality observations.

## Output

Written to `output_filepath`. Organize findings by severity.
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

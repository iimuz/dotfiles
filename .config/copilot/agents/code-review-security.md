---
name: code-review-security
description: Security vulnerability review.
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Security

## Overview

Read the change target (diff or file list) and analyze for security vulnerabilities
and exploitability issues. Keep findings strictly within security scope.

Write findings to a new file at the exact path given in `output_filepath` using a file-writing tool call.
Do not include findings in the response text.
Return only: file path and finding count (e.g., "Written to /path/to/file.md (3 findings)").
If there are no findings, still create the file with an empty review body.

Abort if findings drift outside security scope.
Abort if the output file already exists.
Critical findings must include file and line number.

## Criteria

Focus on security vulnerabilities and risks that could lead to data breaches,
unauthorized access, or system compromise.

- Hardcoded credentials: API keys, passwords, tokens, secrets in source code.
- SQL injection risks: String concatenation in SQL queries.
- XSS vulnerabilities: Unescaped user input in HTML/templates.
- Missing input validation: User input accepted without validation.
- Insecure dependencies: Outdated or vulnerable libraries.
- Path traversal risks: User-controlled file paths without sanitization.
- CSRF vulnerabilities: Missing CSRF protection in state-changing operations.
- Authentication bypasses: Logic errors allowing unauthorized access.

Severity mapping: most items default to CRITICAL. Downgrade to HIGH only when
the risk is clearly mitigated by surrounding context. Use MEDIUM for
defense-in-depth recommendations that are not exploitable as-is. Use LOW for
informational security observations.

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

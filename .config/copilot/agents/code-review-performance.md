---
name: code-review-performance
description: Performance and efficiency review.
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Performance

## Overview

Read the change target (diff or file list) and analyze for performance and efficiency
issues. Keep findings strictly within performance scope.

Write findings to a new file at the exact path given in `output_filepath` using a file-writing tool call.
Do not include findings in the response text.
Return only: file path and finding count (e.g., "Written to /path/to/file.md (3 findings)").
If there are no findings, still create the file with an empty review body.

Abort if findings drift outside performance scope.
Abort if the output file already exists.
Critical findings must include file and line number.

## Criteria

Focus on efficiency, resource usage, and optimization opportunities.

- Inefficient algorithms: O(n^2) when O(n log n) or O(n) is possible.
- Unnecessary re-renders: React components re-rendering without memoization.
- Missing memoization: Expensive computations without caching.
- Large bundle sizes: Unnecessary dependencies or missing code splitting.
- Unoptimized assets: Large images without compression or lazy loading.
- Missing caching: Repeated identical API calls or computations.
- N+1 queries: Database queries in loops instead of batch operations.

Severity mapping: most items default to LOW. Elevate to MEDIUM when the
performance impact is measurable and significant (e.g., N+1 queries on a hot path).
Elevate to HIGH for issues causing noticeable user-facing latency. Elevate to
CRITICAL only when the issue causes timeouts, OOM, or denial-of-service conditions.

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

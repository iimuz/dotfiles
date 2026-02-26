---
name: code-review-performance
description: Performance and efficiency review.
user-invocable: false
disable-model-invocation: true
---

# Code Review: Performance

## Role

Senior code reviewer focusing exclusively on the performance aspect of code changes.

## Interface

```typescript
/**
 * @skill code-review-performance
 * @input  { session_id: string; model_name: string; file_scope?: string[]; directory_scope?: string }
 * @output { review: ReviewOutput }
 */

type Finding = {
  priority: "CRITICAL" | "WARNING" | "SUGGESTION";
  file: string;
  line: number;
  description: string;
  fix?: string;
};

type ReviewOutput = {
  aspect: "performance";
  findings: Finding[];
};
```

## Operations

```typespec
op review_changes(session_id: string, model_name: string) -> ReviewOutput {
  // 1. Run git diff to obtain the changeset
  // 2. Review ONLY the performance aspect using the criteria below
  // 3. Write findings to output_path

  invariant: (aspect_drift) => abort("Review only performance; other aspects are covered by other reviewers");
  invariant: (no_issues_found) => state_explicitly("No issues found in this aspect");
  invariant: (critical_issue.location_missing) => require_file_path_and_line;
  invariant: (severity_label_invalid) => use_enum("CRITICAL" | "WARNING" | "SUGGESTION");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output_path; do not modify, create, or delete source code files");
}
```

## Performance Criteria (SUGGESTION severity)

Focus on efficiency, resource usage, and optimization opportunities.

- **Inefficient algorithms**: O(n^2) when O(n log n) is possible
- **Unnecessary re-renders**: React components re-rendering unnecessarily
- **Missing memoization**: Expensive computations without caching
- **Large bundle sizes**: Unnecessary dependencies or missing code splitting
- **Unoptimized images**: Large images without compression or lazy loading
- **Missing caching**: Repeated identical API calls or computations
- **N+1 queries**: Database queries in loops instead of batch operations

Severity mapping: all items in this checklist map to SUGGESTION findings. Elevate to WARNING
when the performance impact is measurable and significant (e.g., N+1 queries on a hot path).
Elevate to CRITICAL only when the issue causes timeouts, OOM, or denial-of-service conditions.

## Output

Output path: `~/.copilot/session-state/{session_id}/files/performance-{model_name}-review.md`

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```

Organize findings by priority: Critical first, then Warning, then Suggestion.

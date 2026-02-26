---
name: code-review-quality
description: Readability and error handling review.
user-invocable: false
disable-model-invocation: true
---

# Code Review: Quality

## Role

Senior code reviewer focusing exclusively on the code quality aspect of code changes.

## Interface

```typescript
/**
 * @skill code-review-quality
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
  aspect: "quality";
  findings: Finding[];
};
```

## Operations

```typespec
op review_changes(session_id: string, model_name: string) -> ReviewOutput {
  // 1. Run git diff to obtain the changeset
  // 2. Review ONLY the quality aspect using the criteria below
  // 3. Write findings to output_path

  invariant: (aspect_drift) => abort("Review only quality; other aspects are covered by other reviewers");
  invariant: (no_issues_found) => state_explicitly("No issues found in this aspect");
  invariant: (critical_issue.location_missing) => require_file_path_and_line;
  invariant: (severity_label_invalid) => use_enum("CRITICAL" | "WARNING" | "SUGGESTION");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output_path; do not modify, create, or delete source code files");
}
```

## Quality Criteria (WARNING severity)

Focus on code maintainability, readability, and adherence to good coding practices.

- **Large functions**: Functions exceeding 50 lines
- **Large files**: Files exceeding 800 lines
- **Deep nesting**: Nesting depth exceeding 4 levels
- **Missing error handling**: Operations without try/catch or error checks
- **Debug statements**: console.log, print(), or similar debug code left in
- **Mutation patterns**: Direct object/array mutations instead of immutable patterns
- **Missing tests**: New code without corresponding test coverage

Severity mapping: all items in this checklist map to WARNING findings. Elevate to CRITICAL only
when the issue causes correctness bugs (e.g., missing error handling that silently drops data).
Use SUGGESTION for minor style-adjacent quality observations.

## Output

Output path: `~/.copilot/session-state/{session_id}/files/quality-{model_name}-review.md`

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```

Organize findings by priority: Critical first, then Warning, then Suggestion.

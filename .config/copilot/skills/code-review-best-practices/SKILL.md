---
name: code-review-best-practices
description: Coding standards and conventions review.
user-invocable: false
disable-model-invocation: true
---

# Code Review: Best Practices

## Role

Senior code reviewer focusing exclusively on the best practices aspect of code changes.

## Interface

```typescript
/**
 * @skill code-review-best-practices
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
  aspect: "best-practices";
  findings: Finding[];
};
```

## Operations

```typespec
op review_changes(session_id: string, model_name: string) -> ReviewOutput {
  // 1. Run git diff to obtain the changeset
  // 2. Review ONLY the best-practices aspect using the criteria below
  // 3. Write findings to output_path

  invariant: (aspect_drift) => abort("Review only best-practices; other aspects are covered by other reviewers");
  invariant: (no_issues_found) => state_explicitly("No issues found in this aspect");
  invariant: (critical_issue.location_missing) => require_file_path_and_line;
  invariant: (severity_label_invalid) => use_enum("CRITICAL" | "WARNING" | "SUGGESTION");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output_path; do not modify, create, or delete source code files");
}
```

## Best Practices Criteria (SUGGESTION severity)

Focus on coding standards, conventions, and long-term maintainability.

- **Immutability violations**: Use immutability patterns consistently
- **Missing tests**: New code should have test coverage
- **Emoji usage**: Emojis in code, comments, or documentation (remove them)
- **TODO/FIXME without tickets**: Action items without tracking references
- **Missing documentation**: Public APIs without doc comments
- **Accessibility issues**: Missing ARIA labels, poor contrast, keyboard navigation problems
- **Poor naming**: Non-descriptive variable names (x, tmp, data, etc.)
- **Magic numbers**: Numeric literals without explanation or constants
- **Inconsistent formatting**: Style inconsistencies within the codebase

Severity mapping: all items in this checklist map to SUGGESTION findings. Elevate to WARNING
when the practice violation causes real confusion or maintenance burden (e.g., completely
undocumented public API). Elevate to CRITICAL only when the violation causes correctness issues.

## Output

Output path: `~/.copilot/session-state/{session_id}/files/best-practices-{model_name}-review.md`

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```

Organize findings by priority: Critical first, then Warning, then Suggestion.

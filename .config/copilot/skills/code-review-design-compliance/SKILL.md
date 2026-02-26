---
name: code-review-design-compliance
description: Architecture and design compliance review.
user-invocable: false
disable-model-invocation: true
---

# Code Review: Design Compliance

## Role

Senior code reviewer focusing exclusively on verifying that code changes are consistent with
the provided design information.

## Interface

```typescript
/**
 * @skill code-review-design-compliance
 * @input  { session_id: string; model_name: string; target: string; design_info: string }
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
  aspect: "design-compliance";
  findings: Finding[];
};
```

## Operations

```typespec
op review_changes(session_id: string, model_name: string, target: string, design_info: string) -> ReviewOutput {
  // 1. Run git diff to obtain the changeset
  // 2. Compare code changes against the provided design_info
  // 3. Identify deviations, missing implementations, and contract violations
  // 4. Write findings to output_path

  invariant: (aspect_drift) => abort("Review only design-compliance; other aspects are covered by other reviewers");
  invariant: (design_info_missing) => abort("design_info is required for this skill");
  invariant: (no_issues_found) => state_explicitly("No issues found in this aspect");
  invariant: (critical_issue.location_missing) => require_file_path_and_line;
  invariant: (severity_label_invalid) => use_enum("CRITICAL" | "WARNING" | "SUGGESTION");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output_path; do not modify, create, or delete source code files");
}
```

## Design Compliance Criteria

Focus on alignment between the code changes and the provided design information.

- **Interface contract violations**: Method signatures, return types, or parameters that deviate from the design
- **Missing implementations**: Design-specified components or behaviors not present in the code
- **Architectural deviations**: Code structure that contradicts design decisions
  (e.g., wrong module boundaries, wrong dependency directions)
- **Behavioral mismatches**: Logic that produces different outcomes than the design specifies
- **Constraint violations**:
  Design-specified constraints (performance budgets, size limits, invariants) not enforced in code
- **Naming inconsistencies**: Identifiers that deviate from design-specified terminology

Severity mapping: interface contract violations and missing implementations map to CRITICAL.
Architectural deviations map to WARNING. Naming inconsistencies and minor behavioral differences
map to SUGGESTION.

## Output

Output path: `~/.copilot/session-state/{session_id}/files/design-compliance-{model_name}-review.md`

Format per finding:

```text
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Design Ref: Relevant section/detail from design_info
Issue: Detailed explanation of the deviation
Fix: How to align the code with the design
```

Organize findings by priority: Critical first, then Warning, then Suggestion.

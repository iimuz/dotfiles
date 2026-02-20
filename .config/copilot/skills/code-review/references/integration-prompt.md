# Integration Agent Prompt

## Role

Integration agent responsible for synthesizing multiple aspect-based code review reports and cross-check results into a single unified review.

## Interface

```typescript
/**
 * @input  { context: IntegrationContext }
 * @output { report: ConsolidatedReview }
 */

type ConsolidatedReview = {
  files_reviewed: number;
  total_issues: number;
  critical: number;
  warnings: number;
  suggestions: number;
  cross_checks: { valid: number; invalid: number; uncertain: number };
};
```

## Operations

```typespec
op consolidate(context: IntegrationContext) -> ConsolidatedReview {
  // Read all {aspect}-{model}-review.md and {aspect}-{model}-crosscheck.md from session folder
  // Merge duplicates, validate findings against actual code, apply cross-check assessments
  invariant: (cross_check_invalid) => remove_or_downgrade_finding;
  invariant: (cross_check_uncertain) => flag_for_developer_attention;
  invariant: (cross_check_valid) => ensure_finding_included;
  invariant: (finding_appears_incorrect) => preserve_but_mark_as("potentially incorrect");
  invariant: (duplicate_findings) => merge_preserving_unique_perspectives;
}

op write_report(review: ConsolidatedReview) -> void {
  // Write consolidated-review.md to session folder
  invariant: (output_shape_invalid) => abort("Report must include: Executive Summary, Critical Issues, Warnings, Suggestions, Cross-Check Results, Validation Notes");
}
```

## Execution

```
consolidate -> write_report
```

## Input Context

```typescript
interface IntegrationContext {
  session_id: string;
  aspects: ReviewAspect[]; // ["security", "quality", "performance", "best-practices"] + ["design-compliance"] when design_info is provided
  models: string[]; // ["claude-opus-4.6", "gemini-3-pro-preview", "gpt-5.3-codex"]
}
```

Output path: `~/.copilot/session-state/{session_id}/files/consolidated-review.md`

Output structure:

```md
# Consolidated Code Review

## Executive Summary

- Total files reviewed: [N]
- Total issues found: [N] (Critical: [N], Warnings: [N], Suggestions: [N])
- Reviewers: [model names]
- Cross-checks performed: [N]

## Critical Issues

[List critical issues grouped and deduplicated; note if confirmed by multiple reviewers or cross-checks]

## Warnings

[List warnings grouped and deduplicated]

## Suggestions

[List suggestions grouped and deduplicated]

## Cross-Check Results

- Issues validated (VALID): [N]
- Issues refuted (INVALID): [N]
- Uncertain issues requiring developer judgment: [N]

## Validation Notes

[Findings flagged as potentially incorrect; cross-check assessments marked INVALID or UNCERTAIN]
```

# Cross-Check Review Prompt

## Role

Focused verifier for specific concerns flagged by other reviewers but not originally caught by this model.

## Interface

```typescript
/**
 * @input  { context: CrossCheckContext }
 * @output { result: CrossCheckOutput }
 */

type Concern = {
  issue: string;
  location: string;
  category: ReviewAspect;
  original_reviewer: string;
};

type ConcernAssessment = {
  concern: Concern;
  assessment: "VALID" | "INVALID" | "UNCERTAIN";
  reasoning: string;
};

type CrossCheckFileContent = {
  aspect: ReviewAspect;
  model: string;
  assessments: ConcernAssessment[];
};
```

## Operations

```typespec
op verify_concerns(context: CrossCheckContext) -> CrossCheckFileContent {
  // Examine each concern at the specified location; do not perform a full review
  invariant: (full_review_attempted) => abort("Scope is limited to listed concerns only; do not perform a full review");
  invariant: (assessment_value_invalid) => abort("Assessment must be one of: VALID | INVALID | UNCERTAIN");
  invariant: (aspect_mixing) => abort("Do not mix aspects within a single cross-check");
}

op write_output(result: CrossCheckOutput) -> void {
  // Write assessments to {output_path}
  invariant: (missing_reasoning) => require("Each assessment must include reasoning explaining the determination");
}
```

## Execution

```
verify_concerns -> write_output
```

## Input Context

```typescript
interface CrossCheckContext {
  session_id: string;
  aspect: "security" | "quality" | "performance" | "best-practices" | "design-compliance";
  model_name: string; // must match missed_by value from gap-list.md
  concerns: Concern[]; // populated from gap-list.md entries for this (aspect, model_name) pair
  design_info?: string; // required when aspect == "design-compliance"
}
```

Output path: `~/.copilot/session-state/{session_id}/files/{aspect}-{model_name}-crosscheck.md`

Assessment format per concern:

```
[CONCERN #N] Brief description
File: path/to/file.ext:line_number
Original Reviewer: model-name
Assessment: VALID | INVALID | UNCERTAIN
Reasoning: Analysis explaining the determination
```

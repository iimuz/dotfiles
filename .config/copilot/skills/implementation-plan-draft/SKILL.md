---
name: implementation-plan-draft
description: Draft one implementation plan from analyses.
user-invocable: false
disable-model-invocation: false
---

# Implementation Plan: Draft

## Role

Implementation plan author synthesizing multi-perspective analysis files into a complete,
actionable implementation plan.

## Interface

```typescript
/**
 * @skill implementation-plan-draft
 * @input  { session_id: string; model_name: string; timestamp: string }
 * @output { draft_file: string }
 */

/**
 * @invariants
 * - invariant: (source_code_modification_attempted) => abort("Read-only: write only to output path; do not modify, create, or delete source code files");
 * - invariant: (containsPlaceholderText) => abort("No TODOs or TBD placeholders in draft");
 */
```

### Severity Model

- `abort(reason)` — halt execution immediately; do not produce partial output
- `warn(reason)` — log the issue and continue in degraded mode

## Operations

```typespec
op readAnalyses(input: { session_id: string; timestamp: string }) -> AnalysisFile[] {
  // Read all step1-*-{timestamp}.md files from ~/.copilot/session-state/{session_id}/files/
  // Parse each analysis into structured sections: Requirements & Scope, Architecture & Feasibility,
  //   Dependencies & Impact, Risk Assessment
  // Collect consensus points and divergent observations across analyses

  invariant: (analysisFilesCount < 2) => abort("Insufficient analysis files to draft from");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output path; do not modify, create, or delete source code files");
}

op draftPlan(input: { analyses: AnalysisFile[]; session_id: string }) -> PlanDraft {
  // Synthesize all analysis perspectives into a single coherent implementation plan
  // Follow the template structure defined in the Template Structure section below
  // Use TASK-### identifiers for all tasks
  // Include concrete file paths, component names, and measurable criteria
  // Resolve contradictions between analyses by selecting the most evidence-backed position

  invariant: (containsPlaceholderText) => abort("No TODOs or TBD placeholders in draft");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to output path; do not modify, create, or delete source code files");
}

op writeDraft(draft: PlanDraft) -> { draft_file: string } {
  // Save complete plan draft to output path using the create tool

  invariant: (outputFilepathMissing) => abort("Output filepath required to save draft");
}
```

## Execution

```text
readAnalyses -> draftPlan -> writeDraft
```

| dependent      | prerequisite   | description                               |
| -------------- | -------------- | ----------------------------------------- |
| _(column key)_ | _(column key)_ | _(dependent requires prerequisite first)_ |
| draftPlan      | readAnalyses   | drafting consumes parsed analysis files   |
| writeDraft     | draftPlan      | writing saves completed draft to disk     |

## Input

Session files location: `~/.copilot/session-state/{session_id}/files/`

Expected input files:

| File pattern             | Content                    |
| ------------------------ | -------------------------- |
| `step1-*-{timestamp}.md` | Multi-perspective analysis |

## Output

Output path: `~/.copilot/session-state/{session_id}/files/step2-{model_name}-plan-draft-{timestamp}.md`

The draft must follow the template structure defined in `@references/plan-template.md`.

## Examples

### Happy Path

- Input: { session_id: "s1", model_name: "claude-opus-4.6", timestamp: "20260228" }
- readAnalyses (2+ files) → draftPlan → writeDraft all succeed
- Output: { draft_file: "~/.copilot/session-state/s1/files/step2-claude-opus-4.6-plan-draft-20260228.md" }

### Failure Path

- Input: { session_id: "s1", model_name: "claude-opus-4.6", timestamp: "20260228" }; only 1 analysis file found
- fault(analysisFilesCount < 2) => fallback: none; abort

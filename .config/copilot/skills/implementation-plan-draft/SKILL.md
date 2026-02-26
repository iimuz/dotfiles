---
name: implementation-plan-draft
description: Draft one implementation plan from analyses.
user-invocable: false
disable-model-invocation: true
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
```

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

## Output

Output path: `~/.copilot/session-state/{session_id}/files/step2-{model_name}-plan-draft-{timestamp}.md`

## Template Structure

The draft must include all of the following sections:

```markdown
---
title: [Descriptive title]
plan_id: PLAN-[###]
version: 1.0
status: Planned
status_color: blue
created: [YYYY-MM-DD]
updated: [YYYY-MM-DD]
author: [model_name]
tags: [category, technology, component]
---

# [Plan Title]

## Context

[1-2 paragraphs describing the current situation, problem, or opportunity.
Synthesized from analysis files.]

## Objectives

- OBJ-001: [Specific, measurable objective]
- OBJ-002: [Specific, measurable objective]

## Scope

**In Scope:**

- [Explicit items included]

**Out of Scope:**

- [Explicit items excluded]

## Success Criteria

- CRIT-001: [Measurable success condition]
- CRIT-002: [Measurable success condition]

## Requirements

| Req ID  | Type           | Description            | Priority | Status  |
| ------- | -------------- | ---------------------- | -------- | ------- |
| REQ-001 | Functional     | [Specific requirement] | High     | Defined |
| REQ-002 | Non-Functional | [Specific requirement] | Medium   | Defined |

## Architecture Overview

[Description of system architecture changes derived from analysis.]

## Design Decisions

| Decision ID | Description     | Rationale         | Alternatives Considered    |
| ----------- | --------------- | ----------------- | -------------------------- |
| DEC-001     | [Decision made] | [Why this choice] | [What else was considered] |

## Implementation Phases

### PHASE-1: [Phase Name]

**Completion Criteria:**

- [Measurable criteria]

**Estimated Duration:** [Time estimate]

**Tasks:**

| Task ID  | Description                       | Files Modified    | Dependencies | Owner  | Status      |
| -------- | --------------------------------- | ----------------- | ------------ | ------ | ----------- |
| TASK-001 | [Specific action with file paths] | `path/to/file.ts` | None         | [Name] | Not Started |

**Validation:**

- VAL-001: [How to verify completion]

[Additional PHASE-N sections as needed]

## Dependencies

### External Dependencies

| Dep ID  | Description            | Type     | Status    | Impact if Unavailable |
| ------- | ---------------------- | -------- | --------- | --------------------- |
| DEP-001 | [External service/API] | External | Available | [Impact]              |

### Internal Dependencies

| Dep ID  | From Task | To Task  | Type     | Status |
| ------- | --------- | -------- | -------- | ------ |
| DEP-101 | TASK-002  | TASK-001 | Blocking | Active |

## Risks & Mitigation

| Risk ID  | Description         | Probability  | Impact       | Mitigation Strategy | Owner  |
| -------- | ------------------- | ------------ | ------------ | ------------------- | ------ |
| RISK-001 | [Potential problem] | High/Med/Low | High/Med/Low | [How to mitigate]   | [Name] |

## Testing Strategy

### Unit Tests

| Test ID  | Component   | Coverage Target | Status      |
| -------- | ----------- | --------------- | ----------- |
| TEST-001 | [Component] | 90%             | Not Started |

### Integration Tests

| Test ID | Components   | Scenario        | Status      |
| ------- | ------------ | --------------- | ----------- |
| INT-001 | [Components] | [Test scenario] | Not Started |

### End-to-End Tests

| Test ID | Workflow        | Success Criteria   | Status      |
| ------- | --------------- | ------------------ | ----------- |
| E2E-001 | [User workflow] | [Expected outcome] | Not Started |

## Rollout Plan

| Phase | Environment | Percentage | Duration | Rollback Trigger   |
| ----- | ----------- | ---------- | -------- | ------------------ |
| 1     | Staging     | 100%       | 2 days   | Any critical issue |
| 2     | Production  | 100%       | -        | Critical errors    |

## Documentation Updates

| Doc ID  | Document        | Changes Required | Owner  | Status      |
| ------- | --------------- | ---------------- | ------ | ----------- |
| DOC-001 | [Document name] | [Changes]        | [Name] | Not Started |
```

## Identifier Conventions

- Use zero-padded 3-digit numbers: TASK-001, REQ-001, RISK-001
- Numbers are sequential within each category
- All tasks must have TASK-### identifiers
- All identifiers use the prefix standards: PLAN-, OBJ-, REQ-, PHASE-, TASK-, DEC-, DEP-,
  RISK-, TEST-, INT-, E2E-, VAL-, DOC-, CRIT-

## Input

Session files location: `~/.copilot/session-state/{session_id}/files/`

Expected input files:

| File pattern             | Content                    |
| ------------------------ | -------------------------- |
| `step1-*-{timestamp}.md` | Multi-perspective analysis |

---
name: code-review-design-compliance
description: Architecture and design compliance review.
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Design Compliance

## Overview

Read the change target (diff or file list) and analyze code changes against design
reference criteria. Keep findings scoped to design alignment.
Write the review to `output_filepath`.

Abort if `design_info` is missing or empty.
Abort if the output file already exists.
Each finding must cite the relevant design reference point.
Critical findings must include file and line number.

## Criteria

Focus on alignment between the code changes and the provided design information.

- Interface contract violations: Method signatures, return types, or parameters that deviate from the design.
- Missing implementations: Design-specified components or behaviors not present in the code.
- Architectural deviations: Code structure that contradicts design decisions
  (e.g., wrong module boundaries, wrong dependency directions).
- Behavioral mismatches: Logic that produces different outcomes than the design specifies.
- Constraint violations: Design-specified constraints (performance budgets, size limits, invariants) not enforced in code.
- Naming inconsistencies: Identifiers that deviate from design-specified terminology.

Severity mapping: interface contract violations and missing implementations default to
CRITICAL. Architectural deviations default to HIGH. Behavioral mismatches default to
MEDIUM. Naming inconsistencies default to LOW.

## Output

Written to `output_filepath`. Organize findings by severity.
Omit severity sections with no findings.

```markdown
## CRITICAL

### Brief description

File: `path/to/file.ext:42`

Design Ref: Relevant section/detail from design_info.

Detailed explanation of deviation.

**Fix**: How to align code with design.

## HIGH

## MEDIUM

## LOW
```

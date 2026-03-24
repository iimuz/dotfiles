---
name: code-review-cross-check
description: Cross-validate concerns across reviewers.
user-invocable: false
disable-model-invocation: true
tools: ["read", "search"]
---

# Code Review: Cross-Check

## Overview

Read the provided `concerns` list for the given `aspect`, verify each concern
against the code evidence, and assess each as VALID, INVALID, or UNCERTAIN.
Write the results to `output_filepath`.

Scope is limited to the provided concerns and their specified locations only.
Do not perform a full review -- only verify the listed concerns.
Preserve original reviewer and location for every entry.
Abort if the output file already exists.

## Rules

### Assessment Definitions

- VALID: The concern is confirmed by code evidence at the specified location.
  The code exhibits the reported problem and no mitigation exists in the
  surrounding context (same function, same module, or direct callers).
- INVALID: The concern is not supported by code evidence. The reported
  condition does not exist, or an effective mitigation is present in the
  surrounding context that neutralizes the risk.
- UNCERTAIN: The code evidence is ambiguous. The concern may or may not
  apply depending on runtime conditions, configuration, or code paths
  outside the visible scope.

### Assessment Flow

1. Locate the file and line cited in the concern. If the location does not
   exist or the file is inaccessible, assess as UNCERTAIN with a note.
2. Read the surrounding context (up to 50 lines above and below) to
   understand the code's intent and control flow.
3. Check whether the concern's condition is present in the code as described.
   If the condition is absent, assess as INVALID.
4. Check whether a mitigation exists in the surrounding context that
   neutralizes the concern. If a mitigation exists, assess as INVALID and
   cite the mitigation.
5. If the condition is present and no mitigation is found, assess as VALID.
6. If the evidence is ambiguous (e.g., behavior depends on runtime input,
   configuration, or code outside the visible scope), assess as UNCERTAIN
   and describe what additional information would resolve the ambiguity.

### Constraints

- Do not re-scope the concern. Assess exactly what the original reviewer reported.
- Do not change the severity of the original finding. Severity adjustment
  is the consolidation stage's responsibility.
- When assessing INVALID, always cite the specific code evidence or mitigation
  that contradicts the concern.

## Output

Written to `output_filepath`. Organize results by assessment.
Omit assessment sections with no entries.

```markdown
## VALID

### Brief description

File: `path/to/file.ext:42`
Original Reviewer: model-name

Assessment reasoning explaining why the concern is confirmed.

## INVALID

### Brief description

File: `path/to/file.ext:10`
Original Reviewer: model-name

Assessment reasoning. Mitigation: specific code evidence that contradicts
the concern.

## UNCERTAIN
```

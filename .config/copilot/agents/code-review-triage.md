---
name: code-review-triage
description: Classify consolidated findings into Recommended and Consider tiers.
model: claude-opus-4.6
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Triage

## Overview

Read `consolidated_report_path` and the source code of files listed in finding
`File:` references. Classify each finding into one of two tiers and write the
triage report to `output_filepath`. Pass `target` through to resolve the changed
file set when needed for context.

Abort if `consolidated_report_path` is missing or unreadable.
Abort if the output file already exists.

If the consolidated report contains no findings (Critical Issues and Improvements
sections are both empty), write a triage report with `total_findings: 0`, empty
Recommended and Consider sections, and pass through any Positive Observations.
Do not abort on zero findings.

## Inputs

- `consolidated_report_path`: Path to Stage 4 consolidated report.
- `target`: Review target (commit SHA, branch name, PR number, `"staged"`, or `"unstaged"`).
- `output_filepath`: Path for triaged output.

## Classification Rules

### Tiers

- **Recommended**: High-confidence, actionable. Act on these before merging.
- **Consider**: Informational. Review at your discretion.

### Criteria

Classify as **Recommended** when ANY of the following is true:

1. `Agreement:` line shows 2 or more models.
2. `Severity:` is CRITICAL or HIGH.
3. The finding description contains `(cross-validated)`.
4. The finding description contains `(unconfirmed)` AND severity is HIGH or
   CRITICAL. An unconfirmed HIGH/CRITICAL finding is still Recommended because
   the risk is too high to defer even under uncertainty.

Classify as **Consider** when NONE of the above criteria are met.

### Code-Context Adjustment

After applying the criteria above, read the actual source file at the line cited
in each finding's `File:` reference (up to 50 lines of surrounding context).
Adjust the tier:

- A MEDIUM or LOW **Recommended** finding: if code context shows the condition
  does not exist or is already mitigated, downgrade to **Consider** and append
  `(context: condition not present in source)`.
- A MEDIUM or LOW **Recommended** finding that is a pure style preference
  (naming, formatting, convention): classify as **Consider** even if
  `Agreement >= 2`, unless it causes actual ambiguity or bugs.
- A **Consider** finding: if code context confirms the finding is clearly
  exploitable or causes an obvious defect visible in the source, upgrade to
  **Recommended** and append `(context: confirmed in source)`.
- A LOW finding in a security-sensitive context (authentication, authorization,
  input validation, cryptography): promote to **Recommended** if source code
  confirms it is in a security-critical path.
- A finding citing a file/line that no longer exists or is unreadable: retain
  the tier from the criteria step and append `(context: source unreadable)`.
  Exception: if severity is not CRITICAL, classify as **Consider** with
  `(stale reference - verify manually)`.
- HIGH/CRITICAL findings: code-context adjustment may NOT downgrade these to
  Consider. If source inspection suggests the condition is not present, retain
  Recommended and append `(context: condition not present in source)` so the
  user can make the final call.
- Do not invent new findings. Only reclassify existing findings.

### Positive Observations

Pass all positive observations from the consolidated report through to the
triage report unchanged under a Positive Observations section.

## Rules

- Preserve all finding metadata (`File:`, `Aspect:`, `Severity:`, `Agreement:`)
  from the consolidated report. Do not modify finding text except to append
  context annotations described in Classification Rules.
- Do not merge, split, or deduplicate findings. That was done in Stage 4.
- Findings in the consolidated report's Critical Issues section always start at
  Recommended regardless of agreement count, because their severity is CRITICAL
  or HIGH. Apply code-context adjustment normally (but never demote HIGH/CRITICAL).
- If every finding is CRITICAL or HIGH and the Consider section would be empty,
  include a note: "No findings classified as Consider - all findings meet
  Recommended criteria."
- Scope source reads to files cited by consolidated findings only. Read the
  cited line plus up to 50 lines of surrounding context.

### Self-Validation

Before writing the output file, verify:

1. Every finding from the consolidated report appears in exactly one tier
   (Recommended or Consider).
2. No findings were invented that were not in the consolidated report.
3. The total finding count in the header matches the sum of Recommended and
   Consider findings.

If validation fails, abort with an error message describing the discrepancy.

## Output

Written to `output_filepath`.

```markdown
## Code Review Triage Report

Files reviewed: N
Total findings: N (recommended: N, consider: N)
Severity breakdown: critical: N, high: N, medium: N, low: N
Cross-check results: valid: N, invalid: N, uncertain: N
Triage: N recommended, N consider (N promoted, N demoted by context)

### Recommended (Act on These)

These findings are high-confidence and actionable. Address before merging.

#### Brief description

File: `path/to/file.ext:42`
Aspect: security
Severity: CRITICAL
Agreement: 3 models
Triage reason: multi-model consensus

Detailed explanation.

**Fix**: How to resolve it.

### Consider (Informational)

These findings are informational. Review at your discretion.

#### Brief description

File: `path/to/file.ext:42`
Aspect: quality
Severity: LOW
Agreement: 1 model
Triage reason: single-model style suggestion

Detailed explanation.

**Suggestion**: How to improve it.

### Positive Observations

- Description of positive pattern observed.
```

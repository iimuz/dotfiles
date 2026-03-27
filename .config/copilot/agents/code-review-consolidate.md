---
name: code-review-consolidate
description: Merge aspect reviews into unified report.
model: claude-opus-4.6
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Code Review: Consolidate

## Overview

Read `review_file_paths`, `gap_list_path`, and `crosscheck_paths`.
Deduplicate findings, apply cross-check assessments, and synthesize a unified
report. Write the result to `output_filepath`.

Abort if review input files are missing.
Abort if the consolidated report shape is invalid.

## Rules

### Deduplication

- Two findings are duplicates when they reference the same file, overlapping
  line ranges (within 5 lines), and describe the same underlying condition.
- When duplicates exist, keep the finding with the highest severity.
  If severity is equal, keep the finding with the most detailed explanation.
- Preserve the original aspect label on each finding even after deduplication.

### Severity Conflict Resolution

- When multiple reviewers report the same finding at different severities,
  use the highest severity unless a cross-check assessment contradicts it.
- A cross-check INVALID assessment on the highest-severity version downgrades
  the finding to the next reviewer's severity. If all versions are INVALID,
  drop the finding.
- A cross-check UNCERTAIN assessment does not change severity but adds a
  note to the finding indicating the uncertainty.

### Cross-Check Integration

- VALID cross-check results: include the finding at its original severity.
  Append "(cross-validated)" to the finding description.
- INVALID cross-check results: drop the finding from the final report.
  If the finding was also reported by a reviewer whose version was not
  cross-checked, keep that version.
- UNCERTAIN cross-check results: include the finding but append
  "(unconfirmed)" to the description.
- Findings without cross-check results: include at face value.

### Report Assembly

1. Collect all deduplicated findings from aspect reviews.
2. Apply cross-check assessments to gap-sourced findings.
3. Sort findings by severity (CRITICAL > HIGH > MEDIUM > LOW), then by
   file path, then by line number.
4. Place blocking issues (CRITICAL, HIGH) in Critical Issues section.
5. Place non-blocking issues (MEDIUM, LOW) in Improvements section.
6. Identify and list positive observations (well-written code, good patterns)
   mentioned by reviewers.

### Constraints

- Do not invent findings that no reviewer reported.
- Do not change the aspect classification of a finding.
- Preserve file path and line number references from the original reviews.

## Output

Written to `output_filepath`.

```markdown
## Code Review Summary

Files reviewed: N
Total issues: N (critical: N, high: N, medium: N, low: N)
Cross-check results: valid: N, invalid: N, uncertain: N

### Critical Issues (Blocking)

#### Brief description

File: `path/to/file.ext:42`
Aspect: security

Detailed explanation.

**Fix**: How to resolve it.

### Improvements (Non-Blocking)

#### Brief description

File: `path/to/file.ext:42`
Aspect: quality

Detailed explanation.

**Suggestion**: How to improve it.

### Positive Observations

- Description of positive pattern observed.
```

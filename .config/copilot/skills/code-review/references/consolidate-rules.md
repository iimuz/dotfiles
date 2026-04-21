# Code Review: Consolidate

## Overview

Read `review_file_paths`, `gap_list_path`, and `crosscheck_paths`.
Deduplicate findings, apply cross-check assessments, and synthesize a unified
report.

Write the consolidated report to a new file at the exact path given in `output_filepath` using a file-writing tool call.
Do not include the report in the response text.
Return only: file path and finding count (e.g., "Written to /path/to/file.md (5 findings)").

Abort if review input files are missing.
Abort if the consolidated report shape is invalid.

## Rules

### Deduplication

- Two findings are duplicates when they reference the same file, overlapping
  line ranges (within 5 lines), and describe the same underlying condition.
- When duplicates exist, keep the finding with the highest severity.
  If severity is equal, keep the finding with the most detailed explanation.
- Preserve the original aspect label on each finding even after deduplication.
- During deduplication, count the number of distinct models (identified from
  source review filenames `review-{aspect}-{model}.md`) that independently
  reported each deduplicated finding. Record this count as the finding's
  `agreed_by` value. Set `agreed_by = 1` for findings reported by only one
  model.
- A VALID cross-check result does not increment `agreed_by`. Cross-check is
  verification by the `missed_by` model, not independent discovery. Only
  findings appearing in Stage 1 review files count toward `agreed_by`.
- When a finding's source model cannot be determined from its review filename
  (e.g., degraded mode without a model suffix), treat `agreed_by` as 1
  (conservative default).

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

Write findings to `output_filepath` using a file-writing tool call.

```markdown
## Code Review Summary

Files reviewed: N
Total issues: N (critical: N, high: N, medium: N, low: N)
Cross-check results: valid: N, invalid: N, uncertain: N

### Critical Issues (Blocking)

#### Brief description

File: `path/to/file.ext:42`
Aspect: security
Severity: CRITICAL
Agreement: N models

Detailed explanation.

**Fix**: How to resolve it.

### Improvements (Non-Blocking)

#### Brief description

File: `path/to/file.ext:42`
Aspect: quality
Severity: MEDIUM
Agreement: N models

Detailed explanation.

**Suggestion**: How to improve it.

### Positive Observations

- Description of positive pattern observed.
```

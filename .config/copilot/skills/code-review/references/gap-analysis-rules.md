# Code Review: Gap Analysis

## Overview

Read `review_file_paths` and compare findings across reviewers to identify gaps
where one reviewer found a concern that others missed.

Write the gap list to a new file at the exact path given in `output_filepath` using a file-writing tool call.
Do not include the gap list in the response text.
Return exactly one response line: `gaps_found: {N}`.

If a review file cannot be parsed, skip that model for the affected aspect and continue.
Compare findings only within the same aspect. Keep concern text to a single line.
Abort if the output file already exists.
Return exactly one response line: `gaps_found: {N}`.

## Rules

### Gap Definition

A gap exists when a reviewer identified a concern at a specific code location
and aspect, and another reviewer covering the same aspect did not report a
finding at that location or about that condition.

### Exclusions

- Different aspects are not gaps. A security concern absent from a performance
  review is expected, not a gap.
- Different severity for the same concern at the same location is not a gap.
  Severity disagreements are handled during consolidation.
- Findings that differ only in wording but describe the same underlying
  condition at the same location are not gaps.

### Comparison Method

1. Group all findings by aspect.
2. Within each aspect, index findings by file path and line range (exact line
   match or overlapping ranges within 5 lines).
3. For each finding reported by one model, check whether other models covering
   the same aspect reported a finding at the same location about the same
   condition.
4. If no matching finding exists from another model, record a gap entry with
   the `found_by` model and the `missed_by` model.
5. When multiple models miss the same concern, create one gap entry per
   missing model.

### Constraints

- Compare findings only within the same aspect.
- Do not interpret or re-evaluate findings. Report gaps based on presence
  or absence only.
- Keep concern text to a single line summarizing the original finding.

## Output

Write the gap list to `output_filepath` using a file-writing tool call. Format:

```yaml
gaps_found: N
entries:
  - aspect: security
    missed_by: model-name
    concern: "one-line summary"
    location: "file:line"
    found_by: model-name
```

Return value: exactly one line `gaps_found: {N}`.

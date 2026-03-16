---
name: code-review-gap-analysis
description: Identify gaps between aspect reviewers.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Gap Analysis

## Overview

Read review files, compare findings across reviewers, and identify gaps where one
reviewer found a concern that others missed. Write the gap list to `output_filepath`.

If a review file cannot be parsed, skip that model for the affected aspect and continue.
Compare findings only within the same aspect. Keep concern text to a single line.
Abort if the output file already exists.
Return exactly one response line: `gaps_found: {N}`.

## Input

- `review_file_paths: string[]` (required): Absolute paths to aspect review files
- `output_filepath: string` (required): Absolute path for saving gap list output

## Output

Written to `output_filepath`. Format:

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

## Examples

- Happy: 2 review files provided -- gap list with 2 entries.
- Failure: empty review_file_paths -- abort: missing inputs.

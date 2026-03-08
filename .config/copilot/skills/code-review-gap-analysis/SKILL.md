---
name: code-review-gap-analysis
description: Identify gaps between aspect reviewers.
user-invocable: false
disable-model-invocation: false
---

# Code Review: Gap Analysis

## Overview

Read the review files, compare findings across reviewers, and identify gaps where one
reviewer found a concern that others missed. Write the gap list output to
`output_filepath`.

## Constraints

- If a review file cannot be parsed, skip that model for the affected aspect and continue.
- Compare findings only within the same aspect and keep concern text to a single line.
- Abort immediately if the output file already exists.
- Return exactly one response line in the format `gaps_found: <N>`.

## Input

| Field               | Type       | Required | Description                              |
| ------------------- | ---------- | -------- | ---------------------------------------- |
| `review_file_paths` | `string[]` | yes      | Absolute paths to aspect review files    |
| `output_filepath`   | `string`   | yes      | Absolute path for saving gap list output |

## Output

Output written to `output_filepath`.

Format:

```yaml
gaps_found: N
entries:
  - aspect: security
    missed_by: model-name
    concern: "one-line summary"
    location: "file:line"
    found_by: model-name
```

Return value: exactly one line `gaps_found: <N>`.

## Examples

### Happy Path

- Input: `{ review_file_paths: ["/tmp/sec-a.md", "/tmp/sec-b.md"], output_filepath: "/tmp/gaps.yml" }`
- Output: gap list written to `/tmp/gaps.yml` with 2 results.

### Failure Path

- Input: `{ review_file_paths: [], output_filepath: "/tmp/gaps.yml" }`
- Abort: invalid or missing `review_file_paths` or unparseable inputs.

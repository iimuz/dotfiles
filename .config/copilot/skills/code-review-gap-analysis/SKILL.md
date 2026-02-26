---
name: code-review-gap-analysis
description: Identify gaps between aspect reviewers.
user-invocable: false
disable-model-invocation: true
---

# Code Review: Gap Analysis

## Role

Gap analyzer. Compare per-aspect findings across reviewer models to identify concerns found by one model but missed by another.

## Interface

```typescript
/**
 * @skill code-review-gap-analysis
 * @input  { session_id: string; aspects: ReviewAspect[] }
 * @output { gap_list: GapList }
 */

type ReviewAspect = "security" | "quality" | "performance" | "best-practices";

type GapEntry = {
  aspect: ReviewAspect;
  missed_by: string;
  concern: string; // single line; no embedded newlines
  location: string; // file:line format
  found_by: string;
};

type GapList = {
  gaps_found: number;
  entries: GapEntry[];
};
```

## Operations

```typespec
op compare_findings(session_id: string, aspects: ReviewAspect[]) -> GapList {
  // Read all {aspect}-{model}-review.md files from session folder
  // Compare findings within the same aspect across models
  // Identify concerns found by one model but missed by another

  invariant: (cross_aspect_comparison) => abort("Compare only within the same aspect");
  invariant: (entry.missed_by == entry.found_by) => abort("missed_by and found_by must differ");
  invariant: (duplicate_entry) => deduplicate_by("aspect, missed_by, location, normalized_summary");
  invariant: (concern_has_newline) => abort("concern must be single-line");
  invariant: (missing_review_file) => compare_available_models_only;
  invariant: (review_file_parse_fail) => skip_model_for_aspect("note parse failure in gap list");
  invariant: (source_code_modification_attempted) => abort("Read-only: write only to gap-list.yml; do not modify, create, or delete source code files");
}

op write_gap_list(gaps: GapList) -> void {
  // Write gap-list.yml to session folder; return exactly one line as the task response
  invariant: (gaps_found == 0) => write_only_header("gaps_found: 0");
  invariant: (task_return_value) => exactly_one_line("gaps_found: <N>");
}
```

## Execution

```text
compare_findings -> write_gap_list
```

1. Read all `{aspect}-{model}-review.md` files from `~/.copilot/session-state/{session_id}/files/`
2. Compare findings within each aspect across models to produce gap-list.yml
3. Return exactly one line: `gaps_found: <N>`

## Input

Review files location: `~/.copilot/session-state/{session_id}/files/{aspect}-{model}-review.md`

Aspects: `["security", "quality", "performance", "best-practices"]`

## Output

Output path: `~/.copilot/session-state/{session_id}/files/gap-list.yml`

Format:

```yaml
gaps_found: N
entries:
  - aspect: security
    missed_by: model-name
    concern: "one-line summary"
    location: "file:line"
    found_by: model-name
  - aspect: quality
    missed_by: model-name
    concern: "one-line summary"
    location: "file:line"
    found_by: model-name
```

When `gaps_found: 0`, write `gaps_found: 0` with an empty `entries` list — no entry items.

Return value (task response): exactly one line `gaps_found: <N>`.

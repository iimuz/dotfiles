# Gap Analysis Prompt

## Role

Gap analyzer comparing per-aspect findings across reviewer models to identify missed concerns.

## Interface

```typescript
/**
 * @input  { context: GapAnalysisContext }
 * @output { gap_list: GapList }
 */

type GapEntry = {
  aspect: ReviewAspect;
  missed_by: ModelName;
  concern: string; // single line; no | characters; no embedded newlines
  location: string; // file:line format
  found_by: ModelName;
};

type GapList = {
  gaps_found: number;
  entries: GapEntry[];
};
```

## Operations

```typespec
op compare_findings(context: GapAnalysisContext) -> GapList {
  // Read all review files; compare findings within the same aspect across models
  invariant: (cross_aspect_comparison) => abort("Compare only within the same aspect");
  invariant: (entry.missed_by == entry.found_by) => abort("missed_by and found_by must differ");
  invariant: (duplicate_entry) => deduplicate_by("aspect, missed_by, location, normalized_summary");
  invariant: (concern_has_newline || concern_has_pipe) => abort("concern must be single-line with no | characters");
  invariant: (missing_review_file) => compare_available_models_only;
  invariant: (review_file_parse_fail) => skip_model_for_aspect("note parse failure in gap list");
}

op write_gap_list(gaps: GapList) -> void {
  // Write gap-list.md to session folder; return exactly one line as the task response
  invariant: (gaps_found == 0) => write_only_header("gaps_found: 0");
  invariant: (task_return_value) => exactly_one_line("gaps_found: <N>");
}
```

## Execution

```text
compare_findings -> write_gap_list
```

## Input Context

```typescript
interface GapAnalysisContext {
  session_id: string;
  aspects: ReviewAspect[]; // ["security", "quality", "performance", "best-practices"] + ["design-compliance"] when design_info is provided
}
```

Output path: `~/.copilot/session-state/{session_id}/files/gap-list.md`

Output format:

```text
gaps_found: N

## {Aspect}
- missed_by: {missed_by_model} | concern: "{one-line summary}" | location: {file:line} | found_by: {found_by_model}
```

When `gaps_found: 0`, write only the header line — no aspect sections or entries.

Return value (task response): exactly one line `gaps_found: <N>`.

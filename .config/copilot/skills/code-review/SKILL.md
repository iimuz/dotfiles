---
name: code-review
description: >
  Review code changes using multiple AI models in parallel to provide comprehensive
  feedback from diverse perspectives. Works with PRs, uncommitted changes, and local commits.
  Use when thorough multi-perspective code analysis is needed.
---

# Code Review

## Overview

Multi-model code review using 12 parallel agents (4 aspects × 3 models), targeted gap cross-checks, and a single consolidated report.

## Interface

```typescript
/**
 * @skill code-review
 * @input  { scope: ReviewScope }
 * @output { report: ConsolidatedReview }
 */

type ReviewAspect = "security" | "quality" | "performance" | "best-practices";

/** Reviewer model allowlist — all model identifiers must come from this union */
type ModelName = "claude-opus-4.6" | "gemini-3-pro-preview" | "gpt-5.3-codex";

type ModelRoles = {
  /** Balanced multi-aspect analysis; strongest on reasoning and logic */
  ReviewerA: "claude-opus-4.6";
  /** Pattern recognition and documentation quality; strong on best-practices */
  ReviewerB: "gemini-3-pro-preview";
  /** Code-focused insights; strong on security and implementation correctness */
  ReviewerC: "gpt-5.3-codex";
  /** Lightweight gap analyzer; compares per-aspect findings across reviewers */
  GapAnalyzer: "claude-opus-4.6";
  /** Integration agent; synthesizes all reviews into consolidated report */
  Integrator: "claude-opus-4.6";
};

type ReviewScope = {
  type: "pr" | "uncommitted" | "local_commits";
  chunks: Chunk[];
};
type Chunk = { name: string; files: string[] };

type ReviewOutput = { aspect: ReviewAspect; model: string; filepath: string };
type GapEntry = {
  aspect: ReviewAspect;
  missed_by: ModelName;
  concern: string;
  location: string;
  found_by: ModelName;
};
type GapList = { gaps_found: number; entries: GapEntry[] };
/** File-pointer type: location of a cross-check output file (cf. CrossCheckFileContent in cross-check-prompt.md) */
type CrossCheckOutput = {
  aspect: ReviewAspect;
  model: ModelName;
  filepath: string;
};
type ConsolidatedReview = {
  filepath: string;
  critical_count: number;
  warning_count: number;
  suggestion_count: number;
};

/**
 * @invariants
 * 1. Main_No_Read:     main agent never reads *-review.md or *-crosscheck.md
 * 2. Sub_No_Task:      sub-agents cannot invoke the task tool
 * 3. Min_Quorum:       per_aspect_model_count >= 2 or abort
 * 4. Model_Parity:     cross_check_worker.model == gap_entry.missed_by
 * 5. Aspect_Isolation: each reviewer reviews only its assigned ReviewAspect
 * 6. Main_Read_Gate:   main agent reads only gap-list.md (Stage 2b) and consolidated-review.md (Stage 4)
 */
```

## Operations

```typespec
op detect_scope(repo: GitRepo) -> ReviewScope {
  // Detect PR changes, uncommitted changes, or local unpushed commits
  invariant: (not_git_repo) => abort("Current directory is not a git repository.");
  invariant: (no_reviewable_changes) => abort("No reviewable changes found. Stage changes, create commits, or check out a PR branch.");
  invariant: (diff_lines > 1000 || changed_files > 20) => chunk_by_directory(repo);
}

op stage1_parallel_review(scope: ReviewScope) -> ReviewOutput[] {
  // Launch 12 agents (4 aspects × 3 models); each reads @references/review-prompt.md and @references/review-criteria.md
  task(
    model: ModelRoles.ReviewerA | ModelRoles.ReviewerB | ModelRoles.ReviewerC,
    aspects: ReviewAspect[],
    prompt: @references/review-prompt.md,
    criteria: @references/review-criteria.md
  );
  invariant: (per_aspect_responses < 2) => abort("Insufficient review coverage.");
  invariant: (per_aspect_responses == 2) => warn("Degraded mode; note missing model in consolidated report.");
  invariant: (model_timeout || api_failure) => continue_if(remaining_models >= 2);
  invariant: (missing_prompt_template) => continue_if(per_aspect_coverage >= 2);
}

op stage2a_gap_analysis(reviews: ReviewOutput[]) -> GapList {
  // Single haiku-class agent reads all review files and identifies per-aspect gaps
  task(model: ModelRoles.GapAnalyzer, prompt: @references/gap-analysis-prompt.md);
  invariant: (stage2a_fails) => passthrough_to_stage3("note reduced confidence in consolidated output");
  invariant: (gaps_found == 0) => skip(stage2b_cross_check);
  invariant: (gap_list_missing_after_stage2a) => treat_as(gaps_found: 0);
  invariant: (gap_list_parse_fail) => skip(stage2b_cross_check, "note parse error in consolidated report");
}

op stage2b_cross_check(gaps: GapList) -> CrossCheckOutput[] {
  // Fan-out N workers in parallel — one per unique (aspect, missed_by_model) pair; group entries before dispatch
  task(model: gaps[*].missed_by, prompt: @references/cross-check-prompt.md);
  invariant: (gaps_found == 0) => skip("no cross-checks needed");
  invariant: (gaps[*].missed_by not in ModelName) => reject_entry("Unknown model; skip cross-check for this gap entry");
  invariant: (worker_partial_fail) => continue("note incomplete cross-checks in consolidated report");
}

op stage3_consolidate(reviews: ReviewOutput[], cross_checks: CrossCheckOutput[]) -> ConsolidatedReview {
  // Integration agent reads all review/crosscheck files, merges, deduplicates, and validates
  task(model: ModelRoles.Integrator, prompt: @references/integration-prompt.md);
  invariant: (consolidation_fails) => present_highest_priority_findings("note that consolidation failed");
}

op stage4_deliver(consolidated: ConsolidatedReview) -> void {
  // Main agent reads only consolidated-review.md and presents using Output Format below
  invariant: (main_agent_reads_intermediate_files) => abort("I/O invariant violation: @invariants.Main_No_Read");
  invariant: (consolidated_missing) => abort("consolidated-review.md not found; check session folder for errors.");
  invariant: (consolidated_parse_fail) => present_error("consolidated-review.md could not be parsed; presenting highest-priority findings from individual reviews.");
}
```

## Execution

```
detect_scope -> stage1_parallel_review -> stage2a_gap_analysis -> [stage2b_cross_check | skip] -> stage3_consolidate -> stage4_deliver
```

Present `stage4_deliver` output using the Output Format below. Main agent reads only `gap-list.md` (Stage 2b routing) and `consolidated-review.md` (Stage 4 delivery).

Sub-agent prompt templates: [`references/review-prompt.md`](references/review-prompt.md), [`references/cross-check-prompt.md`](references/cross-check-prompt.md), [`references/integration-prompt.md`](references/integration-prompt.md), [`references/gap-analysis-prompt.md`](references/gap-analysis-prompt.md). Aspect criteria: [`references/review-criteria.md`](references/review-criteria.md).

## Output Format

```markdown
## Code Review Summary

Brief assessment of overall change quality and scope.

### Critical Issues (Blocking)

- **[file:line]** Description. Why it matters. Suggested fix.

### Improvements (Non-Blocking)

- **[file:line]** Description. Rationale.

### Positive Observations

- Notable good patterns worth highlighting.

---

_Reviewed by: claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex_
_Session files: ~/.copilot/session-state/{session-id}/files/_
```

**Quality standards for all findings:**

| Check            | Standard                                                               |
| ---------------- | ---------------------------------------------------------------------- |
| File reference   | Every critical issue must include file path and line number            |
| Confidence label | Uncertain findings must be tagged High/Medium/Low confidence           |
| False positives  | Preserve in report but mark clearly as unverified                      |
| Scope            | Focus on bugs, security, and logic errors; exclude style-only comments |

## Session Files

All files are saved to `~/.copilot/session-state/{session-id}/files/`:

| File                                      | Content                                                         |
| ----------------------------------------- | --------------------------------------------------------------- |
| `{aspect}-claude-opus-4.6-review.md`      | Claude's review for that aspect                                 |
| `{aspect}-gemini-3-pro-preview-review.md` | Gemini's review for that aspect                                 |
| `{aspect}-gpt-5.3-codex-review.md`        | GPT's review for that aspect                                    |
| `gap-list.md`                             | Stage 2a gap analysis results (routing file read by main agent) |
| `{aspect}-{model}-crosscheck.md`          | Targeted cross-check output (Stage 2b, when applicable)         |
| `consolidated-review.md`                  | Final integrated review report                                  |

`{aspect}` is one of: `security`, `quality`, `performance`, `best-practices`.

For chunked reviews, prefix with chunk name: `{chunk}-{aspect}-{model}-review.md`.

## Invocation Example

```
skill: code-review
# Review begins automatically — no additional input needed
# Detects PR changes, staged/unstaged changes, or local unpushed commits
```

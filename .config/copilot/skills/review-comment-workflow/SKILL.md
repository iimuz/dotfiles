---
name: review-comment-workflow
description: Resolve PR review comments when users ask to gather facts, evaluate fixes, verify diffs, and commit approved changes.
user-invocable: true
disable-model-invocation: false
---

# Review Comment Workflow

## Overview

Use this workflow to resolve pull request review comments with a staged orchestration
that prioritizes safe decisions and explicit verification before reporting completion.

## Interface

```typescript
type ModelRoles = {
  coordinator: "Runs stage sequencing, gates, and artifact handoff.";
  gatherer: "task(agent_type: 'general-purpose', model: 'gemini-3-pro-preview')";
  evaluator: "skill('council')";
  implementer: "skill('task-coordinator')";
  verifier: "skill('code-review', model: 'claude-opus-4.6')";
  committer: "task(agent_type: 'general-purpose', model: 'gpt-5.3-codex')";
};

type SessionFileTypes = {
  gatherMd: "review-comment-workflow-{timestamp}-gather.md";
  evalInputMd: "review-comment-workflow-{timestamp}-eval-input.md";
  councilJson: "review-comment-workflow-{timestamp}-council.json";
  fixPlanJson: "review-comment-workflow-{timestamp}-fix-plan.json";
  implementJson: "review-comment-workflow-{timestamp}-implement.json";
  verifyJson: "review-comment-workflow-{timestamp}-verify.json";
  commitJson: "review-comment-workflow-{timestamp}-commit.json";
  summaryMd: "review-comment-workflow-{timestamp}-summary.md";
};

type SeveritySummary = {
  critical_count: number;
  high_count: number;
  medium_count: number;
  low_count: number;
};

declare function reviewCommentWorkflow(input: {
  comments: string;
  context?: string;
}): { summary: string };
// @fault input_missing_comments => abort_with_error_summary
// @invariant orchestrator_skill_calls_use_skill_not_task
// @invariant gather_output_is_facts_only_no_judgments_recommendations_or_opinions
// @invariant fail_closed_for_ambiguous_evaluation_output
// @invariant artifacts_saved_under_session_state_files
// @invariant (gather_contains_judgment_or_opinion) => abort("Gather stage must remain facts-only")
// @invariant (coordinator_builds_eval_input_inline_without_gather_artifact) => abort("Delegate gather/eval-input construction to sub-agent")
// @invariant model_roles: ModelRoles
// @invariant session_file_types: SessionFileTypes

declare function gatherStage(input: { comments: string; context?: string }): {
  gather_artifact_path: string;
};
// @fault gather_generation_failed => abort_with_error_summary
// @fault gather_file_missing => abort_with_error_summary
// @fault gather_contains_non_facts => abort_with_error_summary
// @invariant uses task(agent_type: "general-purpose", model: "gemini-3-pro-preview")

declare function evaluateStage(input: { gather_artifact_path: string }): {
  actionable_count: number;
  skip_decision: boolean;
  fix_plan: string;
};
// @fault eval_input_generation_failed => abort_with_error_summary
// @fault eval_input_file_missing => abort_with_error_summary
// @fault council_invocation_failed => abort_with_error_summary
// @invariant uses skill("council") with eval-input artifact path

declare function implementStage(input: {
  skip_decision: boolean;
  fix_plan: string;
}): { implementation_status: string; implementation_artifact_path: string };
// @fault task_coordinator_failed => emit_failed_implementation_status_and_continue
// @invariant uses skill("task-coordinator") when skip_decision is false

declare function verifyStage(input: {
  implementation_artifact_path: string;
  skip_decision: boolean;
}): SeveritySummary;
// @fault code_review_failed => emit_verification_unavailable_and_continue
// @invariant uses skill("code-review", model: "claude-opus-4.6")

declare function commitStage(input: {
  critical_count: number;
  high_count: number;
  implementation_artifact_path: string;
}): { commit_status: string; commit_skip_reason?: string };
// @fault git_add_failed => abort_with_git_add_failed_status
// @fault commit_skill_failed => emit_commit_failed_status_and_continue
// @invariant uses task(agent_type: "general-purpose", model: "gpt-5.3-codex") and commit-staged

declare function summarizeStage(input: {
  actionable_count: number;
  commit_status: string;
  commit_skip_reason?: string;
}): { summary: string };
// @fault summary_artifact_write_failed => abort_with_error_summary
// @invariant summarizes gather, evaluate, implement, verify, and commit outcomes
```

## Workflow

- fault(input_missing_comments) => fallback: abort_with_error_summary; abort

1. Gather

- Delegate gather artifact construction to
  `task(agent_type: 'general-purpose', model: 'gemini-3-pro-preview')` using
  `comments` and optional `context`.
- Require deterministic filename pattern: `review-comment-workflow-{timestamp}-gather.md`.
- Sub-agent writes artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-gather.md`.
- Validate gather file exists on disk and contains only factual observations before proceeding.
- Output: `{ gather_artifact_path }` used by Stage 2.
- fault(gather_generation_failed) => fallback: abort_with_error_summary; abort
- fault(gather_file_missing) => fallback: abort_with_error_summary; abort
- fault(gather_contains_non_facts) => fallback: abort_with_error_summary; abort

1. Evaluate

- Delegate eval-input construction to `task(agent_type: 'general-purpose')` by reading and sanitizing `gather_artifact_path`.
- Strip judgmental wording, advisory language, and uncertain claims from the gather content before eval-input creation.
- Sub-agent writes artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-eval-input.md`.
- Validate eval-input file exists on disk before council invocation.
- Run `skill('council')` with `review-comment-workflow-{timestamp}-eval-input.md` file path as input, not inline text.
- Write artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-council.json`.
- Parse council output into a structured fix plan with item IDs, owners, and concrete change actions.
- Apply fail-closed gate: when a judgment is ambiguous, classify as non-actionable.
- Compute `actionable_count` and set `skip_decision` where true means implementation is skipped.
- Enforce gate: `actionable_count == 0` forces skip.
- Write artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-fix-plan.json`.
- Output: `{ actionable_count, skip_decision, fix_plan }` used by Stage 3.
- fault(eval_input_generation_failed) => fallback: abort_with_error_summary; abort
- fault(eval_input_file_missing) => fallback: abort_with_error_summary; abort
- fault(council_invocation_failed) => fallback: abort_with_error_summary; abort

1. Implement

- Run this stage only when `skip_decision` is false.
- Call `skill('task-coordinator')` with `fix_plan` as the implementation request.
- If skipped, emit `implementation_status: skipped` with reason `no_actionable_items`.
- Write artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-implement.json`.
- Output: implementation result payload or skip payload.
- fault(task_coordinator_failed) => fallback: emit_failed_implementation_status; continue

1. Verify

- Call `skill('code-review', model: 'claude-opus-4.6')` against unstaged working-tree changes produced by Stage 3.
- When Stage 3 was skipped, verify that no unintended unstaged changes exist and mark verification as passed-with-skip-context.
- Write artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-verify.json`.
- Output: verification findings with explicit severity summary `{ critical_count, high_count, medium_count, low_count }`.
- fault(code_review_failed) => fallback: emit_verification_unavailable_and_continue; continue

1. Commit

- Read verify artifact severity fields and attempt strict parsing for `critical_count` and `high_count`.
- Apply severity gate: proceed only when `critical_count == 0` and `high_count == 0`.
- If severity parsing fails, skip commit and propagate `commit_skip_reason: severity_parse_failed`.
- If gate fails, skip commit and propagate `commit_skip_reason: severity_gate_failed`.
- Delegate commit execution to `task(agent_type: 'general-purpose', model: 'gpt-5.3-codex')`.
  Sub-agent performs: git add to stage implementation changes, staged-change pre-check
  (if no staged changes exist, propagate `commit_skip_reason: no_staged_changes` and skip),
  `skill('commit-staged')` invocation when staged-change pre-check passes, and commit artifact JSON write to
  `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-commit.json`.
- Output: `{ commit_status, commit_skip_reason? }` used by Stage 6.
- fault(git_add_failed) => fallback: abort_with_git_add_failed_status; abort
- fault(commit_skill_failed) => fallback: emit_commit_failed_status_and_continue; continue

1. Summarize

- Produce a final summary covering gather outcome, evaluation outcome,
  implementation status, verification results, and commit status.
- Keep wording explicit about skips, degraded paths, unresolved risks, and any `commit_skip_reason`.
- Write artifact: `~/.copilot/session-state/{session_id}/files/review-comment-workflow-{timestamp}-summary.md`.
- Output: `{ summary: string }`.
- fault(summary_artifact_write_failed) => fallback: abort_with_error_summary; abort

## Execution

```text
gather -> evaluate -> implement -> verify -> commit -> summarize
```

## Session Files

- `review-comment-workflow-{timestamp}-gather.md`
- `review-comment-workflow-{timestamp}-council.json`
- `review-comment-workflow-{timestamp}-eval-input.md`
- `review-comment-workflow-{timestamp}-fix-plan.json`
- `review-comment-workflow-{timestamp}-implement.json`
- `review-comment-workflow-{timestamp}-verify.json`
- `review-comment-workflow-{timestamp}-commit.json`
- `review-comment-workflow-{timestamp}-summary.md`

## Examples

### Happy Path

- Gather extracts facts to `review-comment-workflow-{timestamp}-gather.md` and hands off sanitized input to Evaluate.
- Evaluate produces actionable fix plan items and Implement applies approved changes.
- Verify reports zero critical and zero high findings, and Commit proceeds after staged-change pre-check.
- Summarize reports gather, evaluate, implement, verify, and commit outcomes.

### Failure Path

- Gather succeeds, but Verify returns high-severity findings so Commit is skipped with `commit_skip_reason: severity_gate_failed`.
- If severity parsing fails, Commit is skipped with `commit_skip_reason: severity_parse_failed` and workflow continues.
- Summarize includes gather handoff details and explicit commit skip reason.

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

At execution start, the orchestrator generates a run timestamp (`YYYYMMDDHHMMSS`)
and derives two paths:

- `run_dir` = `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow/` for intermediate artifacts
- final output = `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow-summary.md`

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
  gatherMd: "gather.md";
  evalInputMd: "eval-input.md";
  councilJson: "council.json";
  fixPlanJson: "fix-plan.json";
  implementJson: "implement.json";
  verifyJson: "verify.json";
  commitJson: "commit.json";
  summaryMd: "YYYYMMDDHHMMSS-review-comment-workflow-summary.md";
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
- Require deterministic filename pattern: `gather.md`.
- Sub-agent writes artifact: `{run_dir}/gather.md`.
- Validate gather file exists on disk and contains only factual observations before proceeding.
- Output: `{ gather_artifact_path }` used by Stage 2.
- fault(gather_generation_failed) => fallback: abort_with_error_summary; abort
- fault(gather_file_missing) => fallback: abort_with_error_summary; abort
- fault(gather_contains_non_facts) => fallback: abort_with_error_summary; abort

1. Evaluate

- Delegate eval-input construction to `task(agent_type: 'general-purpose')` by
  reading and sanitizing `gather_artifact_path`.
- Strip judgmental wording, advisory language, and uncertain claims from the gather content before eval-input creation.
- Sub-agent writes artifact: `{run_dir}/eval-input.md`.
- Validate eval-input file exists on disk before council invocation.
- Run `skill('council')` with
  `{run_dir}/eval-input.md` file path as input, not inline text.
- Write artifact: `{run_dir}/council.json`.
- Parse council output into a structured fix plan with item IDs, owners, and concrete change actions.
- Apply fail-closed gate: when a judgment is ambiguous, classify as non-actionable.
- Compute `actionable_count` and set `skip_decision` where true means implementation is skipped.
- Enforce gate: `actionable_count == 0` forces skip.
- Write artifact: `{run_dir}/fix-plan.json`.
- Output: `{ actionable_count, skip_decision, fix_plan }` used by Stage 3.
- fault(eval_input_generation_failed) => fallback: abort_with_error_summary; abort
- fault(eval_input_file_missing) => fallback: abort_with_error_summary; abort
- fault(council_invocation_failed) => fallback: abort_with_error_summary; abort

1. Implement

- Run this stage only when `skip_decision` is false.
- Call `skill('task-coordinator')` with `fix_plan` as the implementation request.
- If skipped, emit `implementation_status: skipped` with reason `no_actionable_items`.
- Write artifact: `{run_dir}/implement.json`.
- Output: implementation result payload or skip payload.
- fault(task_coordinator_failed) => fallback: emit_failed_implementation_status; continue

1. Verify

- Call `skill('code-review', model: 'claude-opus-4.6')` against unstaged working-tree changes produced by Stage 3.
- When Stage 3 was skipped, verify that no unintended unstaged changes exist and
  mark verification as passed-with-skip-context.
- Write artifact: `{run_dir}/verify.json`.
- Output: verification findings with explicit severity summary
  `{ critical_count, high_count, medium_count, low_count }`.
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
  `{run_dir}/commit.json`.
- Output: `{ commit_status, commit_skip_reason? }` used by Stage 6.
- fault(git_add_failed) => fallback: abort_with_git_add_failed_status; abort
- fault(commit_skill_failed) => fallback: emit_commit_failed_status_and_continue; continue

1. Summarize

- Produce a final summary covering gather outcome, evaluation outcome,
  implementation status, verification results, and commit status.
- Keep wording explicit about skips, degraded paths, unresolved risks, and any `commit_skip_reason`.
- Write artifact: `{final_output}`.
- Output: `{ summary: string }`.
- fault(summary_artifact_write_failed) => fallback: abort_with_error_summary; abort

## Execution

```python
ts = now("YYYYMMDDHHMMSS")
run_dir = f"{session_dir}/{ts}-review-comment-workflow"
final_output = f"{session_dir}/{ts}-review-comment-workflow-summary.md"
gather -> evaluate -> implement -> verify -> commit -> summarize
```

## Output

- Delivery path: `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow-summary.md`

## Session Files

Intermediate files are saved under {run_dir}/. The final output is saved directly under {session_dir}/.

- `{run_dir}/gather.md`
- `{run_dir}/council.json`
- `{run_dir}/eval-input.md`
- `{run_dir}/fix-plan.json`
- `{run_dir}/implement.json`
- `{run_dir}/verify.json`
- `{run_dir}/commit.json`
- `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow-summary.md`

## Examples

### Happy Path

- Gather extracts facts to `{run_dir}/gather.md`
  and hands off sanitized input to Evaluate.
- Evaluate reads `{run_dir}/eval-input.md` and
  writes plan artifacts under `{run_dir}/`.
- Verify reports zero critical and zero high findings from
  `{run_dir}/verify.json`, and Commit proceeds after staged-change pre-check.
- Summarize reports gather, evaluate, implement, verify, and commit outcomes at
  `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow-summary.md`.

### Failure Path

- Gather succeeds, but Verify returns high-severity findings in
  `{run_dir}/verify.json` so Commit is skipped with
  `commit_skip_reason: severity_gate_failed`.
- If severity parsing fails, Commit is skipped with `commit_skip_reason: severity_parse_failed` and workflow continues.
- Summarize includes gather handoff details and explicit commit skip reason at
  `{session_dir}/YYYYMMDDHHMMSS-review-comment-workflow-summary.md`.

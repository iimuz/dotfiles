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

- Input Type: `{ comments: string, context?: string }`
- Output Type: `{ summary: string }`
- Model Roles:
  - Coordinator: Runs stage sequencing, gates, and artifact handoff.
  - Gatherer: `task(agent_type: 'general-purpose', model: 'gemini-3-pro-preview')`
    extracts facts only from comments and context.
  - Evaluator: `skill('council')` classifies comments and recommends actions.
  - Implementer: `skill('task-coordinator')` applies approved fix plan items.
  - Verifier: `skill('code-review', model: 'claude-opus-4.6')` reviews unstaged changes for correctness.
  - Committer: `task(agent_type: 'general-purpose', model: 'gpt-5.3-codex')`
    delegates commit execution (git add, pre-check, `skill('commit-staged')`,
    artifact write) when verify severity gate passes.
- Session File Types:
  - Gather MD
  - Eval Input MD
  - Council Result JSON
  - Fix Plan JSON
  - Implementation Result JSON
  - Verification Result JSON
  - Commit Result JSON
  - Final Summary MD
- Invariants:
  - Use `skill()` orchestration calls directly; do not wrap orchestrator skills in `task()`.
    Utility skills (e.g., `commit-staged`) may be invoked from within `task()` sub-agents.
  - Gather output must be facts-only with no judgments, recommendations, or opinions.
  - Use fail-closed interpretation for ambiguous evaluation output.
  - Save all artifacts under `~/.copilot/session-state/{session_id}/files/`.
  - `invariant: (gather_contains_judgment_or_opinion) => abort("Gather stage must remain facts-only")`
  - `invariant: (coordinator_builds_eval_input_inline_without_gather_artifact) =>
abort("Delegate gather/eval-input construction to sub-agent")`

## Workflow

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

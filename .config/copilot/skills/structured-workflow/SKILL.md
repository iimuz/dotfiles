---
name: structured-workflow
description: >
  Orchestrate Plan, Implement, Review, and Commit phases in an automated iterative loop.
  This skill should be used when coordinating implementation-plan, code-review, and commit-staged skills without manual confirmation between phases.
---

# Structured Workflow

## Overview

Runs a 5-phase development cycle (Plan → Implement → Commit → Review → Summary) with automatic iteration, looping up
to 3 times to resolve Critical and High severity issues.

## Interface

```typescript
/**
 * @skill structured-workflow
 * @input  { task: string; tdd_mode?: boolean }
 * @output { summary: FinalSummary }
 */

type Issue = {
  severity: "Critical" | "High" | "Medium" | "Low";
  description: string;
};
type ReviewResult = { issues: Issue[] };
type PlanResult = { session_state_file: string; summary: string };
type CommitRef = { sha: string; message: string };
type IterationRecord = {
  iteration: number;
  commit: CommitRef;
  review: ReviewResult;
};
type FinalSummary = {
  fixed: Issue[]; // 修正完了した指摘
  unfixed: Issue[]; // 未修正の指摘
  history: IterationRecord[]; // イテレーション履歴
  recommendations: string[]; // 推奨事項
};

/**
 * @invariants
 * 1. Zero_Verbosity:        imperative step text => remove
 * 2. Signature_Integrity:   all ops fully typed
 * 3. Language_Constraint:   user_facing_output => Japanese; code && commit_messages => own_conventions
 * 4. No_Phase_Confirmation: no ask_user between phases; only at final_summary and error recovery
 */
```

## Operations

```typespec
op plan(task: string) -> PlanResult {
  skill(name: "implementation-plan", input: task);
  // Summarize plan for user in Japanese
  invariant: (plan_empty) => abort("implementation-plan produced no output");
}

op implement(plan: PlanResult, iteration: number, prior_issues: Issue[], tdd_mode: boolean) -> void {
  skill(name: "task-coordinator", input: @references/implement-prompt.md, vars: { plan, iteration, prior_issues, tdd_mode });
  invariant: (subagent_fails) => abort("Implementation subagent failed; halt and report");
}

op commit(iteration: number) -> CommitRef {
  skill(name: "commit-staged");
  invariant: (nothing_staged) => abort("No staged changes to commit");
}

op review(plan: PlanResult, iteration: number) -> ReviewResult {
  skill(name: "code-review", scope: "cumulative", design_info: plan.summary);
  // Summarize findings in Japanese, categorized by severity
  // plan.summary passed as design_info activates design-compliance aspect; must be ≤ 8000 chars
  invariant: (review_fails)                                      => abort("code-review failed; halt and report");
  invariant: (has_critical_or_high(issues) && iteration < 3)    => continue_loop;
  invariant: (iteration >= 3 || !has_critical_or_high(issues))  => finalize;
}

op final_summary(iterations: IterationRecord[]) -> FinalSummary {
  // Present FinalSummary to user in Japanese
  ask_user(message: "ワークフロー完了。残存する指摘への対応を続けますか？");
  invariant: (unfixed.filter("Critical" | "High").length > 0) => include(recommendations);
}
```

## Execution

```text
plan -> loop(max: 3)[implement -> commit -> review] -> final_summary
```

On error (skill failure or build break): halt immediately; report to user with context; use `ask_user` for error
recovery only.

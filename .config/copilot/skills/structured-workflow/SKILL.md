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
  plan: PlanResult; // 元のタスクと計画内容
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
 * 5. No_Direct_Action:    main_agent must NOT perform directly: read_files | search_code | analyze_content | investigate_intent | summarize_content | decompose_requirements | design_solutions; raw_task_input => pass_through_to_delegated_ops
 * 6. Orchestrator_Only:   main_agent => invoke_ops_and_present_results_only; all investigation | analysis | summarization => must_delegate_to_subagent
 */
```

## Operations

```typespec
op plan(task: string) -> PlanResult {
  skill(name: "implementation-plan", input: task);
  task(agent_type: "explore", prompt: "次の計画要約を日本語で簡潔に要約してください。主要ステップと意図のみを抽出してください。", vars: { planSummary: result.summary }); // output: user-facing display
  invariant: (plan_empty) => abort("implementation-plan produced no output");
}

op implement(plan: PlanResult, iteration: number, prior_issues: Issue[], tdd_mode: boolean) -> void {
  skill(name: "task-coordinator", input: @references/implement-prompt.md, vars: { plan, iteration, prior_issues, tdd_mode });
  invariant: (subagent_fails) => abort("Implementation subagent failed; halt and report");
}

// Design note: commit is intentionally delegated to a subagent via task() to
// minimize main-agent context consumption. The commit prompt and its output are
// confined to the subagent's context window, keeping the orchestrator lean.
op commit(iteration: number) -> CommitRef {
  task(agent_type: "general-purpose", prompt: @references/commit-prompt.md, vars: { iteration });
  // nothing_staged invariant lives in commit-prompt.md (single source of truth)
  invariant: (subagent_fails) => abort("Commit subagent failed; halt and report");
}

op review(plan: PlanResult, iteration: number) -> ReviewResult {
  skill(name: "code-review", scope: "cumulative", design_info: plan.summary);
  task(agent_type: "explore", prompt: "次のレビュー指摘を重大度別（Critical/High/Medium/Low）に日本語で要約してください。", vars: { issues: result.issues }); // output: user-facing display
  invariant: (review_fails)                                      => abort("code-review failed; halt and report");
  invariant: (has_critical_or_high(issues) && iteration < 3)    => continue_loop;
  invariant: (iteration >= 3 || !has_critical_or_high(issues))  => finalize;
}

op final_summary(plan: PlanResult, iterations: IterationRecord[]) -> FinalSummary {
  task(agent_type: "explore", prompt: "plan（元タスクと計画内容）と全 iterations（各イテレーションのコミットとレビュー指摘）をまとめて、plan/fixed/unfixed/history/recommendations を含む日本語の最終報告形式に整形してください。", vars: { plan, iterations }); // output: user-facing display
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

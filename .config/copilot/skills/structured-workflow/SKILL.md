---
name: structured-workflow
description: >
  Orchestrate Plan, Implement, Review, and Commit phases in an automated
  iterative loop. This skill should be used when coordinating
  implementation-plan, code-review, and commit-staged skills without
  manual confirmation between phases.
user-invocable: true
disable-model-invocation: true
---

# Structured Workflow

## Overview

Orchestrator that runs a 5-phase development cycle
(Plan → Implement → Commit → Review → Summary) with automatic iteration,
looping up to 3 times to resolve Critical and High severity issues.
The main agent calls orchestrator skills directly via `skill()` and
delegates non-orchestrator work to sub-agents via `task()`.

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
type IterationVerdict = {
  has_critical_or_high: boolean;
  issues: Issue[];
};
type PlanResult = { plan_filepath: string };
type CommitRef = { sha: string; message: string };
type IterationRecord = {
  iteration: number;
  commit: CommitRef;
  verdict: IterationVerdict;
};
type FinalSummary = {
  plan: PlanResult;
  fixed: Issue[];
  unfixed: Issue[];
  history: IterationRecord[];
  recommendations: string[];
};

/**
 * @invariants
 * 1. Zero_Verbosity:             imperative step text => remove
 * 2. Signature_Integrity:        all ops fully typed
 * 3. Language_Constraint:         user_facing_output => Japanese;
 *                                 code && commit_messages =>
 *                                 own_conventions
 * 4. No_Phase_Confirmation:      no ask_user between phases;
 *                                 only at final_summary and
 *                                 error recovery
 * 5. No_Orchestrator_Nesting:    implementation-plan | code-review
 *                                 | task-coordinator | commit-staged
 *                                 => must call via skill() directly;
 *                                 must NOT wrap in task() sub-agent
 * 6. Subagent_For_NonOrchestrator: sub-agents only for:
 *                                 scope analysis | language detection
 *                                 | file staging |
 *                                 plan summary extraction |
 *                                 final summary formatting
 * 7. Minimal_Reads:              main_agent reads only
 *                                 plan_filepath,
 *                                 plan-summary.txt,
 *                                 sw-implement-request-{n}.md,
 *                                 workflow-summary.md
 */
```

## Operations

```typespec
op orchestrate(
  task: string,
  tdd_mode: boolean = false
) -> FinalSummary {
  // Phase 1: skill("implementation-plan") + explore sub-agent
  //          for plan summary
  // Phase 2–4: loop(max: 3) [
  //   structured-workflow-implement sub-skill via task()
  //   -> skill("task-coordinator")
  //   -> stage files via task()
  //   -> skill("commit-staged")
  //   -> skill("code-review")
  // ]
  // Phase 5: explore sub-agent for final summary

  invariant: (orchestrator_in_subagent) =>
    abort("Orchestrator skills must be called via skill()");
  invariant: (main_reads_unneeded_files) =>
    abort("Main agent reads only routing files");
}
```

## Execution

Resolve `session_id` and
`session_dir = ~/.copilot/session-state/{session_id}/files/`
before starting the pipeline.

### Phase 1: Plan

```typespec
skill(name: "implementation-plan",
      input: { session_id, user_request: task })
```

Read `plan_filepath` from the skill result (`PlanResult`).

Extract plan summary for later use in Phase 4:

```text
task(agent_type: "explore",
     prompt: "Read the plan at {plan_filepath}
              and write a 1-paragraph summary
              (max 500 chars) capturing the design
              intent to
              {session_dir}/plan-summary.md")
```

Read `{session_dir}/plan-summary.md` and store as `plan_summary`.

Fault: skill fails → abort with report.

### Phase 2–4: Iterative Loop

Set `iteration = 1`, `prior_issues = []`.
Repeat until `!has_critical_or_high || iteration > 3`.

#### Phase 2: Implement

Step 1 — Scope preparation via sub-skill:

```text
task(agent_type: "general-purpose",
     prompt: "Use the skill tool to invoke
              'structured-workflow-implement'
              with input:
              { session_id: '{session_id}',
                plan_filepath: '{plan_filepath}',
                iteration: {iteration},
                prior_issues: {prior_issues_json},
                tdd_mode: {tdd_mode} }")
```

Read `{session_dir}/sw-implement-request-{iteration}.md`.

Step 2 — Execute implementation:

```typespec
skill(name: "task-coordinator",
      input: <content of
              sw-implement-request-{iteration}.md>)
```

Fault: sub-agent or skill fails → abort with report.

#### Phase 3: Commit

Step 1 — Stage files via sub-agent:

```text
task(agent_type: "general-purpose",
     prompt: "Run git status to identify
              modified/new files related to the
              implementation. Stage all relevant
              files with git add. Do NOT stage
              unrelated files. Report which files
              were staged.")
```

Step 2 — Commit staged changes:

```typespec
skill(name: "commit-staged")
```

Read `CommitRef` from skill result.

Fault: nothing staged or skill fails →
abort with report.

#### Phase 4: Review

```typespec
skill(name: "code-review",
      input: { session_id: session_id,
               target: "HEAD",
               design_info: plan_summary })
```

Read `IterationVerdict` from skill result.

Loop control:

- `has_critical_or_high == true && iteration < 3` →
  set `prior_issues = verdict.issues`,
  increment `iteration`, continue loop
- `has_critical_or_high == false || iteration >= 3` →
  exit loop, proceed to Phase 5

Fault: skill fails → abort with report.

### Phase 5: Final Summary

```text
task(agent_type: "explore",
     prompt: "plan（元タスクと計画内容）と
              全 iterations
              （各イテレーションのコミットと
              レビュー指摘）をまとめて、
              plan/fixed/unfixed/history/
              recommendations を含む日本語の
              最終報告形式に整形し、
              {session_dir}/workflow-summary.md
              に書き込んでください。

              ## Input Context
              - plan_filepath: {plan_filepath}
              - iterations: {iterations_json}")
```

Read `{session_dir}/workflow-summary.md` and present to user.

```text
ask_user(message: "ワークフロー完了。
                   残存する Critical/High 指摘への
                   対応を続けますか？")
```

### Pipeline Summary

```text
phase1_plan
  -> loop(max: 3)[
       phase2_implement
       -> phase3_commit
       -> phase4_review
     ]
  -> phase5_final_summary
```

Loop exits when `!has_critical_or_high || iteration >= 3`.

On error: halt immediately; report to user with context;
use `ask_user` for error recovery only.

## Session Files

All files saved to
`~/.copilot/session-state/{session_id}/files/`:

| File                           | Written by                    | Read by            |
| ------------------------------ | ----------------------------- | ------------------ |
| `{purpose}-{component}-{n}.md` | implementation-plan           | Phase 1 (filepath) |
| `plan-summary.txt`             | explore sub-agent             | Phase 1, Phase 4   |
| `sw-implement-request-{n}.md`  | structured-workflow-implement | Phase 2            |
| `workflow-summary.md`          | explore sub-agent             | Phase 5            |

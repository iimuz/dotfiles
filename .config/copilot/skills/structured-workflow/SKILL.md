---
name: structured-workflow
description: >
  Orchestrate Plan, Implement, Review, and Commit phases in an automated
  iterative loop. This skill should be used when coordinating
  implementation-plan, code-review, and commit-staged skills without
  manual confirmation between phases.
user-invocable: true
disable-model-invocation: false
---

# Structured Workflow

## Overview

Orchestrator that runs a 5-phase development cycle
(Plan → Implement → Commit → Review → Summary) with automatic iteration,
looping up to 3 times to resolve Critical and High severity issues.
The main agent calls orchestrator skills directly via `skill()` and
delegates non-orchestrator work to sub-agents via `task()`.
At execution start, the orchestrator generates a run timestamp (`YYYYMMDDHHMMSS`)
and derives two paths:

- `run_dir` = `{session_dir}/YYYYMMDDHHMMSS-structured-workflow/` for intermediate artifacts
- final output = `{session_dir}/YYYYMMDDHHMMSS-structured-workflow-summary.md`

## Schema

```typescript
// Path reference only — do not read contents in main agent context.
type OpaqueFilePath = string;
type Issue = {
  severity: "Critical" | "High" | "Medium" | "Low";
  description: string;
  iteration?: number; // set when carried forward from a prior iteration
};
type CommitRef = {
  sha: string;
  message: string;
};
type Verdict = {
  has_critical_or_high: boolean;
  issues: Issue[];
};
type FinalSummary = {
  plan: { plan_filepath: OpaqueFilePath };
  fixed: Issue[];
  unfixed: Issue[];
  history: {
    iteration: number;
    commit: CommitRef;
    verdict: Verdict;
  }[];
  recommendations: string[];
};
```

Input: `{ task: string }` → Output: `FinalSummary` at `{session_dir}/YYYYMMDDHHMMSS-structured-workflow-summary.md`

## Constraints

- Do not call `ask_user()` between phases; call it only at the final summary step or for error recovery.
- Call orchestrator skills (`implementation-plan`, `code-review`, `task-coordinator`,
  `commit-staged`) via `skill()` directly and never wrap them in `task()`.
- Use `task()` only for non-orchestrator work.
- Read only `plan_filepath`, `{run_dir}/plan-summary.md`,
  `{run_dir}/sw-implement-request-{n}.md`, and `{final_output}` in the main agent context,
  and abort if any other file is read there.
- Suppress intermediate step output and show only phase transitions and the final summary to the user.
- Abort immediately if the `task` input is missing or empty.
- Obtain `session_id` from the CLI environment at skill start (current session identifier;
  do not prompt the user for it).
- Abort and report error context to the user if any stage skill fails.

## Execution

```python
session_id = resolve_session_id()  # obtain from CLI environment (see Constraints)
session_dir = f"~/.copilot/session-state/{session_id}/files"
ts = now("YYYYMMDDHHMMSS")
run_dir = f"{session_dir}/{ts}-structured-workflow"
final_output = f"{session_dir}/{ts}-structured-workflow-summary.md"
prior_issues = []
stage1_plan()
for iteration in range(1, 4):
    stage2_implement()
    stage3_commit()
    verdict = stage4_review()
    if not verdict.has_critical_or_high:
        break
    # Filter to Critical/High issues, tag each with iteration number for traceability,
    # and carry forward as prior_issues to feed Stage 2 in the next iteration.
    prior_issues = [i for i in verdict.issues if i.severity in ("Critical", "High")]
    for i in prior_issues:
        i.iteration = iteration
stage5_final_summary()
# On error: halt, report context, and use ask_user() only for recovery.
```

### Stage 1: Plan

- Purpose: generate an implementation plan and write a design summary

- Inputs: `session_id: string`, `task: string`
- Actions:

  ```yaml
  - tool: skill
    name: implementation-plan
    input: { session_id: "{session_id}", user_request: "{task}" }
  - tool: task
    agent_type: explore
    model: claude-opus-4.6
    prompt: |
      Read {plan_filepath}; write 1-paragraph summary to {run_dir}/plan-summary.md
  ```

- Outputs: `plan_filepath: OpaqueFilePath`, `{run_dir}/plan-summary.md: OpaqueFilePath`
- Guards: plan_filepath extracted from skill result
- Faults:
  - If the implementation-plan skill fails, abort and report the error.

### Stage 2: Implement

- Purpose: prepare implementation scope and execute tasks via task-coordinator

- Inputs: `session_id: string`, `plan_filepath: OpaqueFilePath`, `iteration: number`, `prior_issues: Issue[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: general-purpose
    model: claude-opus-4.6
    prompt: |
      Invoke skill 'structured-workflow-implement' with
      { session_id, run_dir, plan_filepath, iteration, prior_issues };
      return request_file path
  - { tool: view, path: "{request_file_path}", output: request_file_content }
  - tool: skill
    name: task-coordinator
    input: { request: "{request_file_content}" }
  ```

- Outputs: `{run_dir}/sw-implement-request-{iteration}.md: OpaqueFilePath`
- Guards: request_file readable; task-coordinator succeeds
- Faults:
  - If the implement task or task-coordinator skill fails, abort and report the error.
  - If the request file is unreadable, abort and report the error.

### Stage 3: Commit

- Purpose: stage implementation-related changes and create a commit

- Inputs: `implementation_artifacts: OpaqueFilePath[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: general-purpose
    model: claude-opus-4.6
    prompt: |
      Run git status; stage all implementation-related files
      with git add; report staged files
  - tool: skill
    name: commit-staged
  ```

- Outputs: `commit: CommitRef`
- Guards: at least one file staged before commit
- Faults:
  - If nothing is staged, abort and report the error.
  - If the commit-staged skill fails, abort and report the error.

### Stage 4: Review

- Purpose: review committed changes and determine whether further iteration is needed

- Inputs: `session_id: string`, `{run_dir}/plan-summary.md: OpaqueFilePath`
- Actions:

  ```yaml
  - tool: skill
    name: code-review
    input:
      session_id: "{session_id}"
      target: HEAD
      design_info_filepath: "{run_dir}/plan-summary.md"
  ```

- Outputs: `verdict: Verdict`
- Guards: verdict extracted from skill result
- Faults:
  - If the code-review skill fails, abort and report the error.

### Stage 5: Final Summary

- Purpose: compile Japanese final report from iteration results, present to user, then call ask_user

- Inputs: `plan_filepath: OpaqueFilePath`, `iterations_json: string`, `final_output: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: explore
    model: claude-opus-4.6
    prompt: |
      Read {plan_filepath} and iteration data from {iterations_json};
      write Japanese final report with
      plan/fixed/unfixed/history/recommendations
      to {final_output}
  ```

- Outputs: `{final_output}: FinalSummary`
- Guards: final_output written successfully
- Faults:
  - If the task fails, abort and report the error.

## Session Files

Intermediate files are saved under {run_dir}/. The final output is saved directly under {session_dir}/.

| File                                                                            | Written by                                                 | Read by                 |
| ------------------------------------------------------------------------------- | ---------------------------------------------------------- | ----------------------- |
| `{session_dir}/YYYYMMDDHHMMSS-implementation-plan/{purpose}-{component}-{n}.md` | Stage 1 (implementation-plan skill, owns filename pattern) | Stage 1 (plan_filepath) |
| `{run_dir}/plan-summary.md`                                                     | Stage 1 (explore sub-agent)                                | Stage 4                 |
| `{run_dir}/sw-implement-request-{n}.md`                                         | Stage 2 (structured-workflow-implement)                    | Stage 2                 |
| `{session_dir}/YYYYMMDDHHMMSS-structured-workflow-summary.md`                   | Stage 5 (explore sub-agent)                                | Stage 5                 |

## Examples

### Happy Path

- Input: { task: "Add OAuth login" }
- All intermediate artifacts are written under {run_dir}/; 1 iteration; no Critical/High issues in Stage 4 review
- Output: FinalSummary written to {session_dir}/YYYYMMDDHHMMSS-structured-workflow-summary.md; user shown final report

### Failure Path

- Input: { task: "..." }; Stage 1 implementation-plan skill fails
- Stage 1 aborts; error context reported to user; no {run_dir}/plan-summary.md is produced

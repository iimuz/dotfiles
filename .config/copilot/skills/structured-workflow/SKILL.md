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

Operational constraints:

- Zero_Verbosity: remove imperative step text from all user-facing output.
- No_Phase_Confirmation: do not call ask_user() between phases; only at final summary or for
  error recovery.
- No_Orchestrator_Nesting: orchestrator skills (implementation-plan, code-review,
  task-coordinator, commit-staged) must be called via skill() directly; NEVER wrapped in task().
- Subagent_For_NonOrchestrator: task() must only invoke non-orchestrator sub-skills.
- Minimal_Reads: main agent reads only plan_filepath, plan-summary.md,
  sw-implement-request-{n}.md, workflow-summary.md; abort if any other file is read directly.
- Draft_Review_Safety: Stage 1 intermediate outputs MUST be written to session-scoped
  scratch space first and MUST NOT write to user-managed persistent files such as
  `docs/plans/` or `docs/design/` during draft stages.

## Interface

```typescript
type Issue = {
  severity: "Critical" | "High" | "Medium" | "Low";
  description: string;
};
type FinalSummary = {
  plan: { plan_filepath: string };
  fixed: Issue[];
  unfixed: Issue[];
  history: {
    iteration: number;
    commit: { sha: string; message: string };
    verdict: { has_critical_or_high: boolean; issues: Issue[] };
  }[];
  recommendations: string[];
};
declare function orchestrate(input: { task: string }): FinalSummary;
// @fault invalid_task_input => fallback: none; abort
```

## Execution

```python
session_id = resolve_session_id()
session_dir = f"~/.copilot/session-state/{session_id}/files/"
prior_issues = []
stage1_plan()
for iteration in range(1, 4):
    stage2_implement()
    stage3_commit()
    verdict = stage4_review()
    if not verdict.has_critical_or_high:
        break
    prior_issues = map_issues(verdict.issues, iteration)
    # Transition: mapped Critical/High issues feed Stage 2 in the next iteration.
stage5_final_summary()
# On error: halt, report context, and use ask_user() only for recovery.
```

### Stage 1: Plan

- Purpose: Generate an implementation plan and write a design summary for review reference.
- Inputs: session_id: string; task: string
- Actions:

  ```yaml
  - tool: skill
    name: implementation-plan
    input:
      session_id: "{session_id}"
      user_request: "{task}"
  - tool: task
    agent_type: explore
    model: claude-opus-4.6
    prompt: |
      Read {plan_filepath}; write 1-paragraph summary to {session_dir}/plan-summary.md
  ```

- Outputs: plan_filepath: string; {session_dir}/plan-summary.md
- Guards: plan_filepath extracted from skill result.
- Guards: Inspect any output_filepath against user-provided context paths; if matched, write to a fresh
  timestamped path in {session_dir} and pass the existing file via reference_filepaths (read-only).
- Faults:
  fault(skill_fails) => fallback: none; abort

### Stage 2: Implement

- Purpose: Prepare implementation scope and execute tasks via task-coordinator.
- Inputs: session_id: string; plan_filepath: string; iteration: number; prior_issues: PriorIssue[]
- Actions:

  ```yaml
  - tool: task
    agent_type: general-purpose
    model: claude-opus-4.6
    prompt: |
      Invoke skill 'structured-workflow-implement' with
      { session_id, plan_filepath, iteration, prior_issues };
      return request_file path
  - tool: view
    path: "{request_file_path}"
    output: request_file_content
  - tool: skill
    name: task-coordinator
    input:
      request: "{request_file_content}"
  ```

- Outputs: ~/.copilot/session-state/{session_id}/files/sw-implement-request-{iteration}.md
- Guards: request_file readable; task-coordinator succeeds
- Faults:
  fault(implement_task_fails) => fallback: none; abort
  fault(request_file_unreadable) => fallback: none; abort
  fault(task_coordinator_fails) => fallback: none; abort

### Stage 3: Commit

- Purpose: Stage all implementation-related changes and create a commit.
- Inputs: implementation artifacts from Stage 2
- Actions:

  ```yaml
  - tool: task
    agent_type: general-purpose
    model: gpt-5.3-codex
    prompt: |
      Run git status; stage all implementation-related files
      with git add; report staged files
  - tool: skill
    name: commit-staged
  ```

- Outputs: CommitRef: { sha: string; message: string }
- Guards: at least one file staged before commit
- Faults:
  fault(nothing_staged) => fallback: none; abort
  fault(skill_fails) => fallback: none; abort

### Stage 4: Review

- Purpose: Review committed changes and evaluate whether further iteration is needed.
- Inputs: session_id: string; {session_dir}/plan-summary.md
- Actions:

  ```yaml
  - tool: skill
    name: code-review
    input:
      session_id: "{session_id}"
      target: HEAD
      design_info_filepath: "{session_dir}/plan-summary.md"
  ```

- Outputs: verdict: { has_critical_or_high: boolean; issues: Issue[] }
- Guards: verdict extracted from skill result
- Faults:
  fault(skill_fails) => fallback: none; abort

### Stage 5: Final Summary

- Purpose: Compile all iteration results into a Japanese final report and present to user.
- Inputs: plan_filepath: string; iterations_json: string; session_dir: string
- Actions:

  ```yaml
  - tool: task
    agent_type: explore
    model: gemini-3-pro-preview
    prompt: |
      Read {plan_filepath} and iteration data from {iterations_json};
      write Japanese final report with
      plan/fixed/unfixed/history/recommendations
      to {session_dir}/workflow-summary.md
  ```

- Outputs: {session_dir}/workflow-summary.md
- Guards: workflow-summary.md written successfully
- Faults:
  fault(task_fails) => fallback: none; abort

```text
ask_user(message: "Workflow complete. Continue addressing any remaining Critical/High issues?")
```

## Session Files

All files saved to
`~/.copilot/session-state/{session_id}/files/`:

| File                           | Written by                    | Read by            |
| ------------------------------ | ----------------------------- | ------------------ |
| `{purpose}-{component}-{n}.md` | implementation-plan           | Stage 1 (filepath) |
| `plan-summary.md`              | explore sub-agent             | Stage 4            |
| `sw-implement-request-{n}.md`  | structured-workflow-implement | Stage 2            |
| `workflow-summary.md`          | explore sub-agent             | Stage 5            |

## Examples

### Happy Path

- Input: { task: "Add OAuth login" }
- All 5 stages succeed; 1 iteration; no Critical/High issues in Stage 4 review
- Output: FinalSummary written to workflow-summary.md; user shown final report

### Failure Path

- Input: { task: "..." }; Stage 1 implementation-plan skill fails
- fault(skill_fails) => fallback: none; abort; user shown error report

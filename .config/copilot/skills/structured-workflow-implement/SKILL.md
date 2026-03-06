---
name: structured-workflow-implement
description: Prepare implementation request from plan scope.
user-invocable: false
disable-model-invocation: false
---

# Structured Workflow Implement

## Overview

Sub-skill that prepares a task-coordinator request file.
Determines the implementation scope from the plan or
prior review issues and writes a natural-language request
file that the main agent passes to `task-coordinator`.

Execution order: determine_scope -> write_checkpoint -> write_request -> write_checkpoint

## Interface

```typescript
type PriorIssue = {
  issue_id: string;
  severity: "Critical" | "High" | "Medium" | "Low";
  file: string;
  action: string;
};

type ScopeResult = {
  tasks: string[];
  context: string;
};

type CheckpointInput = {
  session_id: string;
  iteration: number;
  scope_summary: string;
  status: "scope_done" | "complete";
};

declare function determine_scope(input: {
  plan_filepath: string;
  iteration: number;
  prior_issues: PriorIssue[];
}): ScopeResult;
// @fault plan_unreadable => fallback: none; abort
// @invariant iteration == 1 reads plan_filepath; iteration > 1 scopes to Critical/High prior_issues and excludes unrelated issues
// Detail: iteration==1 → read plan_filepath and extract all tasks/changes to implement.
//         iteration>1  → filter prior_issues to severity "Critical" and "High" only.
//                        Exclude pre-existing issues unrelated to the plan goal.

declare function write_checkpoint(input: CheckpointInput): string;
// @fault checkpoint_write_failed => fallback: none; abort
// @invariant writes { iteration, scope_summary, status } to {session_dir}/sw-checkpoint-{iteration}.json
// Detail: Called after determine_scope with status="scope_done".
//         Called again after write_request with status="complete".

declare function write_request(input: {
  session_id: string;
  iteration: number;
  scope: ScopeResult;
}): { request_file: string; checkpoint_file: string };
// @fault request_write_failed => fallback: none; abort
// @invariant if request and complete checkpoint already exist, returns existing path without regeneration
// Detail: See references/request-template.md for the content structure of the output file.
```

## Session Files

All files saved to
`~/.copilot/session-state/{session_id}/files/`:

| File                          | Written by       | Read by                  |
| ----------------------------- | ---------------- | ------------------------ |
| `sw-implement-request-{n}.md` | write_request    | structured-workflow main |
| `sw-checkpoint-{n}.json`      | write_checkpoint | write_request            |

## Examples

### Happy Path

- Input: { session_id: "s1", plan_filepath: "~/.../plan.md", iteration: 1, prior_issues: [] }
- determine_scope → write_checkpoint(status="scope_done") → write_request → write_checkpoint(status="complete") all succeed
- Output: { request_file: "~/.copilot/session-state/s1/files/sw-implement-request-1.md" }

### Failure Path

- Input: { ..., plan_filepath: "~/.../plan.md" }; plan file not found or unreadable
- fault(plan_unreadable) => fallback: none; abort

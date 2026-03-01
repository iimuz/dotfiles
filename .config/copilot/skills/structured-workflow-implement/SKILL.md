---
name: structured-workflow-implement
description: Prepare a task-coordinator implementation request from plan scope.
user-invocable: false
disable-model-invocation: false
---

# Structured Workflow Implement

## Overview

Sub-skill that prepares a task-coordinator request file.
Determines the implementation scope from the plan or
prior review issues and writes a natural-language request
file that the main agent passes to `task-coordinator`.

## Interface

```typescript
/**
 * @skill structured-workflow-implement
 * @input  ImplementInput
 * @output ImplementOutput
 */

type Issue = {
  severity: "Critical" | "High" | "Medium" | "Low";
  description: string;
};

type PriorIssue = {
  issue_id: string;
  severity: "Critical" | "High" | "Medium" | "Low";
  file: string;
  action: string;
};

type ImplementInput = {
  session_id: string;
  plan_filepath: string;
  iteration: number;
  prior_issues: PriorIssue[];
};

type ScopeResult = {
  tasks: string[];
  context: string;
};

type ImplementOutput = {
  request_file: string;
  checkpoint_file: string;
};
```

## Operations

```typespec
op determine_scope(
  plan_filepath: string,
  iteration: integer,
  prior_issues: PriorIssue[]
) -> ScopeResult {
  // iteration == 1: read plan_filepath, extract tasks
  // iteration > 1: filter prior_issues to
  //                Critical/High only
  // Exclude pre-existing issues unrelated to plan goal
  fault(plan_unreadable) => fallback: none; abort
}

op write_checkpoint(
  session_id: string,
  iteration: integer,
  scope_summary: string,
  status: "scope_done" | "complete"
) -> string {
  // Write { iteration, scope_summary, status }
  // to {session_dir}/sw-checkpoint-{iteration}.json
  // Returns checkpoint file path
}

op write_request(
  session_id: string,
  iteration: integer,
  scope: ScopeResult
) -> ImplementOutput {
  // Recovery: if sw-implement-request-{iteration}.md exists
  // and sw-checkpoint-{iteration}.json shows status "complete",
  // skip re-generation and return existing path.
  // Otherwise: build natural-language request for
  // task-coordinator and write to
  // {session_dir}/sw-implement-request-{iteration}.md
  // After success: call write_checkpoint with status "complete"
}
```

## Execution

```text
determine_scope -> write_checkpoint(status: "scope_done") -> write_request -> write_checkpoint(status: "complete")
```

### determine_scope

- If `iteration == 1`: read `plan_filepath` and extract
  all tasks/changes to implement.
- If `iteration > 1`: filter `prior_issues` to severity
  "Critical" and "High" only.
- Exclude pre-existing issues unrelated to the plan goal.

### write_checkpoint

- Called after `determine_scope` completes with
  `status: "scope_done"`, writing
  `{ iteration, scope_summary, status: "scope_done" }`
  to `{session_dir}/sw-checkpoint-{iteration}.json`.
- Called again after `write_request` succeeds with
  `status: "complete"`, updating the checkpoint file.

### write_request

Build
`{session_dir}/sw-implement-request-{iteration}.md`
with this content structure:

**Recovery rule:** If
`{session_dir}/sw-implement-request-{iteration}.md`
already exists and
`{session_dir}/sw-checkpoint-{iteration}.json`
shows `status: "complete"`, skip re-generation and
return the existing file path.

```markdown
# Implementation Request

## Scope

{scope items as bullet list}

## Instructions

- Implement ALL scope items completely.
- Do not fix pre-existing issues unrelated to the scope.
```

Return `ImplementOutput` with `request_file` and `checkpoint_file` paths.

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
- determine_scope → write_checkpoint → write_request all succeed
- Output: { request_file: "~/.copilot/session-state/s1/files/sw-implement-request-1.md" }

### Failure Path

- Input: { ..., plan_filepath: "~/.../plan.md" }; plan file not found or unreadable
- fault(plan_unreadable) => fallback: none; abort

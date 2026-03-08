---
name: structured-workflow-implement
description: Prepare implementation request from plan scope.
user-invocable: false
disable-model-invocation: false
---

# Structured Workflow Implement

## Overview

Determine the implementation scope from a plan or prior review issues and write a
natural-language request file for downstream execution. For iteration 1, read the plan file
and extract all tasks/changes to implement. For iteration > 1, filter prior issues to severity
Critical and High only, excluding pre-existing issues unrelated to the plan goal.
Execution order: determine_scope -> write_checkpoint -> write_request -> write_checkpoint.

## Schema

```typescript
type PriorIssue = {
  issue_id: string;
  severity: "Critical" | "High" | "Medium" | "Low";
  file: string;
  action: string;
};

type CheckpointInput = {
  iteration: number;
  scope_summary: string;
  status: "scope_done" | "complete";
};
```

## Constraints

- If the plan file is unreadable, abort immediately.
- If the checkpoint write fails, abort immediately.
- If the request write fails, abort immediately.
- If request and complete checkpoint already exist for this iteration, return existing paths without regeneration.

## Input

| Field           | Type           | Required | Description                           |
| --------------- | -------------- | -------- | ------------------------------------- |
| `plan_filepath` | `string`       | yes      | Absolute path to the plan file        |
| `iteration`     | `number`       | yes      | Current iteration number              |
| `prior_issues`  | `PriorIssue[]` | no       | Review issues from previous iteration |
| `output_dir`    | `string`       | yes      | Absolute path to output directory     |

## Output

- request_file: path to the written request file
- checkpoint_file: path to the written checkpoint file

## Examples

### Happy Path

- Input: { plan_filepath: "/tmp/plan.md", iteration: 1, prior_issues: [], output_dir: "/tmp/run/" }
- determine_scope -> write_checkpoint -> write_request -> write_checkpoint all succeed
- Output: { request_file: "/tmp/run/sw-implement-request-1.md" }

### Failure Path

- Input: { plan_filepath: "/tmp/missing.md", ... }; plan file not found
- Abort: plan file is unreadable.

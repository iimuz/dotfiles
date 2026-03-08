---
name: task-coordinator-present
description: Present execution results.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Present

## Overview

Read the synthesis or inline result file and render a formatted summary to the user.
Persist `PresentationReceipt` to `presentation-receipt.json`.

## Schema

```typescript
type PresentationReceipt = {
  status: "ok" | "degraded";
  mode: "inline" | "pipeline";
  result_file: string;
  message: string;
};
```

## Constraints

- Abort without fallback when presentation formatting fails.
- Emit a degraded receipt and continue when `result_file` is unreadable.
- Keep output concise and focused on the result summary.

## Input

| Field         | Type     | Required | Description                             |
| ------------- | -------- | -------- | --------------------------------------- |
| `mode`        | `string` | yes      | Execution mode selected by orchestrator |
| `result_file` | `string` | yes      | Result or synthesis artifact path       |

## Output

- result_file: presented artifact path
- receipt: `PresentationReceipt` with status and user-facing message

Use the following presentation format:

```text
Result Summary
- Mode: {mode}
- Result File: {result_file}
- Status: {ok|degraded}
- Message: {message}
```

## Examples

### Happy Path

- Input: { mode: "pipeline", result_file: "/tmp/synthesis.md" }
- Output: formatted summary rendered; receipt with status: ok

### Failure Path

- `result_file` cannot be read.
- Emit degraded receipt and continue.

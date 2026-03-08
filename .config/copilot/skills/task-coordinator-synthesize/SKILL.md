---
name: task-coordinator-synthesize
description: Synthesize pipeline worker outputs into a unified result.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Synthesize

## Overview

Read `references/synthesizer-protocol.md` for the synthesis workflow. Merge pipeline worker outputs
into one synthesis artifact. Emit a synthesis receipt with status and output file path.

## Schema

```typescript
type PlanTask = {
  id: string;
  agent_type: "explore" | "task" | "general-purpose" | "code-review";
  prompt_file: string;
  output_file: string;
  depends_on: string[];
  description?: string;
  model?: string;
};

type Plan = {
  schema_version: string;
  run_id: string;
  goal: string;
  tasks: PlanTask[];
  synthesis_output_file: string;
};

type WorkerReceipt = {
  task_id: string;
  status: "EXECUTION_OK" | "EXECUTION_FAIL";
  output_file: string;
  summary?: string;
  error?: string;
};

type SynthesisReceipt = {
  status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL";
  output_file: string;
  summary: string;
  reason?: string;
};
```

## Constraints

- Run synthesis only for multi-task pipeline executions.
- Emit a `SYNTHESIS_FAIL` receipt and continue when synthesis generation fails.
- Do not read `synthesis.md` unless explicitly requested by the caller.
- Follow `references/synthesizer-protocol.md` for synthesis workflow, subagent prompt template, and receipt validation rules.

## Input

| Field           | Type              | Required | Description                                            |
| --------------- | ----------------- | -------- | ------------------------------------------------------ |
| `plan`          | `Plan`            | yes      | Validated plan provided by orchestrator plan stage     |
| `receipts`      | `WorkerReceipt[]` | yes      | Worker receipts provided by orchestrator execute stage |
| `protocol_file` | `string`          | yes      | Synthesizer protocol path within skill directory       |

## Output

- synthesis artifact: markdown file at `plan.synthesis_output_file`
- receipt: `SynthesisReceipt` persisted to `synthesis-receipt.json`

## Examples

### Happy Path

- Input: { plan: { run_id: "run-1", tasks: 3 }, receipts: 3, protocol_file: "references/synthesizer-protocol.md" }
- Output: synthesis artifact written; receipt with status: SYNTHESIS_OK and output_file path

### Failure Path

- Synthesis generation fails during protocol execution.
- Emit `SYNTHESIS_FAIL` receipt and continue.

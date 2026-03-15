---
name: task-coordinator-synthesize
description: Synthesize pipeline worker outputs into a unified result.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Synthesize

## Overview

Read `references/synthesizer-protocol.md` for the synthesis workflow, subagent prompt template,
and receipt validation rules. Run synthesis only for multi-task pipeline executions. Merge worker
outputs into a unified synthesis artifact at `plan.synthesis_output_file` and emit a receipt
reporting the final status and output path. If synthesis generation fails, emit a `SYNTHESIS_FAIL`
receipt and continue so the caller can present degraded pipeline results. Do not read
`synthesis.md` unless the caller explicitly requests it.

## Input

- `plan: object` - Validated plan from the orchestrator plan stage, including `synthesis_output_file`.
- `receipts: array` - Worker receipts from the execute stage that provide synthesis inputs and statuses.
- `protocol_file: string` - Synthesizer protocol path within the skill directory.

## Output

- `synthesis_artifact: markdown file` - Unified synthesis written to `plan.synthesis_output_file` for pipeline presentation.
- `receipt: json file` - `synthesis-receipt.json` containing the synthesis status, output file, and summary.

## Examples

- Happy: multi-task pipeline with 3 worker receipts produces the synthesis artifact and a
  `SYNTHESIS_OK` receipt in `synthesis-receipt.json`.
- Failure: synthesis generation fails, emits `SYNTHESIS_FAIL` in `synthesis-receipt.json`, and
  continues for degraded pipeline presentation.

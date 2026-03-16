---
name: task-coordinator-present
description: Present execution results.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Present

## Overview

Read the synthesis or inline result file and render a concise summary to the user. Use
`references/output-format.md` for the required presentation format. Persist the presentation
receipt to `presentation-receipt.json` after rendering. If `result_file` is unreadable, emit a
degraded receipt and continue with a concise message explaining the degraded status. If
presentation formatting fails, abort without fallback.

## Input

- `mode: string` - Execution mode selected by the orchestrator.
- `result_file: string` - Result artifact or synthesis artifact path to read and summarize.

## Output

- `result_summary: text output` - User-facing summary rendered with the format defined in `references/output-format.md`.
- `receipt: json file` - `presentation-receipt.json` containing mode, result file, status, and message.

## Examples

- Happy: mode "pipeline" with a readable result file renders the output format and writes an ok
  receipt to `presentation-receipt.json`.
- Failure: unreadable result file emits a degraded receipt and returns a concise degraded summary.

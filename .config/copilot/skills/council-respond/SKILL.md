---
name: council-respond
description: Generate a single independent council member response to a question.
user-invocable: false
disable-model-invocation: false
---

# Council Respond

## Overview

Read and analyze the question independently, structure a thorough response from multiple angles,
and save the response to the specified output path.

## Constraints

- The analysis must be self-contained; abort if references to other responses appear.
- If the response references other models, abort immediately.
- If the output file already exists, abort immediately.
- The output path must be absolute; abort if filepath validation fails.

## Input

| Field             | Type     | Required | Description                           |
| ----------------- | -------- | -------- | ------------------------------------- |
| `question`        | `string` | yes      | The question to answer                |
| `output_filepath` | `string` | yes      | Absolute path for saving the response |

## Output

| Field            | Type     | Description                              |
| ---------------- | -------- | ---------------------------------------- |
| `saved_filepath` | `string` | Absolute path of the saved response file |

## Examples

### Happy Path

- Input: { question: "What is X?", output_filepath: "/tmp/response.md" }
- Output: response written to /tmp/response.md

### Failure Path

- Input: { question: "What is X?", output_filepath: "/tmp/existing.md" } where file already exists at that path
- Abort: output file already exists.

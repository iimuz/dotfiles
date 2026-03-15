---
name: council-respond
description: Generate a single independent council member response to a question.
user-invocable: false
disable-model-invocation: false
---

# Council Respond

## Overview

Read and analyze the question independently, structure a thorough response from multiple
angles, and save the response to the specified output path.

Keep the analysis self-contained.
Abort if references to other responses appear.
Abort if the response references other models.
Abort if the output file already exists.
Abort if the output path is not absolute.

## Input

- `question: string` (required): The question to answer.
- `output_filepath: string` (required): Absolute path for saving the response.

## Output

- `saved_filepath: string`: Absolute path of the saved response file.

## Examples

- Happy: question="What is X?", output="/tmp/response.md" -- response written.
- Failure: output="/tmp/existing.md" where file exists -- abort: output file already exists.

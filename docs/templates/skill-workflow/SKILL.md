---
name: skill-name
description: What this skill does and clear trigger conditions for when to use it.
user-invocable: true
disable-model-invocation: false
---

# Skill Name

## Overview

One or two sentences describing what this skill does and why it exists.

At execution start, generate a `YYYYMMDDHHMMSS` timestamp and derive:

- Intermediate artifacts: `{session_dir}/{timestamp}-skill-name/` (referred to as `run_dir`)
- Final output: `{session_dir}/{timestamp}-skill-name-descriptor.md`

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.

## Output

Description of the final output. Include field names and types if structured.

- `result_field: type`: What this field contains.

## Execution Flow

### Stage 1: Stage Name

Prose paragraph describing what this stage does and which sub-skill it invokes.
Include any conditions for skipping or branching.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill sub-skill-name with
> input_field={value},
> output_filepath={run_dir}/stage1-output.md

- Output: `{run_dir}/stage1-output.md` -> Stage 2
- Fault: Retry once on failure. Abort if retry fails.

### Stage 2: Stage Name

Prose paragraph describing what this stage does. Reference artifacts from Stage 1.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill another-sub-skill with
> input_paths={stage1_paths},
> output_filepath={final_output}

- Output: `{final_output}`
- Fault: Abort immediately on failure.

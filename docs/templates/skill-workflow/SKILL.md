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

## Input

- `field_name: type` (required): Description of the input field.
- `optional_field: type`: Description of an optional input field.

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

## Examples

- Happy: `field_name: "value"` -- all stages complete, final report delivered.
- Failure: `field_name: ""` -- abort because input is empty.

<!--
  Authoring guidelines:
  - Target: under 300 lines (single-operation: under 200 lines)
  - Use inline `field: type` annotations; avoid TypeScript code blocks unless schema is the primary deliverable
  - Embed constraints inline where they relate to behavior; a separate Constraints section is optional
  - Blockquotes contain only subagent-facing prompts; do not include orchestrator adaptation logic
  - Do not chain more than one level of fallback; if the fallback fails, abort
  - Session artifacts: ~/.copilot/session-state/{session_id}/files/
  - Run directory: {session_dir}/YYYYMMDDHHMMSS-{skill-name}/
  - Final output: {session_dir}/YYYYMMDDHHMMSS-{skill-name}-{descriptor}.md
  - Prefer reasoning-based guidance over bare ALWAYS/NEVER imperatives
  See also: .config/copilot/skills/code-review/SKILL.md
-->

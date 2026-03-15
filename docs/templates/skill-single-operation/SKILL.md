---
name: skill-name
description: One sentence describing what this skill does.
user-invocable: true
disable-model-invocation: false
---

# Skill Name

## Overview

One or two sentences describing what this skill does and why it exists.
Include key constraints inline where they relate to behavior.

Execution order: step-a -> step-b -> step-c.

## Input

- `field_name: type` (required): Description of the input field.
- `optional_field: type`: Description of an optional input field.

## Output

- `result_field: type`: What this field contains.

## Operations

### Step A Name

Describe what this step does. Reference scripts or reference files as needed.
Abort conditions go here.

### Step B Name

Describe what this step does. Reference the output of Step A if applicable.

## Examples

- Happy: 3 files staged with a bug fix -- commit created as `fix: resolve token expiration`.
- Failure: no staged files -- abort with "no staged files to commit".

<!--
  Authoring guidelines:
  - Target: under 200 lines (workflow: under 300 lines)
  - Use inline `field: type` annotations; avoid TypeScript code blocks unless schema is the primary deliverable
  - Embed constraints inline where they relate to behavior; a separate Constraints section is optional
  - Prefer reasoning-based guidance over bare ALWAYS/NEVER imperatives
  See also: .config/copilot/skills/commit-staged/SKILL.md
-->

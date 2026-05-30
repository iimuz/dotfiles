---
name: write-plan
description: >-
  Create or refine a planning file. Use to start the planning phase or to
  reflect inline annotations back into an existing plan.
---

# Write Plan

## Overview

Create a detailed implementation plan, or update an existing plan by processing
inline annotations. Follow the planning template at `references/template.md` as
a starting point — it is intentionally minimal; add sections freely to produce a
complete handoff document.

## Process

### Step 1: Determine Mode

Identify the planning file from the user's prompt (default: `docs/planning.md`).
Read the file if it exists.

- File does not exist → Generate Mode
- File exists → Annotate Mode

### Generate Mode

1. Read all research files the user specifies.
2. Read implementation files and related code referenced in the research files.
3. Write the planning file. Include at minimum:
   - Detailed explanation of the approach
   - Code snippets showing the actual changes
   - File paths that will be modified
   - Considerations and trade-offs
     Add any other sections needed for a complete handoff document.

### Annotate Mode

1. Read the planning file in full.
2. Identify all inline annotations the user has added
   (corrections, rejections, additions, domain knowledge).
3. Process each annotation: update the relevant section accordingly.
4. Remove resolved annotation text after incorporating it.

## Planning File Format

- Use `references/template.md` as a starting point; add sections freely.
- Append notes to `## Log` (never delete or modify existing entries).
- The planning file is ephemeral. GitHub Issues are the permanent record.
- Never delete the planning file without explicit user instruction.

## Constraints

- Do NOT write or edit any implementation files.
- Do not implement any part of the plan.

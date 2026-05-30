---
name: deep-read
description: >-
  Deeply read and understand a specified target, producing a structured
  research document. Use before the planning phase to prevent uninformed changes.
---

# Deep Read

## Overview

Perform an exhaustive reading of the specified target to produce a research document.
Surface-level reading is not acceptable.
Read every relevant file, understand every component, and trace all dependencies.

## Process

1. Identify the target (directory, file, or topic) from the user's instruction.
2. Identify the output file path from the user's instruction
   (pattern: `docs/research-{topic}.md`).
3. Read the target exhaustively:
   - Read every file in the specified scope.
   - Trace imports, dependencies, and related modules.
   - Understand each component's purpose, constraints, and behavior.
   - Look for hidden invariants, edge cases, and existing patterns.
4. Write findings to the output file using the research template at
   [references/template.md](references/template.md). Additional sections may be added freely.

## Constraints

- Never modify implementation files.
- Never propose how to implement — only describe what exists.
- If the target scope is ambiguous, ask for clarification before reading.
- The output file is overwritten if it already exists.

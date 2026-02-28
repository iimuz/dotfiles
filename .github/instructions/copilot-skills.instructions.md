---
applyTo: ".config/copilot/skills/**"
---

# Copilot Skills

## Skill Creation Rule

- Action: Invoke the `skill-creator` and `transform-legacy-skill` skill when creating or updating a skill.
- Reference: Follow the best practices provided by the skill-creator.

## Canonical Skill Format

- Section-1: YAML frontmatter (`name`, `description`).
- Section-2: `## Role`.
- Section-3: `## Interface`.
- Section-4: `## Operations`.
- Section-5: `## Execution`.
- Section-6: `## Input`.
- Section-7: `## Output`.
- Constraint: Do not add, reorder, or rename sections.
- Template: Reference `.config/copilot/skills/references/canonical-skill-template.md`.

## Invariant Syntax

- Rule: All invariants must use anonymous syntax only:

  ```text
  invariant: (condition) => action;
  ```

- Scope: Named invariants (e.g., `1. Zero_Verbosity: ...`) are forbidden outside the `@invariants` JSDoc block.
- Placement: Each `invariant:` line belongs inside the `op` block that owns its condition.
- Interface Placement: Cross-op invariants belong in the `@invariants` JSDoc comment in the
  `## Interface` block.

## Severity Model

- Abort: `abort(reason)` - halt execution immediately; do not produce partial output.
- Warn: `warn(reason)` - log the issue and continue in degraded mode.
- Restriction: No other severity keywords are permitted.

## Dependency Table

- Requirement: The `## Execution` section must include a dependency table with
  `dependent | prerequisite | description` columns.
- Rule: Include a legend row and at least one example row.

  ```markdown
  | dependent      | prerequisite   | description                               |
  | -------------- | -------------- | ----------------------------------------- |
  | _(column key)_ | _(column key)_ | _(dependent requires prerequisite first)_ |
  | step_two       | step_one       | step_two consumes output of step_one      |
  ```

- Rule: The table uses `dependent -> prerequisite` semantics: the left column depends on the right column.

---
applyTo: ".config/copilot/skills/**"
---

# Copilot Skills

- Rule: When creating or updating a skill,
  invoke the `skill-creator` and `transform-legacy-skill` skill and follow its best practices.

## Canonical Skill Format

### Section Order

Every SKILL.md must contain exactly these sections in this order:

1. YAML frontmatter (`name`, `description`)
2. `## Role`
3. `## Interface`
4. `## Operations`
5. `## Execution`
6. `## Input`
7. `## Output`

- Rule: Do not add, reorder, or rename sections.
- Rule: Reference template: `.config/copilot/skills/references/canonical-skill-template.md`

### Invariant Syntax

- Rule: All invariants must use anonymous syntax only:

  ```text
  invariant: (condition) => action;
  ```

- Rule: Named invariants (e.g., `1. Zero_Verbosity: ...`) are forbidden outside the `@invariants` JSDoc block.
- Rule: Each `invariant:` line belongs inside the `op` block that owns its condition.
- Rule: Cross-op invariants belong in the `@invariants` JSDoc comment in the `## Interface` block.

### Severity Model

- Rule: Use `abort(reason)` to halt execution immediately; do not produce partial output.
- Rule: Use `warn(reason)` to log the issue and continue in degraded mode.
- Rule: No other severity keywords are permitted.

### Dependency Table

- Rule: The `## Execution` section must include a dependency table with `dependent | prerequisite | description` columns.
- Rule: Include a legend row and at least one example row.

  ```markdown
  | dependent      | prerequisite   | description                               |
  | -------------- | -------------- | ----------------------------------------- |
  | _(column key)_ | _(column key)_ | _(dependent requires prerequisite first)_ |
  | step_two       | step_one       | step_two consumes output of step_one      |
  ```

- Rule: The table uses `dependent -> prerequisite` semantics: the left column depends on the right column.

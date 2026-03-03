---
applyTo: ".config/copilot/skills/**"
---

# Agent Skills Creation and Management Rules

## Skill Specification (Agent Skills Specification)

- Design: A Skill is not just a collection of prompts, but a module designed based on the principle of "Progressive Disclosure."

### Directory Structure

- Each Skill is placed in its own directory and must include at least a `SKILL.md` file.
- Use the following subdirectories as needed:

```text
skill-name/
├── SKILL.md         # Required: YAML frontmatter + Markdown body
├── scripts/         # Optional: Executable code (Python, Bash, Node.js, etc.)
├── references/      # Optional: Additional documentation (REFERENCE.md, API definitions, etc.)
└── assets/          # Optional: Static resources (templates, images, data files, etc.)
```

### SKILL.md Format

- The file must begin with YAML frontmatter, followed by the instruction body in Markdown.

```yaml
---
name: skill-name
description: What this Skill does and clear trigger conditions for "when to use it."
license: Apache-2.0 # Optional
compatibility: Runtime environment requirements, etc. # Optional
metadata: # Optional
  author: your-name
  version: "1.0"
allowed-tools: Bash(git:*) Read # Optional (space-separated)
user-invocable: true # Required (true for orchestrators, false for sub-skills)
disable-model-invocation: false # Required (always false)
---
```

- Rule: ALWAYS use `## Overview` as the first section heading in the SKILL.md Markdown body.
- Rule: NEVER use `## Role` as a section heading in SKILL.md; use `## Overview` instead.

### Strict Constraints for Frontmatter

- `name` (Required):
  - 1–64 characters. Lowercase alphanumeric characters and hyphens (`-`) only.
  - Leading/trailing hyphens and consecutive hyphens (`--`) are not allowed.
  - Must exactly match the parent directory name.
- `description` (Required):
  - 1–1024 characters.
  - Important: This field is the only trigger the AI uses to determine "when to invoke this Skill."
  - Include clear trigger conditions: "what keywords the user might say" or "what type of task this applies to."
  - Note: The Markdown body is only loaded after the Skill is triggered, so writing "When to use this skill"
    in the body is meaningless.
  - Rule: Sub-skill `description` MUST be one sentence describing only what the skill does.
    MUST NOT include caller metadata (e.g., "This skill should be used only by...").
  - Rule: Sub-skill `description` MUST be 10 words or fewer.
- `user-invocable` (Required):
  - MUST be `true` for orchestrator skills (user-facing entry points).
  - MUST be `false` for sub-skills (invoked only by other skills).
- `disable-model-invocation` (Required):
  - MUST be `false` for all skills.

### Directory Scope Constraint

- Rule: A skill may only reference files inside its own `{skill-name}/` directory tree.
- Rule: NEVER create shared subdirectories directly under `.config/copilot/skills/`;
  only `{skill-name}/` directories are valid children—files outside a skill directory
  are silently inaccessible.
- Rule: Shared reference material must be duplicated into each skill's own `references/` subdirectory.

### Content Scope Constraint

- Rule: SKILL.md bodies MUST contain only runtime instructions (procedures, invariants, examples, fault declarations).
- Rule: NEVER include planning notes, debt tracking, future evaluation, roadmap items,
  or placeholder markers in SKILL.md bodies.
- Exception: Placeholder-marker literals inside code-block invariant examples are permitted.
- Rule: ALWAYS relocate planning content to `docs/plans/` and debt content to `docs/debt/`.

### Interface Section Style

- Rule: ALWAYS use exactly one typescript code block for interface contracts.
- Rule: NEVER use typespec blocks.
- Rule: ALWAYS define operations with declare function signatures.
- Rule: NEVER use JSDoc (/\*\* \*/) for contract definitions.
- Rule: NEVER use markdown bullets for type/operation definitions.
- Rule: ALWAYS place @fault and @invariant tags as comments directly below each declare function.
- Rule: ALWAYS use inline object types when an input/output shape has 3 or fewer top-level fields.
- Rule: ALWAYS use named types when an input/output shape has more than 3 top-level fields.
- Rule: NEVER treat Interface @fault/@invariant annotations as replacements for stage-level
  fault()/assert() declarations; ALWAYS keep both.

## Best Practices and Design Guidelines

- Commit to Progressive Disclosure
  - To protect the LLM's context window, keep the `SKILL.md` body under 500 lines.
  - If content exceeds 500 lines or includes large prompts/data, extract them into additional layers (`references/` or `assets/`).
  - Link from `SKILL.md` using relative paths and provide guidance on "when the AI should read that file"
    (e.g., `For detailed schema, see [schema.md](references/schema.md)`).
  - Include a Table of Contents at the beginning of reference files exceeding 300 lines.
- Writing Instructions (Markdown Body)
  - Rule: In SKILL.md bodies (not instruction files), prefer reasoning-based guidance over bare imperatives.
  - Rule: Include step-by-step procedures, input/output examples, and common edge-case handling.

## Skill Type Taxonomy

- Workflow Skill: Coordinates multi-step execution across sub-skills or agents;
  owns stage sequencing, delegation, and fault routing.
- Knowledge/Transform Skill: Executes a single bounded transformation or analysis;
  does not delegate to other skills or agents.
- Trigger for Workflow Authoring: Skill body contains stage sequencing, task() calls, or sub-skill delegation.
- Trigger for Knowledge/Transform Authoring: Skill body contains a single op chain with no delegation to other skills.

## Workflow Skill Authoring

- Coordinator-Only Discipline: A workflow skill acts as the sole coordinator; it must not
  be invoked as a sub-skill by another workflow skill unless an explicit
  orchestrator-delegation contract is declared in both the parent and child SKILL.md.
- Sub-Agent Nesting Prohibition: Sub-agents invoked by sub-skills MUST NOT make further
  `task()` calls. Sub-agents cannot call sub-agents. If sub-agent routing is needed,
  declare it in the main orchestrator skill.
- Fault Declaration Requirement: Every delegation stage must declare fault tolerance with
  three fields: failure condition, fallback action, and continue or abort decision.
- Fault Declaration Format: `fault(<condition>) => fallback: <action>; <continue|abort>`
- Assert Declaration Format: `assert(<left> != <right>) => on_conflict: <resolution>; <continue|abort>`
  - Use assert() only when two independently produced values are expected to agree or be compatible.
  - Do not use assert() to restate a fault condition; fault() guards failure states, assert() guards consistency.
  - When resolution is "warn", the assertion is non-blocking; execution continues.
- Placement Convention: Place fault() and assert() at the end of each numbered stage block,
  after the stage output description.
- Fallback Sub-Skill Delegation: When the fallback action delegates to a sub-skill, set the
  action field to the sub-skill name with a parenthesized argument summary.
  Do not chain more than one level of fallback delegation; if the fallback sub-skill fails, the decision must be abort.
- Examples Policy: Each workflow skill and each sub-skill it delegates to must include
  one happy-path example and one failure-path example.
- Examples Format: Use `## Examples` section with `### Happy Path` and `### Failure Path`
  subsections; limit each to 5 lines or fewer.
- ALWAYS include an Execution section with a call-order text block (e.g., gather -> evaluate -> synthesize).

## Knowledge/Transform Skill Authoring

- Definition: A knowledge/transform skill executes a single bounded transformation or analysis.
  It does not call task() or delegate to other skills or agents.
- Trigger for Use: Apply this track when the skill body contains a single op chain with no delegation.
- Structure: Define one or more ops in sequence; each op has a clear input, action, and output.
  Do not add stage sequencing, delegation tables, or task() calls.
- Fault Declaration Placement: Place fault() at the end of each op execution description.
  Omit fault() when the op has no meaningful failure mode; do not add empty or trivially true clauses.
- Assert Usage: Do not use assert() in knowledge/transform skills; use op-body invariants for
  input validation and consistency checks instead.
- Coordinator Restriction: No coordinator-only restrictions apply; a knowledge/transform skill
  may be invoked by any workflow skill or directly by the user.
- Examples Policy: Include one happy-path example and one failure-path example using the same
  `## Examples` section format with `### Happy Path` and `### Failure Path` subsections.
- Execution section is optional; omit unless delegation is introduced.

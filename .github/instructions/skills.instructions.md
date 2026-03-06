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

- Rule: ALWAYS include a single H1 title (`# Title`) as the first line of the Markdown body,
  immediately after the frontmatter closing `---`.
  Exception: when the repo uses Prettier for markdown formatting, Prettier enforces a blank
  line after YAML frontmatter. In that case, one blank line between `---` and `# Title` is
  acceptable and required to pass the pre-commit hook.
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
- `allowed-tools` (Optional): Space-separated list of tool identifiers the skill is permitted
  to use. MCP tools use `server-name/tool-name` or `server-name/*` syntax. The set of valid
  identifiers is resolved by the execution environment.
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

### Output Safety

- Rule: `output_filepath` MUST NOT match any reference or input file path.
- Rule: `output_policy` default value is `create_only` when omitted.

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
  Rule: NEVER use JSDoc (/\*\* \*/) for contract definitions.
- Rule: NEVER use markdown bullets for type/operation definitions.
- Rule: ALWAYS place @fault and @invariant tags as comments directly below each declare function.
  Good example (place after closing ``` of Interface block, not inline):

  ```typescript
  declare function fetch(input: { url: string }): string;
  // @fault network_error => fallback: none; abort
  // @invariant url must be https
  ```

  Bad example: placing @fault in prose paragraphs outside the Interface code block.

- Rule: ALWAYS use inline object types when an input/output shape has 3 or fewer top-level fields.
- Rule: ALWAYS use named types when an input/output shape has more than 3 top-level fields.
- Rule: Named types are permitted for shapes with 3 or fewer fields when the type is referenced
  by 2 or more operations in the same Interface section.
- Rule: Named types with 3 or fewer fields are also permitted when the type appears in 3 or more
  distinct field positions within the same Interface block (including within other named types),
  and inlining would create significant duplication.
- Rule: NEVER define types in Interface that are not directly referenced in at least one
  `declare function` signature (argument or return type).
- Rule: In Workflow skills, NEVER treat Interface @fault/@invariant annotations as replacements
  for stage-level fault()/assert() declarations; ALWAYS keep both.
- Rule: Supplementary implementation detail for a `declare function` MUST use `// Detail:`
  prefix on a separate line immediately after `@fault`/`@invariant` annotations.
- Rule: When op detail is too long for inline comments, extract it to `references/` and
  link from the Interface using `// Detail: See references/filename.md for ...`.

### Allowed Section Headings

- Required: `## Overview`, `## Interface`, `## Examples`
- Optional (all skills): `## Session Files`, `## Input`, `## Output`
- Optional (workflow skills only): `## Execution`
- Prohibited: all unlisted headings, including `## Role`
- Rule: Skills that write runtime artifacts MUST include a `## Session Files` section with a
  table listing each file name, the op that writes it, and the op that reads it.
- Rule: All session-scoped runtime artifacts MUST be saved to
  `~/.copilot/session-state/{session_id}/files/`.
- Rule: In Session Files tables, the Written by column MUST name the op for Knowledge/Transform
  skills and MUST name the Stage, Sub-Skill, or Agent type for Workflow skills
  (e.g., `Stage 2`, `structured-workflow-implement`, `explore sub-agent`).

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
- Invocation Separation: choose by delegation capability, not invocability labels.
- Task-capable target (`task()` reachable directly or transitively in its skill-delegation graph) MUST be invoked via `skill()`.
- Task-free target (no reachable `task()` in its delegation graph) MAY be invoked via `skill()` or from within `task()`.
- If capability is unknown, treat as task-capable; non-skill processing MUST use `task()`.
- Sub-Agent Nesting Prohibition: Sub-agents invoked by sub-skills MUST NOT make further
  `task()` calls. Sub-agents cannot call sub-agents. If sub-agent routing is needed,
  declare it in the main orchestrator skill.
- Fault Declaration Requirement: Every delegation stage must declare fault tolerance with
  three fields: failure condition, fallback action, and continue or abort decision.
- Multiple Faults: A single stage's Faults block MAY contain multiple `fault()` declarations,
  one per distinct failure condition.
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
- ALWAYS include an Execution section with a call-order block using a `python` code fence
  (pseudocode showing stage call order, e.g., `stage1(); for i in range(3): stage2()`).
- Control Flow: Workflow skills requiring conditional stage transitions MUST place loop/branch
  logic in the `python` call-order block at the top of Execution. Do not place conditional
  logic as prose between stage definitions.
- Stage Template Requirement: ALWAYS use the 6-field stage template for each stage in the
  Execution section. ALWAYS use `yaml` code fences for Actions blocks in workflow
  stage templates:

  ````text
  ### Stage N: Name

  - Purpose: one-sentence stage objective
  - Inputs: list of required inputs with types
  - Actions:

    ```yaml
    - tool: skill
      name: "..."
      input: { ... }
    - tool: task
      agent_type: "..."
      prompt: "..."
    ```

  - Outputs: list of output artifacts with paths
  - Guards: conditions required to proceed
  - Faults:
    fault(<condition>) => fallback: <action>; <continue|abort>
  ````

## Knowledge/Transform Skill Authoring

- Definition: A knowledge/transform skill executes a single bounded transformation or analysis.
  It does not call task() or delegate to other skills or agents.
- Trigger for Use: Apply this track when the skill body contains a single op chain with no delegation.
- Structure: Define one or more ops in sequence; each op has a clear input, action, and output.
  Do not add stage sequencing, delegation tables, or task() calls.
- Fault Declaration Placement: Place fault() at the end of each op execution description.
  Omit fault() when the op has no meaningful failure mode; do not add empty or trivially true clauses.
- Rule: In Knowledge/Transform skills, `@fault` annotations in the Interface section satisfy
  both Interface-level and op-level fault declaration requirements; a separate Execution
  section is NOT required for fault declarations alone.
- Assert Usage: Do not use assert() in knowledge/transform skills; use op-body invariants for
  input validation and consistency checks instead.
- Coordinator Restriction: No coordinator-only restrictions apply; a knowledge/transform skill
  may be invoked by any workflow skill or directly by the user.
- Examples Policy: Include one happy-path example and one failure-path example using the same
  `## Examples` section format with `### Happy Path` and `### Failure Path` subsections.
- Execution section is optional; omit unless delegation is introduced. When operation
  sequencing is critical for correctness, state the execution order in a single line within
  the Overview section (e.g., `Execution order: op_a -> op_b -> op_c`).
- Op Spec Placement: Op specifications MUST be placed as `//` comments directly below the
  corresponding `declare function` in the Interface section. Large content (e.g., output
  file templates) MUST be extracted to `references/` with a relative link from the Interface.
  Do not use JSDoc `/** */` for op specs.

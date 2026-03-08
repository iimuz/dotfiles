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

- Rule: SKILL.md bodies MUST contain only runtime instructions (procedures, constraints, examples).
- Rule: NEVER include planning notes, debt tracking, future evaluation, roadmap items,
  or placeholder markers in SKILL.md bodies.
- Exception: Placeholder-marker literals inside code-block constraint examples are permitted.
- Rule: ALWAYS relocate planning content to `docs/plans/` and debt content to `docs/debt/`.

### Contract Layers and Schema Style

- Rule: Use a two-layer contract model.
  - Layer 1 (required for all skills): `## Overview`, `## Schema` (when the skill has structured
    input/output), `## Constraints`, and `## Examples`.
  - Layer 2 (optional for complex Workflow skills only): optional
    `## Execution` with call-order block and 6-field stage template, and
    `## Session Files` when runtime artifacts are written.
- Rule: NEVER use JSDoc (/\*\* \*/) for contract definitions.
- Rule: Use TypeScript for data schema definitions only (input/output shapes), not for operation logic.
- Rule: NEVER use TypeSpec blocks.
- Rule: Keep schema definitions in exactly one TypeScript code block per `## Schema` section.
- Rule: NEVER use markdown bullets for type/interface definitions.
- Rule: Prefer `type` or `interface` for data shapes only, and keep operation
  procedures in prose sections such as `## Overview`, `## Constraints`, and `## Execution`.
- Rule: Do not define unused schema types; every schema type MUST be referenced
  by at least one documented input/output shape.

### Constraints Section Style

- Rule: Every SKILL.md MUST include a `## Constraints` section written in plain language.
- Rule: ALL invariants, error handling policies, and failure behaviors MUST be documented in
  `## Constraints` using plain natural-language bullet points.
- Rule: Write constraints as single-sentence imperative bullets.
- Rule: Keep constraints specific, testable, and directly tied to execution behavior.
- Rule: Prefer concise procedural limits over symbolic DSL notation.
- Rule: Do NOT use @fault/@invariant DSL.
- Example:
  - If fewer than 2 responses are received, abort immediately.
  - If a sub-skill fails once, retry once with a refined prompt before aborting.
  - Never read intermediate artifact file contents in the main agent context.

### Allowed Section Headings

- Required (all skills): `## Overview` (first), `## Constraints`, `## Examples`
- Required when applicable: `## Schema` (when the skill has structured input/output),
  `## Session Files` (when the skill writes runtime artifacts)
- Optional (all skills): `## Input`, `## Output`
- Optional (workflow skills only): `## Execution`
- Prohibited: `## Role`
- Rule: Standard headings beyond the listed sections are allowed when needed;
  include a short inline reason for each extra heading.
- Rule: Skills that write runtime artifacts MUST include a `## Session Files` section with a
  table listing each file name, the op that writes it, and the op that reads it.
- Rule: All session-scoped runtime artifacts MUST be saved to
  `~/.copilot/session-state/{session_id}/files/`.
- Rule: In Session Files tables, the Written by column MUST name the op for Knowledge/Transform
  skills and MUST name the Stage, Sub-Skill, or Agent type for Workflow skills
  (e.g., `Stage 2`, `structured-workflow-implement`, `explore sub-agent`).

## Best Practices and Design Guidelines

- Commit to Progressive Disclosure
  - To protect the LLM's context window, keep Knowledge/Transform `SKILL.md` bodies under 200 lines.
  - To protect the LLM's context window, keep Workflow `SKILL.md` bodies under 300 lines.
  - If any single section exceeds 30 lines or includes large prompts/data, extract content to `references/` or `assets/`.
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
  `task()` calls. This prohibition applies to the entire skill package, including prompt
  templates in references/ and executable logic in scripts/. Sub-agents cannot call
  sub-agents. If sub-agent routing is needed,
  declare it in the main orchestrator skill.
- Constraints Requirement: Every delegation stage MUST include a `Faults`
  subsection written as plain-language bullets that state failure condition,
  fallback action, and whether execution continues or aborts.
- Multiple Failure Cases: A single stage's `Faults` subsection MAY contain
  multiple plain-language bullets, one per distinct failure condition.
- Placement Convention: Place `Faults` at the end of each numbered stage block, after the stage output description.
- Fallback Sub-Skill Delegation: When the fallback action delegates to a sub-skill, set the
  action field to the sub-skill name with a parenthesized argument summary.
  Do not chain more than one level of fallback delegation; if the fallback sub-skill fails, the decision must be abort.
- Examples Policy: Each workflow skill and each sub-skill it delegates to must include
  one happy-path example and one failure-path example.
- Examples Format: Use `## Examples` section with `### Happy Path` and `### Failure Path`
  subsections; limit each to 3-5 lines.
- Workflow skills using Layer 2 MUST include an Execution section with a call-order block
  using a `python` code fence and the 6-field stage template.
- Control Flow: Workflow skills requiring conditional stage transitions MUST place loop/branch
  logic in the `python` call-order block at the top of Execution. Do not place conditional
  logic as prose between stage definitions.
- Stage Template Requirement: ALWAYS use the 6-field stage template for each stage in the
  Execution section. ALWAYS use `yaml` code fences for Actions blocks in workflow stage templates:
  - Keep the heading short: `### Stage N: Name` (no purpose suffix).
  - Use a `Purpose` bullet as the first field for a one-sentence stage objective.
  - Use inline type annotations for Inputs and Outputs (e.g., `` `field: Type` ``).
  - Guards MUST remain as an independent field.
  - Faults MUST be present per stage with failure condition, fallback, and continue-or-abort.

  ````text
  ### Stage N: Name

  - Purpose: one-sentence stage objective
  - Inputs: `field: Type`, `field2: Type`
  - Actions:

    ```yaml
    - tool: skill
      name: "..."
      input: { ... }
    - tool: task
      agent_type: "..."
      prompt: "..."
    ```

  - Outputs: `field: Type`, `path/to/artifact`
  - Guards: condition required to proceed
  - Faults:
    - Describe each failure condition, fallback action, and continue-or-abort decision.
  ````

## Knowledge/Transform Skill Authoring

- Definition: A knowledge/transform skill executes a single bounded transformation or analysis.
  It does not call task() or delegate to other skills or agents.
- Trigger for Use: Apply this track when the skill body contains a single op chain with no delegation.
- Structure: Define one or more ops in sequence; each op has a clear input, action, and output.
  Do not add stage sequencing, delegation tables, or task() calls.
- Constraints Placement: Use the required `## Constraints` section for execution
  limits, retry policy, and abort conditions in plain language.
- Coordinator Restriction: No coordinator-only restrictions apply; a knowledge/transform skill
  may be invoked by any workflow skill or directly by the user.
- Examples Policy: Include one happy-path example and one failure-path example using the same
  `## Examples` section format with `### Happy Path` and `### Failure Path` subsections.
- Examples Format: Keep each happy-path and failure-path subsection to 3-5 lines.
- Execution section is optional; omit unless delegation is introduced. When operation
  sequencing is critical for correctness, state the execution order in a single line within
  the Overview section (e.g., `Execution order: op_a -> op_b -> op_c`).
- Contract Detail Placement: Document operation procedures in prose sections
  (`## Overview`, `## Constraints`, and optional `## Execution`), and keep
  TypeScript blocks for schema definitions only.

---
applyTo: ".config/copilot/skills/**,docs/templates/skill-workflow/**,docs/templates/skill-single-operation/**"
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

- Templates:
  - Workflow Orchestrator: [`docs/templates/skill-workflow/`](../../docs/templates/skill-workflow/SKILL.md)
  - Single-operation Skill: [`docs/templates/skill-single-operation/`](../../docs/templates/skill-single-operation/SKILL.md)

### Frontmatter Fields

- `name` (Required): 1-64 characters. Lowercase alphanumeric and hyphens only.
  Leading/trailing hyphens and consecutive hyphens are not allowed.
  Must exactly match the parent directory name.
- `description` (Required): 1-1024 characters.
  This field is the only trigger the AI uses to determine "when to invoke this Skill."
  Include clear trigger conditions: "what keywords the user might say" or "what type of task this applies to."
  The Markdown body is only loaded after the Skill is triggered, so writing "When to use this skill"
  in the body is meaningless.
  Sub-skill `description` MUST be one sentence, 10 words or fewer.
  MUST NOT include caller metadata (e.g., "This skill should be used only by...").
- `allowed-tools` (Optional): Space-separated list of tool identifiers.
  MCP tools use `server-name/tool-name` or `server-name/*` syntax.
- `user-invocable` (Required): `true` for orchestrators, `false` for sub-skills.
- `disable-model-invocation` (Required): `false` for all skills.

### Directory Scope Constraint

- A skill may only reference files inside its own `{skill-name}/` directory tree.
- NEVER create shared subdirectories directly under `.config/copilot/skills/`;
  only `{skill-name}/` directories are valid children -- files outside a skill directory
  are silently inaccessible.
- Shared reference material must be duplicated into each skill's own `references/` subdirectory.

### Output Safety

- `output_filepath` MUST NOT match any reference or input file path.

### References File Conventions

- NEVER wrap reference file content in a code block. The AI reads the file as raw text.
- NEVER use HTML tags (`<details>`, `<summary>`, etc.) in reference files. They are non-functional in CLI environments.
- Reference files MUST contain only format definitions and templates. Behavioral instructions MUST remain in SKILL.md.

### Placeholder Convention

- Use `{placeholder}` (curly braces) for template variables in SKILL.md and reference files.
- NEVER use `<placeholder>` (angle brackets) because it conflicts with HTML parsing.
- Exception: CLI command argument notation `<arg>` follows standard convention and is permitted.

### Body Structure

- State each piece of information exactly once, at the point where it is most relevant.
  NEVER duplicate the same information across multiple sections (e.g., describing input types
  in both a Schema section and a Stage Inputs field).

## Best Practices

- Commit to Progressive Disclosure
  - If any single section exceeds 30 lines or includes large prompts/data, extract content to `references/` or `assets/`.
  - Link from `SKILL.md` using relative paths and provide guidance on "when the AI should read that file"
    (e.g., `For detailed schema, see [schema.md](references/schema.md)`).
  - Include a Table of Contents at the beginning of reference files exceeding 300 lines.

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

### Autonomous Subagent Design

- Orchestrators provide the problem and infrastructure constraints.
  They MUST NOT dictate step-by-step procedures to subagents.
- Sub-skills frame instructions as best practices, not mandatory procedures. Only safety constraints are mandatory.
- Prompt templates in blockquotes describe WHAT to achieve, not HOW to achieve it.

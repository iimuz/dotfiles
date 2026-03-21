---
applyTo: ".config/copilot/skills/**,docs/templates/skill-workflow/**,docs/templates/skill-single-operation/**"
---

# Agent Skills Creation and Management Rules

## Official Documentation

When creating or modifying skill files, use a subagent to fetch the latest
specification from the official documentation and return the relevant
specification details:

- [Agent Skills Specification](https://agentskills.io/specification)
- [Create skills - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills)

If the fetch fails, follow the overview described below instead.

## Skill Specification Overview

- Each skill is placed in its own directory under `.config/copilot/skills/` and must include at least a `SKILL.md` file.
- Optional subdirectories: `scripts/`, `references/`, `assets/`.
- `SKILL.md` consists of YAML frontmatter and a Markdown body.
- Required frontmatter fields: `name`, `description`, `user-invocable`, `disable-model-invocation`.
- Optional frontmatter field: `allowed-tools` (space-separated tool identifiers).
- The `description` field is the only trigger the AI uses to determine when to invoke the skill. The Markdown body is only loaded after the skill is triggered.
- Templates:
  - Workflow Orchestrator: [`docs/templates/skill-workflow/`](../../docs/templates/skill-workflow/SKILL.md)
  - Single-operation Skill: [`docs/templates/skill-single-operation/`](../../docs/templates/skill-single-operation/SKILL.md)

## Project Policy

The following rules always apply regardless of whether the official
documentation was fetched. When they conflict with the official
documentation, these rules take precedence.

### Naming

- `name`: 1-64 characters, lowercase alphanumeric and hyphens only. No leading/trailing or consecutive hyphens. Must exactly match the parent directory name.
- Sub-skill `description` must be one sentence, 10 words or fewer. Must not include caller metadata (e.g., "This skill should be used only by...").

### Directory Scope Constraint

- A skill may only reference files inside its own `{skill-name}/` directory tree.
- Do not create shared subdirectories directly under `.config/copilot/skills/`. Only `{skill-name}/` directories are valid children. Files outside a skill directory are silently inaccessible.
- Shared reference material must be duplicated into each skill's own `references/` subdirectory.

### Output Safety

- `output_filepath` must not match any reference or input file path.

### References File Conventions

- Do not wrap reference file content in a code block. The AI reads the file as raw text.
- Do not use HTML tags (`<details>`, `<summary>`, etc.) in reference files. They are non-functional in CLI environments.
- Reference files must contain only format definitions and templates. Behavioral instructions must remain in SKILL.md.

### Placeholder Convention

- Use `{placeholder}` (curly braces) for template variables in SKILL.md and reference files.
- Do not use `<placeholder>` (angle brackets) because it conflicts with HTML parsing.
- Exception: CLI command argument notation `<arg>` follows standard convention and is permitted.

### Body Structure

- State each piece of information exactly once, at the point where it is most relevant. Do not duplicate the same information across multiple sections.

### Required Content

- Every skill must include: purpose and scope, abort conditions, and output format specification.
- Additional sections are chosen by the skill author based on the skill's purpose
  (Criteria, Operations, Rules, Input, Examples, etc.).
- Orchestrator-invoked sub-skills (`user-invocable: false`) may omit Input and Examples
  when the orchestrator's prompt template provides the parameter contract.
- Analysis-oriented skills may use domain-specific section names
  (Criteria, Rules, Checks) instead of Operations.

### Size Targets

- Single-operation skills: under 200 lines.
- Workflow orchestrator skills: under 300 lines.

### Notation

- Use inline `field: type` annotations for parameters.
  Avoid TypeScript code blocks unless schema is the primary deliverable.
- Session artifacts path: `~/.copilot/session-state/{session_id}/files/`.
- Run directory: `{session_dir}/YYYYMMDDHHMMSS-{skill-name}/`.
- Final output: `{session_dir}/YYYYMMDDHHMMSS-{skill-name}-{descriptor}.md`.

### Progressive Disclosure

- If any single section exceeds 30 lines or includes large prompts/data, extract content to `references/` or `assets/`.
- Link from `SKILL.md` using relative paths and provide guidance on when the AI should read that file.
- Include a Table of Contents at the beginning of reference files exceeding 300 lines.

### Skill Type Taxonomy

- Workflow Skill: Coordinates multi-step execution across sub-skills or agents. Owns stage sequencing, delegation, and fault routing.
- Knowledge/Transform Skill: Executes a single bounded transformation or analysis. Does not delegate to other skills or agents.
- Trigger for Workflow Authoring: Skill body contains stage sequencing, task() calls, or sub-skill delegation.
- Trigger for Knowledge/Transform Authoring: Skill body contains a single op chain with no delegation to other skills.

### Workflow Skill Authoring

- A workflow skill acts as the sole coordinator. It must not be invoked as a sub-skill by another workflow skill unless an explicit orchestrator-delegation contract is declared in both the parent and child SKILL.md.
- Invocation Separation: choose by delegation capability, not invocability labels.
  - Task-capable target (`task()` reachable directly or transitively in its skill-delegation graph) must be invoked via `skill()`.
  - Task-free target (no reachable `task()` in its delegation graph) may be invoked via `skill()` or from within `task()`.
  - If capability is unknown, treat as task-capable. Non-skill processing must use `task()`.
- Sub-agents invoked by sub-skills must not make further `task()` calls. This applies to the entire skill package including prompt templates in references/ and executable logic in scripts/. Sub-agents cannot call sub-agents. If sub-agent routing is needed, declare it in the main orchestrator skill.
- Blockquotes in workflow skills contain only subagent-facing prompts.
- Do not chain more than one level of fallback; if the fallback fails, abort.

### Autonomous Subagent Design

- Orchestrators provide the problem and infrastructure constraints. They must not dictate step-by-step procedures to subagents.
- Sub-skills frame instructions as best practices, not mandatory procedures. Only safety constraints are mandatory.
- Prompt templates in blockquotes describe what to achieve, not how to achieve it.

### Frontmatter Defaults

- `user-invocable`: `true` for orchestrators, `false` for sub-skills.
- `disable-model-invocation`: `false` for all skills.

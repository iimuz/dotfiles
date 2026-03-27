---
applyTo: ".config/copilot/skills/**"
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
- The `description` field is the only trigger the AI uses to determine when to invoke
  the skill. The Markdown body is only loaded after the skill is triggered.

## Project Policy

The following rules always apply regardless of whether the official
documentation was fetched. When they conflict with the official
documentation, these rules take precedence.

### Naming

- `name`: 1-64 characters, lowercase alphanumeric and hyphens only.
  No leading/trailing or consecutive hyphens. Must exactly match the parent directory name.
- Sub-skill `description` must be one sentence, 10 words or fewer.
  Must not include caller metadata (e.g., "This skill should be used only by...").

### Description for Model-Discovered Skills

When `disable-model-invocation` is false and the skill is not explicitly called
by an orchestrator, the description must serve as an effective trigger for
autonomous model invocation:

- Lead with a trigger phrase ("Must be used for...", "Use when...").
  Do not lead with a capability declaration ("Coordinator for...").
- Include keywords that match user requests: action verbs users actually say
  ("get", "retrieve", "debug") and domain terms (specific service or tool names).
- Target 15-25 words. Below 10 words risks missing trigger keywords.

### Directory Scope Constraint

- A skill may only reference files inside its own `{skill-name}/` directory tree.
- Do not create shared subdirectories directly under `.config/copilot/skills/`.
  Only `{skill-name}/` directories are valid children.
  Files outside a skill directory are silently inaccessible.
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

### Domain Logic

- Skills that perform judgment, evaluation, or analysis should include a domain
  section (Criteria, Rules, Checks, or equivalent) between Overview and Output
  that externalizes the evaluation logic. The domain section should state the
  decision standards, prioritization rules, and rejection or abstention conditions
  needed to produce consistent output. An I/O contract alone is insufficient when
  the skill's value depends on how it evaluates, not just what it receives and
  produces.

### Size Targets

- Single-operation skills: under 200 lines.
- Workflow orchestrator skills: under 300 lines.

### Progressive Disclosure

- Extract content to `references/` or `assets/` when a section contains large prompts,
  data, or format definitions that are better served as standalone files.
- Link from `SKILL.md` using relative paths and provide guidance on when the AI should read that file.
- Include a Table of Contents at the beginning of reference files exceeding 300 lines.

### Workflow Skill Authoring

- A workflow skill acts as the sole coordinator. It must not be invoked as a sub-skill
  by another workflow skill unless an explicit orchestrator-delegation contract is declared
  in both the parent and child SKILL.md.
- Invocation Separation: choose by delegation capability, not invocability labels.
  - Task-capable target (`task()` reachable directly or transitively in its
    skill-delegation graph) must be invoked via `skill()`.
  - Task-free target (no reachable `task()` in its delegation graph) may be invoked
    via `skill()` or from within `task()`.
  - If capability is unknown, treat as task-capable. Non-skill processing must use `task()`.
- Sub-agents invoked by sub-skills must not make further `task()` calls.
  This applies to the entire skill package including prompt templates in references/
  and executable logic in scripts/. Sub-agents cannot call sub-agents.
  If sub-agent routing is needed, declare it in the main orchestrator skill.
- Blockquotes in workflow skills contain only subagent-facing prompts.
- Do not chain more than one level of fallback; if the fallback fails, abort.

### Autonomous Subagent Design

- Orchestrators provide the problem and infrastructure constraints. They must not dictate step-by-step procedures to subagents.
- Sub-skills frame instructions as best practices, not mandatory procedures. Only safety constraints are mandatory.
- Prompt templates in blockquotes describe what to achieve, not how to achieve it.

### Canonical Examples

When creating or modifying skills, refer to existing skills as authoritative examples:

- Single-operation (analysis): `.config/copilot/skills/adr-extract/SKILL.md`
- Single-operation (utility): `.config/copilot/skills/commit-staged/SKILL.md`
- Workflow orchestrator: `.config/copilot/skills/code-review/SKILL.md`

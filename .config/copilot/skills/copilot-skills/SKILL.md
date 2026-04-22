---
name: copilot-skills
description: >-
  Use when creating or modifying skill files in .config/copilot/skills/ to
  enforce specification compliance and project policy rules.
user-invocable: true
disable-model-invocation: false
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

### Description for Model-Discovered Skills

When `disable-model-invocation` is false and the skill is not explicitly called
by an orchestrator:

- Sub-skill `description` must be one sentence, 10 words or fewer.
  Must not include caller metadata (e.g., "This skill should be used only by...").
- Lead with a trigger phrase ("Must be used for...", "Use when...").
  Do not lead with a capability declaration ("Coordinator for...").
- Target 15-25 words. Below 10 words risks missing trigger keywords.

### References File Conventions

- Do not wrap reference file content in a code block. The AI reads the file as raw text.
- Do not use HTML tags (`<details>`, `<summary>`, etc.) in reference files. They are non-functional in CLI environments.
- When referencing files in `references/`, use relative Markdown link syntax: `[filename](references/filename.md)`.

### Workflow Skill Authoring

- Orchestrators describe the goal and constraints, not step-by-step procedures.
- Blockquotes in workflow skills contain only subagent-facing prompts.
- Do not chain more than one level of fallback; if the fallback fails, abort.

### Canonical Examples

When creating or modifying skills, refer to existing skills as authoritative examples:

- Single-operation (analysis): `.config/copilot/skills/adr-manage/SKILL.md`
- Single-operation (utility): `.config/copilot/skills/git-commit/SKILL.md`
- Workflow orchestrator: `.config/copilot/skills/code-review/SKILL.md`

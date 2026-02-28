---
applyTo: ".config/copilot/skills/**"
---

# Agent Skills Creation and Management Rules

- Directive: Proactively support the user in creating new Skills or testing and improving existing ones.

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
---
```

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

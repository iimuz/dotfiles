---
applyTo: ".github/copilot-instructions.md,.github/instructions/**"
---

# Rule Generation & Maintenance Guidelines

## Trigger

- Condition: Creates, edits, or reviews files in `copilot-instructions.md` or `.github/instructions/`.

## Protocol

- Minimalism: NEVER use lengthy explanations. Use short bullet points ONLY.
- Imperative Language: NEVER use "It is recommended to...". ALWAYS use strong commands like "ALWAYS" and "NEVER".
- Template Compliance: ALWAYS specify `applyTo:` in the YAML frontmatter to limit target files
  when creating individual rules.

---
applyTo: ".github/copilot-instructions.md,.github/instructions/**"
---

# Rule Generation & Maintenance Guidelines

## Trigger

This rule applies ONLY when creating, editing, or reviewing files in `copilot-instructions.md` or `.github/instructions/`.

## ALWAYS

Follow this strict protocol when creating or updating rule files:

- Ruthless Minimalism: NEVER use lengthy explanations. Use short bullet points ONLY.
- Imperative Language: NEVER use "It is recommended to...". ALWAYS use strong commands like "ALWAYS" and "NEVER".
- Strict Template: When creating individual rules (`.github/instructions/*.md`),
  ALWAYS specify `applyTo:` in the YAML frontmatter to limit target files.

---
name: standards-doc
description: >-
  Use when writing or updating documentation, instruction files, or Markdown files
  to enforce syntax, naming, and file registry conventions.
user-invocable: true
disable-model-invocation: false
---

# Doc Standards

## Syntax Rules

- Use Markdown headers (##) to organize sections.
- Write content as plain sentences or bullet lists. Choose the format that best communicates each piece of information.
- Use hyphen (-) for all bullet lists.
- Do not use bold or italic markup.
- Do not use tables. Use bullet lists or plain sentences instead.
- Do not use horizontal rules (---) to separate content. Use headers to organize sections.
- Separate sections with a blank line after each header.
- Use Mermaid code blocks for diagrams within Design files.
- Use TypeScript Interface code blocks for models within Design files.
- When updating documents, overwrite existing state. Append logs only if specified.

## Naming Conventions

- Headers and Keys: Title Case with spaces (e.g., Syntax Rules, Package Manager, Last Run).
- Values: Sentence case or lowercase. Use exact match only for code variables.
- Acronyms: Standard capitalization (e.g., macOS, ARM64, WSL).
- File Names: kebab-case with .md extension.
- Separator: Spaces for document text, hyphens for file names.

## File Registry

- Type: Design
  - Pattern: `[topic].md`
  - Template: [references/design.md](references/design.md)
  - Directory: `docs/design/`
  - Example: core-beliefs.md
- Type: Report
  - Pattern: `[YYYY-MM-DD]-[topic].md`
  - Template: [references/report.md](references/report.md)
  - Directory: `docs/reports/`
  - Example: 2024-03-20-skill-interface-style.md

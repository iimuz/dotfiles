---
name: standards-doc
description: >-
  Use when writing, updating, or creating any Markdown file.
  Applies to all documentation including design docs and reports.
user-invocable: true
disable-model-invocation: false
---

# Doc Standards

## Syntax Rules

- Use Markdown headers (##) to organize sections.
- Use hyphen (-) for all bullet lists.
- Do not use bold, italic, tables, or horizontal rules.
- Use Mermaid code blocks for diagrams.
- Use TypeScript Interface code blocks for models.
- When updating documents, overwrite existing state unless append is specified.

## Naming Conventions

- Headers: Title Case with spaces.
- File names: kebab-case with .md extension.

## File Registry

- Type: Design
  - Pattern: `[topic].md`
  - Template: [references/design.md](references/design.md)
  - Directory: `docs/design/`
- Type: Report
  - Pattern: `[YYYY-MM-DD]-[topic].md`
  - Template: [references/report.md](references/report.md)
  - Directory: `docs/reports/`

# DOC_STANDARDS

## SYNTAX_RULES

- Format: Markdown Headers (##) + Key-Value pairs.
- Style: Plain text only. NO bold (\*_), NO italics (_).
- Lists: Use hyphen (-) for all arrays and properties.
- Newline: Strict Bullet List or Header separation. No free-text paragraphs.
- Diagram: Use Mermaid code blocks within Design files.
- Model: Use TypeScript Interface code blocks within Design files.
- UpdatePolicy: Overwrite existing state. Append logs only if specified.

## NAMING_CONVENTIONS

- Case: kebab-case
- Extension: .md
- Separator: hyphen (-)
- Keys: PascalCase (e.g., PackageManager, LoadingOrder, LastRun)

## FILE_REGISTRY

- Type: Plan
  - Pattern: [YYYY-MM-DD]-[action].md
  - Template: docs/templates/plan.md
  - Example: 2024-03-20-add-login.md

- Type: ADR
  - Pattern: [000-Index]-[slug].md
  - Template: docs/templates/adr.md
  - Example: 001-init-stack.md

- Type: Design
  - Pattern: [topic].md
  - Template: N/A
  - Example: core-beliefs.md

- Type: Quality
  - Pattern: quality.md
  - Template: docs/templates/quality.md
  - Scope: Singleton (Update only)

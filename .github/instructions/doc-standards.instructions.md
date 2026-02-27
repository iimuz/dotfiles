---
applyTo: ".github/copilot-instructions.md,.github/instructions/**/*.md,docs/adr/**/*.md,docs/debt/**/*.md,docs/design/**/*.md,docs/plans/**/*.md"
---

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

- Headers & Keys: Title Case with spaces (e.g., Syntax Rules, Package Manager, Last Run).
- Values: Sentence case or lowercase. Use exact match only for code variables.
- Acronyms: Standard capitalization (e.g., macOS, ARM64, WSL).
- File Names: kebab-case with .md extension.
- Separator: Spaces for document text, hyphens for file names.

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
- Type: Debt
  - Pattern: [slug].md
  - Template: docs/templates/debt.md
  - Directory: docs/debt/open/ (active) or docs/debt/resolved/ (closed)

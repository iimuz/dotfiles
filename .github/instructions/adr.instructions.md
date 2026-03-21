---
applyTo: "docs/adr/**"
---

# ADR Files

## Template Compliance

- Frontmatter requires the following keys with no additional keys permitted:
  - `id`: Zero-padded 4-digit string.
  - `status`: One of `Proposed`, `Accepted`, `Deprecated`, `Superseded`, or `Rejected`.
  - `date`: ISO 8601 date.
  - `supersedes`: Array of ADR IDs. Empty array if none.
- Required sections in order: `## Context`, `## Decision`, `## Consequences`. Do not remove, rename, or reorder these sections.

## Lifecycle

- Do not modify the content of an Accepted ADR. To change a decision, create a new ADR that supersedes the old one.
- Status transitions:
  - `Proposed` to `Accepted` or `Rejected`.
  - `Accepted` to `Deprecated` or `Superseded`.
  - No other transitions are permitted.
- On supersede: Create a new ADR with the `supersedes` field referencing the
  old ADR ID. Update the old ADR status to `Superseded`. Status change is the
  only permitted edit to an Accepted ADR.
- On deprecate: Set status to `Deprecated`. Status change is the only permitted edit to an Accepted ADR.
- Only the user decides when status changes. Do not change ADR status without explicit user instruction.

## Naming Convention

- Pattern: `[0000-Index]-[slug].md` (e.g., `0001-use-postgresql.md`).
- Location: `docs/adr/` for all ADR files.
- Use the next sequential number. Check existing files to determine the next available ID.

## Content Rules

- Context: Explain why the decision was needed. Include background,
  constraints, and alternatives considered. Alternatives with their
  trade-offs provide transparency into the decision process.
- Decision: State the decision and the rationale clearly. Be specific about
  what was chosen.
- Consequences: Document what happens as a result. Include positive
  outcomes, negative trade-offs, and risks. Be honest about downsides.

## When to Write an ADR

- Would an AI agent, asked to "clean up" the codebase, break this decision
  and cause bugs or cost increases? If yes, write an ADR.
- Was this decision learned through a past incident, failure, or painful experience? If yes, write an ADR.
- Can a `// WHY:` comment above the relevant code convey the rationale
  sufficiently? If yes, skip the ADR and use an inline comment instead.

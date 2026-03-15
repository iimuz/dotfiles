---
applyTo: "docs/adr/**"
---

# ADR Files

## Template Compliance

- Frontmatter: Required keys `id` (zero-padded 4-digit string), `status`
  (value: `Proposed`, `Accepted`, `Deprecated`, `Superseded`, or `Rejected`),
  `date` (ISO 8601 date), `supersedes` (array of ADR IDs, empty if none).
  No additional keys.
- Sections: Required in order `## Context`, `## Decision`, `## Consequences`.
  Required sections MUST NOT be removed, renamed, or reordered.

## Lifecycle

- Immutability: NEVER modify the content of an Accepted ADR.
  To change a decision, create a new ADR that supersedes the old one.
- Status Transitions: `Proposed` -> `Accepted` or `Rejected`.
  `Accepted` -> `Deprecated` or `Superseded`. No other transitions.
- On Supersede: Create a new ADR with the `supersedes` field referencing
  the old ADR ID. Update the old ADR status to `Superseded`.
  Status change is the only permitted edit to an Accepted ADR.
- On Deprecate: Set status to `Deprecated`. Status change is the only permitted edit to an Accepted ADR.
- Ownership: ONLY the user decides when status changes. NEVER change ADR status without explicit user instruction.

## Naming Convention

- Pattern: `[0000-Index]-[slug].md` (e.g., `0001-use-postgresql.md`).
- Location: `docs/adr/` for all ADR files.
- ID Assignment: Use the next sequential number. Check existing files to determine the next available ID.

## Content Rules

- CONTEXT: Explain why the decision was needed. Include background, constraints,
  and alternatives considered. Alternatives with their trade-offs provide
  transparency into the decision process.
- DECISION: State the decision and the rationale clearly. Be specific about what was chosen.
- CONSEQUENCES: Document what happens as a result. Include positive outcomes,
  negative trade-offs, and risks. Be honest about downsides.

## When to Write an ADR

- Test 1 (AI Optimization): Would an AI agent, asked to "clean up" the codebase,
  break this decision and cause bugs or cost increases? If yes, write an ADR.
- Test 2 (Painful Lesson): Was this decision learned through a past incident,
  failure, or painful experience? If yes, write an ADR.
- Test 3 (Inline Sufficiency): Can a `// WHY:` comment above the relevant code
  convey the rationale sufficiently? If yes, skip the ADR and use an inline
  comment instead.

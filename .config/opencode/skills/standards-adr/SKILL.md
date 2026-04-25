---
name: standards-adr
description: >-
  Use when creating, updating, or reviewing ADRs to enforce template compliance
  and lifecycle rules.
---

# ADR Manage

Enforce ADR template compliance and lifecycle rules for all ADR operations.

ADR template: [references/template.md](references/template.md).
ADR files live in `docs/adr/`.

## Create

1. Determine next sequential ID: check existing files in `docs/adr/` to find the highest number, then increment.
2. Name the file: `NNNN-slug.md` (e.g., `0001-use-postgresql.md`).
3. Copy template from [references/template.md](references/template.md).
4. Fill in frontmatter: `id` (zero-padded 4-digit string), `status: Proposed`, `date` (ISO 8601), `supersedes: []`.
5. Write content per the Content Rules below.

## Update Status

Only the user decides when status changes. Do not change ADR status without explicit user instruction.

Permitted transitions:

- `Proposed` → `Accepted` or `Rejected`
- `Accepted` → `Deprecated` or `Superseded`
- No other transitions permitted.

On supersede:

1. Create a new ADR that references the old ID in its `supersedes` field.
2. Update the old ADR `status` to `Superseded`. This is the only permitted edit to an Accepted ADR.

On deprecate:

- Set `status` to `Deprecated`. This is the only permitted edit to an Accepted ADR.

## Review

Check the following for any ADR file:

- Frontmatter keys: only `id`, `status`, `date`, `supersedes` are permitted.
- `id`: zero-padded 4-digit string matching the filename index.
- `status`: one of `Proposed`, `Accepted`, `Deprecated`, `Superseded`, `Rejected`.
- `date`: ISO 8601 format.
- `supersedes`: array (empty array `[]` if none).
- Sections present in order: `## Context`, `## Decision`, `## Consequences`. No renames, no reorders, no omissions.
- Content of Accepted, Deprecated, or Superseded ADRs must not be modified (status field only).

## Content Rules

- Context: explain why the decision was needed. Include background, constraints, and alternatives with trade-offs.
- Decision: state what was chosen and the rationale. Be specific.
- Consequences: document positive outcomes, negative trade-offs, and risks. Be honest about downsides.

## When to Write an ADR

Write an ADR when either of these is true:

- An AI agent asked to "clean up" the codebase would break this decision and cause bugs or cost increases.
- This decision was learned through a past incident, failure, or painful experience.

Skip the ADR and use a `// WHY:` inline comment when that comment alone conveys the rationale sufficiently.

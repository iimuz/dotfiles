---
name: standards-adr
description: >-
  Use when creating or updating ADR files in docs/adr/.
  Also use when making an architectural decision to evaluate
  whether an ADR should be written.
---

# ADR Standards

## When to Write

- An AI agent asked to "clean up" the codebase would break this decision.
- The decision was learned through a past incident or failure.
- If a `// WHY:` inline comment alone conveys the rationale, skip the ADR.

## Create

1. Search existing ADRs in `docs/adr/` (titles and content) for the same or an
   overlapping decision. If one exists, update it or ask the user to
   supersede it instead of creating a duplicate.
2. Find the highest ID in `docs/adr/`, increment by one.
3. Name: `NNNN-slug.md`
4. Copy [references/template.md](references/template.md) and fill in content.

## Update Status

Only the user decides status changes.

Permitted transitions:

- `Proposed` → `Accepted` or `Rejected`
- `Accepted` → `Deprecated` or `Superseded`

On supersede: Create a new ADR with old ID in `supersedes`. Set old ADR to `Superseded`.
On deprecate: Set old ADR to `Deprecated`.

Status is the only permitted edit to an Accepted ADR.

## Cross-Repository References

- Same repository: refer to ADRs as `ADR-NNNN`.
- Other repositories: refer to ADRs as `owner/repo#ADR-NNNN`.

## Writing Style

- Write section headings in English; write the ADR title and body text in Japanese.
- Describe considered options and their trade-offs inside the Context section.
  Do not add a separate options section.

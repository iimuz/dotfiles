---
name: adr-extract
description: >-
  Use when the user asks to create an ADR, record a decision, or extract
  decisions from plans or code changes.
user-invocable: true
disable-model-invocation: false
---

# Extract ADR

## Overview

Extract a technical or architectural decision from provided context and produce
an ADR file following the repository template and instructions.

Execution order: resolve ID -> analyze context -> draft ADR -> write file.

## Input

- `context: string` (required): The source material containing the decision. This may be
  a plan file path, conversation summary, code diff, or free-form description from the user.
- `title: string`: Short title for the ADR. If not provided, derive from context.
- `status: string`: Initial status. Defaults to `Proposed`. Must be one of
  `Proposed`, `Accepted`, `Deprecated`, `Superseded`, `Rejected`.
- `supersedes: string[]`: Array of ADR IDs this decision supersedes. Defaults to empty.

## Output

- `filepath: string`: Path to the created ADR file under `docs/adr/`.
- `id: string`: The assigned ADR ID (zero-padded 4-digit string).

## Operations

### Resolve ID

List existing files in `docs/adr/` to determine the next sequential ID.
If the directory does not exist, create it and assign ID `0001`.
Zero-pad the ID to 4 digits.

### Analyze Context

Read the provided context material and identify:

- Why the decision was needed (background, constraints, alternatives considered).
- What was decided and the rationale.
- What consequences follow (positive, negative, risks).

Apply the three ADR tests from [`adr.instructions.md`](../../../../.github/instructions/adr.instructions.md)
to confirm the decision warrants an ADR rather than an inline comment.
If test 3 (Inline Sufficiency) suggests an inline comment is enough, inform the user
and ask whether to proceed.

### Draft ADR

Read the template at [`docs/templates/adr.md`](../../../../docs/templates/adr.md) and produce
the ADR content:

- Fill frontmatter: id, status, date (today), supersedes.
- Write Context section from the analysis.
- Write Decision section with the chosen option and rationale.
- Write Consequences section covering positive, negative, and risks.

Keep the ADR concise: target 1-2 pages maximum.

### Write File

Save the ADR to `docs/adr/{id}-{slug}.md` where slug is derived from the title
in kebab-case. If `supersedes` is non-empty, update each superseded ADR file
to set its status to `Superseded`.

## Examples

- Happy: User says "record the decision to use Zustand over Redux" -- ADR created
  at `docs/adr/0003-use-zustand.md` with context, decision, and consequences.
- Inline: User asks to record a minor config choice -- test 3 triggers, user is asked
  whether an inline comment suffices.
- Supersede: User says "supersede ADR-0001 with a new caching strategy" -- new ADR created
  with `supersedes: ["0001"]`, old ADR status updated to `Superseded`.

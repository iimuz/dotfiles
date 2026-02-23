---
status: DONE
---

# TASK: Add plan.instructions.md

## GOAL

- Goal: Create `.github/instructions/plan.instructions.md` with `applyTo: "docs/plans/**"` to
  enforce template compliance when AI agents create or edit plan files.

## REF

- `docs/templates/plan.md`
- `docs/design/doc-standards.md`
- `.github/instructions/tool-configuration.instructions.md`

## STEPS

- [x] Step 1: Read `docs/templates/plan.md` to confirm required structure.
- [x] Step 2: Create `.github/instructions/plan.instructions.md` with `applyTo: "docs/plans/**"`,
      listing all template compliance rules.

## VERIFY

- Verify: `.github/instructions/plan.instructions.md` exists and `applyTo` is set to `"docs/plans/**"`.

## SCRATCHPAD

- Motivation: `core-beliefs.md` ROUTING declares `docs/templates/` as DocumentTemplates location,
  but no enforcement mechanism existed. AI agents defaulted to enterprise-style formats from
  training data instead.
- Approach: `.github/instructions/` files are automatically applied to matching paths by Copilot agents.
- Council finding: Instructions file is Layer 4 (prevention), not enforcement. Combine with
  shell validator (Layer 1-3) for full coverage.

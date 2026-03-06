---
status: IN_PROGRESS
---

# TASK: Fix skill SKILL.md compliance with skills.instructions.md

## Goal

- Goal: Update structured-workflow and structured-workflow-implement SKILL.md files to fully
  comply with skills.instructions.md rules.

## Ref

- `.config/copilot/skills/structured-workflow/SKILL.md`
- `.config/copilot/skills/structured-workflow-implement/SKILL.md`
- `.github/instructions/skills.instructions.md`

## Steps

- [ ] Step 1: Fix structured-workflow/SKILL.md - remove operational constraints prose from Overview
- [ ] Step 2: Fix structured-workflow/SKILL.md - add @invariant tags to Interface below declare function
- [ ] Step 3: Fix structured-workflow/SKILL.md - remove conditional loop exit logic from Execution prose
- [ ] Step 4: Verify structured-workflow-implement/SKILL.md is already compliant (no changes needed)
- [ ] Step 5: Run lint/format and commit

## Verify

- Verify: `mise run lint` passes with no errors.

## Scratchpad

Violations found in structured-workflow/SKILL.md:

1. Operational constraints documented as prose bullet list in Overview instead of @invariant tags in Interface.
   Rule: "ALWAYS place @fault and @invariant tags as comments directly below each declare function."
2. "Loop exits when `!has_critical_or_high || iteration >= 3`." is conditional logic in prose after the
   python call-order block. Rule: "Do not place conditional logic as prose between stage definitions."

structured-workflow-implement/SKILL.md: No violations found. Already compliant.

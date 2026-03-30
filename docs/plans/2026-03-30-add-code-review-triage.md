---
issue:
---

# TASK: Add Code Review Triage Stage

## Goal

Add Stage 5 (Triage) to code-review skill to classify findings into Recommended/Consider tiers.

## Ref

- `.config/copilot/agents/code-review-triage.md` (new)
- `.config/copilot/agents/code-review-consolidate.md`
- `.config/copilot/skills/code-review/SKILL.md`
- `.github/instructions/custom-agents.instructions.md`

## Steps

- [ ] Step 1: PHASE-1 — Create code-review-triage agent (TASK 1-4)
- [ ] Step 2: PHASE-2 — Add Agreement/Severity metadata to consolidate + wire Stage 5 (TASK 5-11)
- [ ] Step 3: PHASE-3 — Add triage statistics, triage reason, edge cases (TASK 12-14)
- [ ] Step 4: Run mise run lint and mise run format
- [ ] Step 5: Commit

## Verify

`mise run lint && mise run format` passes with zero errors.

## Log

Append-only record of decisions and findings during execution.

- Implementation plan generated via 4-stage multi-model process (2 drafts, 2 reviews, resolution, synthesis).
- Key decisions: HIGH/CRITICAL non-demotable, fallback on Stage 5 failure,
  cross-check does not inflate agreed_by, agent-first phase ordering.

## Scratchpad

Full implementation plan at: ~/.copilot/session-state/75580b8a-74d9-4343-9076-65b15c51199f/files/20260330010116-implementation-plan.md

---
status: DONE
---

# TASK: update-gpt-5-4-model-selection

## Goal

- Goal: Update the repository model-selection policy and skill definitions to
  replace the GPT slot from `gpt-5.3-codex` to `gpt-5.4`.

## Ref

- `.config/copilot/copilot-instructions.md`
- `.config/copilot/agents/orchestrator.md`
- `.config/copilot/skills/task-coordinator-plan/references/plan-schema.md`
- `.config/copilot/skills/task-coordinator-plan/references/planner-protocol.md`
- `.config/copilot/skills/task-coordinator-plan/SKILL.md`
- `.config/copilot/skills/resolve-comments/SKILL.md`
- `.config/copilot/skills/council/SKILL.md`
- `.config/copilot/skills/code-review/SKILL.md`
- `.config/copilot/skills/implementation-plan/SKILL.md`

## Steps

- [x] Step 1: Run baseline verification commands before editing.
- [x] Step 2: Update policy and schema/reference files for the GPT model slot.
- [x] Step 3: Update skill files that hardcode the GPT model slot.
- [x] Step 4: Run verification commands after editing and inspect the final diff.

## Verify

- Verify: Run `mise run lint && mise run format`.

## Summary

The GPT model slot was updated consistently from `gpt-5.3-codex` to `gpt-5.4`
across the policy table, the task-coordinator planning schema/reference files,
and the skill files that hardcode the GPT member of the triad or the single
committer role. The main issue during verification was a formatter rewrite of
the `AllowedModel` union in `plan-schema.md`, which was reviewed and accepted
because it preserved the intended schema meaning while keeping the model list
consistent. Final verification completed successfully with `mise run format`
and `mise run lint`, and the remaining worktree changes are limited to the
intended edited files plus this active plan file.

## Scratchpad

- Description: Implement the council recommendation as a full GPT-slot
  replacement while keeping Claude and Gemini assignments unchanged.
- Finding: `mise run lint` and `mise run format` completed successfully before
  edits, and no tracked-file changes were present afterward.
- Finding: All `gpt-5.3-codex` references under `.config/copilot/` were
  replaced with `gpt-5.4`, while Claude and Gemini assignments were left
  unchanged.

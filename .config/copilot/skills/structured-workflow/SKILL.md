---
name: structured-workflow
description: Orchestrates Plan, Implement, Review, and Commit phases with user confirmations at each transition. Use when coordinating implementation-plan, code-review, and commit-staged skills together.
---

# Structured Workflow

Orchestrates a 4-phase development workflow (Plan -> Implement -> Review -> Commit) by coordinating sub-skills with user confirmation checkpoints between phases.

## Language Rule

User-facing plan summaries and review summaries must be in Japanese. This does not apply to commit messages or code, which follow their own conventions.

## Workflow

Execute phases sequentially. Use `ask_user` to get user approval before advancing to the next phase. If the user requests changes, revise and re-confirm before proceeding.

### Phase 1: Plan

1. Invoke the `implementation-plan` skill to generate an implementation plan
2. Summarize the plan for the user
3. Get user approval via `ask_user` before proceeding

### Phase 2: Implement

1. Read the approved plan from the session state file generated in Phase 1
2. Execute each step of the plan
3. Confirm with the user via `ask_user` when implementation is complete

### Phase 3: Review

1. Invoke the `code-review` skill to review all changes
2. Summarize review findings for the user
3. Fix any issues found, then get user approval via `ask_user`
4. If fixes were made, re-run the review (max 3 iterations). If issues persist after 3 rounds, report remaining items to the user and ask how to proceed

### Phase 4: Commit

1. Invoke the `commit-staged` skill, which handles staging and committing. Group changes into logical units if multiple commits are appropriate
2. Get final user confirmation via `ask_user`

## Error Handling

If a skill invocation fails or a build/test breaks, stop the workflow immediately, report the issue to the user, and confirm the recovery approach via `ask_user` before continuing. Do not proceed to the next phase while a critical error is unresolved.

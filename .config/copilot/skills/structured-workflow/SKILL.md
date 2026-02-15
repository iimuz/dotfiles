---
name: structured-workflow
description: Orchestrates Plan, Implement, Review, and Commit phases without user confirmations. This skill should be used when coordinating implementation-plan, code-review, and commit-staged skills in an automated iterative workflow.
---

# Structured Workflow

Orchestrates a 5-phase development workflow (Plan -> Implement -> Commit -> Review -> Final Summary) with automatic iteration. The loop (Implement -> Commit -> Review) repeats up to 3 times to fix Critical and High severity issues identified during code review.

## Language Rule

User-facing plan summaries and review summaries must be in Japanese. This does not apply to commit messages or code, which follow their own conventions.

## Workflow

Execute phases sequentially without user confirmations between phases. The workflow consists of an initial planning phase followed by an iterative implementation-commit-review cycle.

### Phase 1: Plan

1. Invoke the `implementation-plan` skill to generate an implementation plan
2. Summarize the plan for the user in Japanese
3. Proceed automatically to Phase 2 without user confirmation

### Implementation Loop (max 3 iterations)

Execute the following cycle up to 3 times:

#### Phase 2: Implement (Iteration N)

1. On first iteration: Read the approved plan from the session state file generated in Phase 1
2. On subsequent iterations: Implement fixes ONLY for Critical and High severity issues that are directly related to achieving the Phase 1 plan. Do NOT fix pre-existing code issues unrelated to the current implementation goal. These should be addressed in separate PRs.
3. Execute implementation steps completely

#### Phase 3: Commit (Iteration N)

1. Invoke the `commit-staged` skill to create a conventional commit
2. Each iteration should produce a complete, meaningful commit (not WIP or fixup commits)
3. Commit message should reflect the work done in this iteration

#### Phase 4: Review (Iteration N)

1. Invoke the `code-review` skill to review all changes made so far (cumulative)
2. Analyze the review results to identify Critical and High severity issues
3. Summarize review findings in Japanese, categorizing issues by severity
4. If Critical or High severity issues exist and iterations remain (N < 3):
   - Continue to next iteration (Phase 2)
5. If iteration limit reached (N = 3) or no Critical/High severity issues remain:
   - Proceed to Phase 5 (Final Summary)

### Phase 5: Final Summary

1. Create a comprehensive summary in Japanese containing:
   - **修正完了した指摘**: List of Critical and High severity issues that were fixed during iterations
   - **未修正の指摘**: List of remaining issues (Medium, Low severity, or Critical/High that couldn't be fixed within 3 iterations)
   - **イテレーション履歴**: Brief summary of what was done in each iteration (implementation → commit → review)
   - **推奨事項**: Recommendations for addressing unfixed issues (if any)

2. Use `ask_user` to confirm workflow completion and ask if any remaining issues should be addressed

## Error Handling

If a skill invocation fails or a build/test breaks, stop the workflow immediately and report the issue to the user with context. Do not proceed while a critical error is unresolved. The workflow does not use `ask_user` for phase transitions, but should use it for error recovery decisions.

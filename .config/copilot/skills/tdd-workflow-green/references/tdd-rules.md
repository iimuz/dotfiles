# TDD Green Rules

## Purpose

- Define strict Green-phase constraints for minimal, behavior-focused implementation.

## Constraints

- Require verified Red failure proof before any production code change.
- Write only the minimum production code needed to satisfy the failing test.
- Do not add unrelated behavior, refactors, or speculative enhancements.
- Keep edits scoped to the implementation file targeted by the test.
- Run the provided test command after implementation.
- Confirm all tests pass; partial pass is not acceptable.
- Abort Green execution if Red proof is missing.
- Abort Green execution if tests still fail.
- Abort Green execution if unrelated behavior is introduced.

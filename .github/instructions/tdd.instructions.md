---
applyTo: "dummy/**"
---

# TDD

## Iron Law

- NEVER write production code without a failing test. No exceptions.
- Write code before its test? Delete it. Start over.

## Red-Green-Refactor Workflow

- ALWAYS write one failing test before writing production code.
- ALWAYS verify the test fails for the expected reason before implementation.
- ALWAYS write the minimal production code required to make the test pass.
- NEVER add unrelated behavior during the green phase.
- ALWAYS refactor only after tests are green.
- ALWAYS keep behavior unchanged during refactor.
- ALWAYS repeat the cycle for each behavior change.

## Test Quality

- Minimal: ALWAYS keep each test focused on one behavior.
- Clear: ALWAYS use test names that describe observable behavior.
- Shows Intent: ALWAYS show intent through inputs, outputs, and side effects.
- ALWAYS test through public interfaces.
- NEVER rely on unclear names, broad setup, or multi-purpose assertions.

## Anti-Patterns

- NEVER mock implementation details or internal calls as primary assertions.
- NEVER test private fields, private methods, or internal data structures.
- NEVER add production methods intended only for tests.
- NEVER over-mock fast in-process dependencies.
- NEVER build excessive fixture setup that hides test intent.
- ALWAYS mock only external dependencies when unavoidable.
- ALWAYS prefer observable behavior over interaction-count assertions.

## Verification

- ALWAYS ensure every new function/method has a test.
- ALWAYS watch each test fail before implementing.
- ALWAYS ensure each test failed for the expected reason.
- ALWAYS write minimal code to pass.
- ALWAYS ensure all tests pass and output is pristine.
- ALWAYS ensure tests use real code and cover edge cases.
- NEVER proceed when any check is unchecked; TDD was skipped. Start over.

## Exceptions

- NEVER require TDD for documentation, configuration, or non-code file edits.

---
name: tdd
description: >-
  Use when implementing new features or fixing bugs to enforce test-driven
  development red-green-refactor workflow and anti-patterns.
user-invocable: true
disable-model-invocation: false
---

# TDD

## Iron Law

Do not write production code without a failing test. No exceptions. If code is
written before its test, delete it and start over.

## Red-Green-Refactor Workflow

1. Write one failing test before writing production code.
2. Verify the test fails for the expected reason before implementation.
3. Write the minimal production code required to make the test pass. Do not add unrelated behavior during this phase.
4. Refactor only after tests are green. Keep behavior unchanged during refactor.
5. Repeat the cycle for each behavior change.

## Test Quality

- Keep each test focused on one behavior.
- Use test names that describe observable behavior.
- Show intent through inputs, outputs, and side effects.
- Test through public interfaces.
- Do not rely on unclear names, broad setup, or multi-purpose assertions.

## Anti-Patterns

- Do not mock implementation details or internal calls as primary assertions.
  Mock only external dependencies when unavoidable. Prefer observable behavior
  over interaction-count assertions.
- Do not test private fields, private methods, or internal data structures.
- Do not add production methods intended only for tests.
- Do not over-mock fast in-process dependencies.
- Do not build excessive fixture setup that hides test intent.

## Verification

- Ensure every new function/method has a test.
- Watch each test fail before implementing. Ensure each test failed for the expected reason.
- Write minimal code to pass. Ensure all tests pass and output is pristine.
- Ensure tests use real code and cover edge cases.
- Do not proceed when any check is unchecked. TDD was skipped. Start over.

## Exceptions

TDD is not required for documentation, configuration, or non-code file edits.

---
name: standards-tdd
description: >-
  Use when implementing new features, fixing bugs, or writing any production code.
  Enforces red-green-refactor workflow. Does not apply to documentation,
  configuration, or non-code file edits.
---

# TDD

## Iron Law

Do not write production code without a failing test. No exceptions.
If code is written before its test, delete it and start over.

## Red-Green-Refactor

1. Red: Write one failing test. Verify it fails for the expected reason.
2. Green: Write minimal production code to make it pass.
3. Refactor: Refactor only after tests are green. Keep behavior unchanged.
4. Repeat for each behavior change.

## Rules

- One behavior per test. Test through public interfaces only.
- Do not mock internal calls. Mock only external dependencies when unavoidable.
- Do not add production code intended only for tests.

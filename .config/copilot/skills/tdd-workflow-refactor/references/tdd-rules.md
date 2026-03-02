# TDD Refactor Phase Rules

- Refactor only after the test suite is green.
- Refactor must not change observable behavior.
- Keep public interfaces and externally visible side effects unchanged.
- Re-run the same relevant tests after refactor.
- Treat any post-refactor test failure as a failed refactor and abort.
- If green proof is missing, do not start refactoring.

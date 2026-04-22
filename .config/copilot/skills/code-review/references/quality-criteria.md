# Quality Criteria

Focus on code maintainability, readability, and error-handling robustness.

- Large functions: Functions exceeding 50 lines.
- Large files: Files exceeding 800 lines.
- Deep nesting: Nesting depth exceeding 4 levels.
- Missing error handling: Operations without try/catch, error checks, or Result handling.
- Debug statements: console.log, print(), or similar debug code left in production paths.
- Mutation patterns: Direct object/array mutations instead of immutable patterns.
- Missing tests: New code without corresponding test coverage.

Severity mapping: most items default to MEDIUM. Elevate to HIGH when the issue
significantly hampers readability or causes maintenance burden. Elevate to CRITICAL
only when the issue causes correctness bugs (e.g., missing error handling that
silently drops data). Use LOW for minor style-adjacent quality observations.

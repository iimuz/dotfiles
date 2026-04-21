# Best Practices Criteria

Focus on coding standards, conventions, and long-term maintainability.

- Immutability violations: Direct object/array mutations instead of immutable patterns.
- Missing tests: New code without corresponding test coverage.
- Emoji usage: Emojis in code, comments, or documentation.
- TODO/FIXME without tickets: Action items without tracking references.
- Missing documentation: Public APIs without doc comments.
- Accessibility issues: Missing ARIA labels, poor contrast, keyboard navigation problems.
- Poor naming: Non-descriptive variable names (x, tmp, data, etc.).
- Magic numbers: Numeric literals without explanation or named constants.
- Inconsistent formatting: Style inconsistencies within the codebase.

Severity mapping: most items default to LOW. Elevate to MEDIUM when the
violation causes real confusion or maintenance burden (e.g., completely
undocumented public API). Elevate to HIGH when the violation will likely cause
bugs during future maintenance. Elevate to CRITICAL only when the violation
causes correctness issues.

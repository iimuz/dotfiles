---
name: code-review-checklist
description: >-
  Provides additional review criteria to augment the standard code review
  workflow. Use when performing code review to check design compliance,
  security, quality, performance, testing, and best practices.
user-invocable: true
disable-model-invocation: false
---

# Code Review Checklist

## Overview

This Skill provides a checklist of review criteria to augment the standard
code review workflow. When reviewing code, apply the criteria below in
addition to the standard review process.

Severity classification and output formatting follow the standard review
workflow; this Skill only supplies the criteria to check.

## Design Compliance

Focus on alignment between the code changes and the provided design information.

Skip this category if no design information is provided.

- Interface contract violations: Method signatures, return types, or parameters
  that deviate from the design.
- Missing implementations: Design-specified components or behaviors not present
  in the code.
- Architectural deviations: Code structure that contradicts design decisions
  (e.g., wrong module boundaries, wrong dependency directions).
- Behavioral mismatches: Logic that produces different outcomes than the design
  specifies.
- Constraint violations: Design-specified constraints (performance budgets,
  size limits, invariants) not enforced in code.
- Naming inconsistencies: Identifiers that deviate from design-specified
  terminology.

## Security

Focus on security vulnerabilities and risks that could lead to data breaches,
unauthorized access, or system compromise.

- Hardcoded credentials: API keys, passwords, tokens, secrets in source code.
- SQL injection risks: String concatenation in SQL queries.
- XSS vulnerabilities: Unescaped user input in HTML/templates.
- Missing input validation: User input accepted without validation.
- Insecure dependencies: Outdated or vulnerable libraries.
- Path traversal risks: User-controlled file paths without sanitization.
- CSRF vulnerabilities: Missing CSRF protection in state-changing operations.
- Authentication bypasses: Logic errors allowing unauthorized access.

## Quality

Focus on code maintainability, readability, and error-handling robustness.

- Large functions: Functions exceeding 50 lines.
- Large files: Files exceeding 800 lines.
- Deep nesting: Nesting depth exceeding 4 levels.
- Missing error handling: Operations without try/catch, error checks, or
  Result handling.
- Debug statements: console.log, print(), or similar debug code left in
  production paths.

## Performance

Focus on efficiency, resource usage, and optimization opportunities.

- Inefficient algorithms: O(n^2) when O(n log n) or O(n) is possible.
- Unnecessary re-renders: React components re-rendering without memoization.
- Missing memoization: Expensive computations without caching.
- Large bundle sizes: Unnecessary dependencies or missing code splitting.
- Unoptimized assets: Large images without compression or lazy loading.
- Missing caching: Repeated identical API calls or computations.
- N+1 queries: Database queries in loops instead of batch operations.

## Testing

Focus on test coverage for code changes.

- Missing tests: New code without corresponding test coverage.

## Best Practices

Focus on coding standards, conventions, and long-term maintainability.

- Immutability violations: Direct object/array mutations instead of immutable
  patterns.
- Emoji usage: Emojis in code, comments, or documentation.
- TODO/FIXME without tickets: Action items without tracking references.
- Missing documentation: Public APIs without doc comments.
- Accessibility issues: Missing ARIA labels, poor contrast, keyboard navigation
  problems.
- Poor naming: Non-descriptive variable names (x, tmp, data, etc.).
- Magic numbers: Numeric literals without explanation or named constants.
- Inconsistent formatting: Style inconsistencies within the codebase.

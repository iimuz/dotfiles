# Review Criteria

This document defines the four independent aspects for comprehensive code review.

## Security Checks (CRITICAL)

Focus on security vulnerabilities and risks that could lead to data breaches, unauthorized access, or system compromise.

- **Hardcoded credentials**: API keys, passwords, tokens, secrets in source code
- **SQL injection risks**: String concatenation in SQL queries
- **XSS vulnerabilities**: Unescaped user input in HTML/templates
- **Missing input validation**: User input accepted without validation
- **Insecure dependencies**: Outdated or vulnerable libraries
- **Path traversal risks**: User-controlled file paths
- **CSRF vulnerabilities**: Missing CSRF protection in state-changing operations
- **Authentication bypasses**: Logic errors allowing unauthorized access

## Code Quality (HIGH)

Focus on code maintainability, readability, and adherence to good coding practices.

- **Large functions**: Functions exceeding 50 lines
- **Large files**: Files exceeding 800 lines
- **Deep nesting**: Nesting depth exceeding 4 levels
- **Missing error handling**: Operations without try/catch or error checks
- **Debug statements**: console.log, print(), or similar debug code left in
- **Mutation patterns**: Direct object/array mutations instead of immutable patterns
- **Missing tests**: New code without corresponding test coverage

## Performance (MEDIUM)

Focus on efficiency, resource usage, and optimization opportunities.

- **Inefficient algorithms**: O(n²) when O(n log n) is possible
- **Unnecessary re-renders**: React components re-rendering unnecessarily
- **Missing memoization**: Expensive computations without caching
- **Large bundle sizes**: Unnecessary dependencies or missing code splitting
- **Unoptimized images**: Large images without compression or lazy loading
- **Missing caching**: Repeated identical API calls or computations
- **N+1 queries**: Database queries in loops instead of batch operations

## Best Practices (MEDIUM)

Focus on coding standards, conventions, and long-term maintainability.

- **Immutability violations**: Use immutability patterns consistently
- **Missing tests**: New code should have test coverage
- **Emoji usage**: Emojis in code, comments, or documentation (remove them)
- **TODO/FIXME without tickets**: Action items without tracking references
- **Missing documentation**: Public APIs without doc comments
- **Accessibility issues**: Missing ARIA labels, poor contrast, keyboard navigation problems
- **Poor naming**: Non-descriptive variable names (x, tmp, data, etc.)
- **Magic numbers**: Numeric literals without explanation or constants
- **Inconsistent formatting**: Style inconsistencies within the codebase

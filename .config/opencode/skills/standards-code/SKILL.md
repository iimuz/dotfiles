---
name: standards-code
description: >-
  Use when writing or reviewing code in Bash, Go, Python, Rust, or TypeScript
  to enforce coding standards.
---

# Coding Standards

## Principles

- Handle errors explicitly. Do not swallow errors silently.
- Depend on abstractions, not concrete implementations.
- Validate external input at the boundary. Do not trust unvalidated data beyond that point.
- Keep public API surface minimal. Do not export internal implementation details.
- Inject dependencies. Do not rely on global mutable state.
- Use structured logging. Do not use print statements for operational output.

## Language References

- Bash: [references/bash.md](references/bash.md)
- Go: [references/go.md](references/go.md)
- Python: [references/python.md](references/python.md)
- Rust: [references/rust.md](references/rust.md)
- TypeScript: [references/typescript.md](references/typescript.md)

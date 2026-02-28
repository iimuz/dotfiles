---
applyTo: "**/*.py"
---

# Python

## Architecture

- ALWAYS use dataclasses or Pydantic models for structured data; NEVER pass raw dicts across module boundaries.
- ALWAYS use **all** to declare the public API of a module explicitly.
- NEVER use wildcard imports (from module import \*) in production code.
- ALWAYS use dependency injection for testability; NEVER rely on global mutable state.
- NEVER use mutable default arguments in function signatures.
- ALWAYS use pathlib.Path instead of os.path for filesystem operations.

## Type Safety

- ALWAYS add type hints to all function signatures and class attributes.
- ALWAYS enable mypy strict mode for public APIs.
- ALWAYS use Protocol for structural typing; prefer Protocol over ABC for duck-typed interfaces.

## Error Handling

- NEVER raise bare Exception; ALWAYS define custom exception hierarchies for domain errors.
- ALWAYS handle exceptions at the appropriate architectural layer; NEVER swallow exceptions silently.
- NEVER catch broad exception types (Exception, BaseException) unless re-raising or logging and re-raising.

## Async

- NEVER mix sync blocking calls inside async functions.
- ALWAYS use async context managers for async resources.
- ALWAYS use asyncio.TaskGroup for structured concurrency.

## Security

- ALWAYS validate and sanitize external input before use.
- NEVER interpolate user input directly into SQL queries; ALWAYS use parameterized queries.
- NEVER hardcode secrets; ALWAYS read secrets from environment variables or a secret manager.

## Testing

- ALWAYS write tests with pytest; ALWAYS use fixtures to isolate test data from production data.
- ALWAYS use parametrize for edge-case coverage; NEVER duplicate test bodies for similar cases.
- ALWAYS mock external I/O (HTTP, DB, filesystem) at service boundaries; NEVER hit real endpoints in unit tests.

## Performance

- ALWAYS use context managers (with) for file, network, and database resources.
- ALWAYS use generators for large datasets to avoid memory exhaustion.
- ALWAYS prefer comprehensions over explicit loops for simple transformations.

## Logging

- ALWAYS use logging with structured fields; NEVER use print for operational output.

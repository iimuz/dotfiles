# Python

## Official Documentation

When encountering unfamiliar Python APIs or patterns, use a subagent to fetch
the relevant specification details from the official documentation:

- [Python Standard Library](https://docs.python.org/3/library/index.html)

## Architecture

- Use dataclasses or Pydantic models for structured data. Do not pass raw dicts across module boundaries.
- Use `__all__` to declare the public API of a module explicitly.
- Do not use wildcard imports (`from module import *`) in production code.
- Use dependency injection for testability. Do not rely on global mutable state.
- Do not use mutable default arguments in function signatures.
- Use `pathlib.Path` instead of `os.path` for filesystem operations.

## Type Safety

- Add type hints to all function signatures and class attributes.
- Enable mypy strict mode for public APIs.
- Use `Protocol` for structural typing. Prefer `Protocol` over `ABC` for duck-typed interfaces.

## Error Handling

- Do not raise bare `Exception`. Define custom exception hierarchies for domain errors.
- Handle exceptions at the appropriate architectural layer. Do not swallow exceptions silently.
- Do not catch broad exception types (`Exception`, `BaseException`) unless re-raising or logging and re-raising.

## Async

- Do not mix sync blocking calls inside async functions.
- Use async context managers for async resources.
- Use `asyncio.TaskGroup` for structured concurrency.

## Security

- Validate and sanitize external input before use.
- Do not interpolate user input directly into SQL queries. Use parameterized queries.
- Do not hardcode secrets. Read secrets from environment variables or a secret manager.

## Performance

- Use context managers (`with`) for file, network, and database resources.
- Use generators for large datasets to avoid memory exhaustion.
- Prefer comprehensions over explicit loops for simple transformations.

## Logging

- Use `logging` with structured fields. Do not use `print` for operational output.

## Testing

- Write tests with pytest. Use fixtures to isolate test data from production data.
- Use `parametrize` for edge-case coverage. Do not duplicate test bodies for similar cases.
- Mock external I/O (HTTP, DB, filesystem) at service boundaries. Do not hit real endpoints in unit tests.

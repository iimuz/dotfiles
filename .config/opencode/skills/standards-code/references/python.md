# Python

- Official docs: [Standard Library](https://docs.python.org/3/library/index.html)
- Use dataclasses or Pydantic models for structured data. Do not pass raw dicts across module boundaries.
- Add type hints to all function signatures. Enable mypy strict mode for public APIs.
- Use `Protocol` for structural typing. Prefer `Protocol` over `ABC`.
- Define custom exception hierarchies for domain errors. Do not raise bare `Exception`.
- Use `pathlib.Path` instead of `os.path`.
- Do not use mutable default arguments in function signatures.
- Use `asyncio.TaskGroup` for structured concurrency. Do not mix sync blocking calls in async functions.
- Use parameterized queries for SQL. Do not interpolate user input.
- Use `logging` with structured fields.
- Use pytest with `parametrize` for edge-case coverage. Mock external I/O at service boundaries.

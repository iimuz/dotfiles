---
name: standards-mise
description: >-
  Use when creating or modifying mise tasks (file-based scripts in
  .mise/tasks/ or inline tasks in mise.toml) to enforce naming conventions
  and pick the right task pattern.
user-invocable: true
disable-model-invocation: false
---

# Mise Tasks

## Official Documentation

When working with mise task configuration or encountering unfamiliar mise
features, use a subagent to fetch the relevant specification details from
the official documentation:

- [Task Configuration - mise](https://mise.jdx.dev/tasks/task-configuration.html)
- [Configuration - mise](https://mise.jdx.dev/configuration.html)

## Project Policy

The following rules always apply regardless of whether the official
documentation was fetched. When they conflict with the official
documentation, these rules take precedence.

### Two Task Patterns

Two ways to define a task exist in this repo; pick based on what the task
needs.

- **File-based** (`.mise/tasks/`): use when the task needs real shell
  positional args (`$@`), bash-only features, or non-trivial logic.
  Examples: `setup`, `test`.
- **Inline** (`mise.toml` `[tasks]`): use for simple, single-purpose tasks.
  Examples: the per-tool `format:*` / `lint:*` tasks and the `format` /
  `lint` umbrella tasks that `depends` on them.

### Naming Convention

- File-based tasks: always include a file extension (`.sh` for shell
  scripts). mise uses the filename without extension as the task name.
  Example: `setup.sh` becomes task `setup`.
- Inline tasks: the `[tasks]` table key is the task name, e.g.
  `[tasks."format:sh"]` becomes task `format:sh`.

### Inline Task Arguments

Inline `run` bodies execute under POSIX `sh`, not bash, and do not receive
real shell positional params — `$@` is empty even when the task is invoked
with arguments. To accept file arguments, declare them with the `usage`
field (e.g. `arg "[files]" var=#true`) and read them via the matching
`$usage_files` env var. Common pattern: if `$usage_files` is set, operate
on those files; otherwise glob all files of that type via `git ls-files`.

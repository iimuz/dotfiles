---
name: standards-mise
description: >-
  Use when creating or modifying mise tasks (inline tasks in mise.toml or
  script-backed tasks in scripts/) to enforce naming conventions and pick
  the right task pattern.
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

- **Inline** (`mise.toml` `[tasks]`): the default. Use for simple,
  single-purpose tasks. Examples: `setup`, the per-tool `format:*` /
  `lint:*` / `test:*` tasks, and the `format` / `lint` / `test` umbrella
  tasks that `depends` on them.
- **Script-backed** (`scripts/`): use when the task needs bash-only
  features or non-trivial logic. Place the script in `scripts/` and
  reference it from an inline task's `run`. No current task needs this.

### Naming Convention

- Inline tasks: the `[tasks]` table key is the task name, e.g.
  `[tasks."format:sh"]` becomes task `format:sh`.
- Sub-tasks use a target-language suffix (`format:py` / `lint:sh` /
  `test:py`); umbrella tasks aggregate them via `depends`.
- Script-backed tasks: name the script after the task with a file
  extension, e.g. `scripts/setup.sh` referenced by `[tasks.setup]`.

### Inline Task Arguments

Inline `run` bodies execute under POSIX `sh`, not bash, and do not receive
real shell positional params — `$@` is empty even when the task is invoked
with arguments. To accept file arguments, declare them with the `usage`
field (e.g. `arg "[files]" var=#true`) and read them via the matching
`$usage_files` env var. Common pattern: if `$usage_files` is set, operate
on those files; otherwise glob all files of that type via `git ls-files`.

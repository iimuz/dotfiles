---
applyTo: ".mise/tasks/**"
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

### Naming Convention

- Always include a file extension (`.sh` for shell scripts).
- mise uses the filename without extension as the task name.
- Example: `format.sh` becomes task `format`, `lint.sh` becomes task `lint`.

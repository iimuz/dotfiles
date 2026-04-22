---
name: devcontainer
description: >-
  Use when creating or modifying devcontainer configuration files in .devcontainer/
  to apply project-specific JSONC format policy.
user-invocable: true
disable-model-invocation: false
---

# Devcontainer Configuration

## Official Documentation

When creating or modifying devcontainer files, use a subagent to fetch the
latest specification from the official documentation and return the relevant
specification details:

- [Dev Container Specification](https://containers.dev/implementors/json_reference/)
- [Available Features](https://containers.dev/features)

If the fetch fails, follow the project policy below instead.

## Project Policy

- Use JSONC (JSON with Comments) for `devcontainer.json`.

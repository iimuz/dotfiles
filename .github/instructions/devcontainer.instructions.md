---
applyTo: ".devcontainer/**"
---

# Devcontainer Configuration

## Official Documentation

When creating or modifying devcontainer files, use a subagent to fetch
the latest specification from the official documentation and return the
relevant specification details:

- [Dev Container Specification](https://containers.dev/implementors/json_reference/)
- [Available Features](https://containers.dev/features)

If the fetch fails, follow the project policy below instead.

## Project Policy

The following rules are project-specific policies.

- Use JSONC (JSON with Comments) for `devcontainer.json`.

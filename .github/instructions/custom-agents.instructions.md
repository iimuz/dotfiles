---
applyTo: ".config/copilot/agents/**"
---

# Custom Agents

## Official Documentation

When creating or modifying custom agent files, use a subagent to fetch
the latest specification from the official documentation and return the
relevant specification details:

- [Create custom agents for CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [Custom agents configuration reference - GitHub Docs](https://docs.github.com/en/copilot/reference/custom-agents-configuration)

If the fetch fails, follow the overview described below instead.

## Custom Agent Specification Overview

- Place custom agent files under `.config/copilot/agents/`.
- Use `.md` or `.agent.md` file extensions.
- The filename without extension serves as the default agent identifier.
- Required frontmatter fields: `name`, `description`, `tools`, `user-invocable`, `disable-model-invocation`.
- The `tools` field is a string array of CLI-compatible tool names. Use MCP tool syntax as `server-name/tool-name` or `server-name/*` when needed.
- Agent body should include a title, overview section, allowed tools mapping, and a process section with ordered execution steps.## Project Policy

When they conflict with the official documentation, these rules take precedence.

### Naming

- Keep `name` lowercase kebab-case to match the file identity.
- Do not use spaces, uppercase letters, or ambiguous names in filenames or `name`.

### Tool Declarations

- Use least-privilege tool declarations. Prefer explicit allowlists over `"*"` unless full access is required with explicit justification.
- Do not declare tools that the agent body does not use.

### Anti-Patterns

- Do not write vague `description` values that do not indicate trigger conditions.
- Do not define agent behavior that requires tools not declared in `tools`.
- Do not use `allowed-tools` in custom agent frontmatter. Use `tools` instead.
- Do not rely on `argument-hint` or `handoffs` in CLI-targeted custom agent guidance.
- Do not assume model override behavior is portable across CLI, VS Code, and GitHub.com contexts.

### Linter-Enforceable Rules Exclusions

- Do not define indentation, trailing whitespace, line length, or shell syntax rules in this file. Those are enforced by `mise run format` and `mise run lint`.

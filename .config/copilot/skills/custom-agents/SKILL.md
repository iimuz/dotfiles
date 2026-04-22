---
name: custom-agents
description: >-
  Use when creating or modifying custom agent files in .config/copilot/agents/
  to enforce sub-agent pattern and tool property rules.
user-invocable: true
disable-model-invocation: false
---

# Custom Agents

## Official Documentation

When creating or modifying custom agent files, use a subagent to fetch the
latest specification from the official documentation and return the relevant
specification details:

- [Create custom agents for CLI - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [Custom agents configuration reference - GitHub Docs](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Your first custom agent - GitHub Docs](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents/your-first-custom-agent)

## Project Policy

### Sub-Agent Pattern

When an agent is designed to be invoked only by an orchestrator (skill or
agent), not directly by users:

- Set `user-invocable: false` to prevent direct user invocation.
- Set `disable-model-invocation: false` to allow `task()` dispatch. Setting this
  to `true` blocks all programmatic `task()` calls, not just model-initiated ones.
- Set `model` when the agent has a clear model affinity per the Model Selection
  policy. Orchestrators can still override via `task(agent-name, model=X)`.

### Tool Property

- Use `tools` for tool declarations. Do not use `allowed-tools` (that is a skill frontmatter field).

### Canonical Examples

- Sub-agent (aspect reviewer): `.config/copilot/agents/code-review-security.md`
- Sub-agent (pipeline utility): `.config/copilot/agents/code-review-consolidate.md`
- User-facing agent: `.config/copilot/agents/orchestrator.md`

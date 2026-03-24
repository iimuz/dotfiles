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
- [Your first custom agent - GitHub Docs](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents/your-first-custom-agent)

If the fetch fails, follow the overview described below instead.

## Custom Agent Specification Overview

- Each custom agent is a Markdown file (`.md` or `.agent.md`) with YAML frontmatter and a prompt body.
- The filename without extension serves as the default agent identifier.
- Required frontmatter: `name`, `description`.
- Optional frontmatter: `tools`, `mcp-servers`, `model`, `infer`.
- Tool aliases (`execute`, `read`, `edit`, `search`, `agent`, `web`, `todo`) are case insensitive.
  MCP tools use `server-name/tool-name` or `server-name/*` syntax.
- Naming conflicts: lowest level wins (user > repository > organization > enterprise).

## Project Policy

The following rules always apply regardless of whether the official
documentation was fetched. When they conflict with the official
documentation, these rules take precedence.

### Naming

- Keep `name` lowercase kebab-case to match the file identity.
- Do not use spaces, uppercase letters, or ambiguous names in filenames or `name`.

### Tool Declarations

- Use least-privilege tool declarations. Prefer explicit allowlists over
  `"*"]` unless full access is required with explicit justification.
- Do not declare tools that the agent body does not use.

### Description Quality

- Write `description` values that clearly state what expertise the agent has and when it should be used.
- Do not write vague descriptions that do not indicate trigger conditions.
- The `description` is the primary signal Copilot uses for auto-delegation.
  A poor description leads to incorrect or missed invocations.

### Body Structure

The prompt body serves as the system prompt when the agent runs. Follow the
structure demonstrated in the official GitHub Docs tutorial:

- Open with a persona statement: "You are a {role} specialized in {domain}."
  Establish expertise and scope in the first sentence.
- Define scope with bold section headers (e.g., Primary Focus, File Types).
  Keep each section focused on one responsibility.
- Include an explicit limitations section with "Do NOT" constraints to
  prevent scope creep and unwanted side effects.
- End with a guiding principle that reinforces the agent's primary goal.

### Sub-Agent Pattern

When an agent is designed to be invoked only by an orchestrator (skill or
agent), not directly by users:

- Set `user-invocable: false` to prevent direct user invocation.
- Set `disable-model-invocation: true` to prevent auto-delegation bypass.
- Omit `model` from frontmatter so the orchestrator controls model selection
  per invocation via `task(agent-name, model=X)`.

### Anti-Patterns

- Do not define agent behavior that requires tools not declared in `tools`.
- Do not use `allowed-tools` in custom agent frontmatter. Use `tools` instead.
- Do not rely on `argument-hint` or `handoffs` in CLI-targeted custom agent guidance.
  These properties are not supported in Copilot CLI or GitHub.com.

### Canonical Examples

- Sub-agent (aspect reviewer): `.config/copilot/agents/code-review-security.md`
- Sub-agent (pipeline utility): `.config/copilot/agents/code-review-consolidate.md`
- User-facing agent: `.config/copilot/agents/orchestrator.md`

### Linter-Enforceable Rules Exclusions

- Do not define indentation, trailing whitespace, line length, or shell
  syntax rules in this file. Those are enforced by linter and formatter.

---
applyTo: ".config/copilot/agents/**"
---

# Custom Agents

## Naming Conventions

- ALWAYS place custom agent files under `.config/copilot/agents/`.
- ALWAYS use `.md` or `.agent.md` file extensions.
- ALWAYS treat the filename without extension as the default agent identifier.
- ALWAYS keep `name` lowercase kebab-case to match the file identity when possible.
- NEVER use spaces, uppercase letters, or ambiguous names in filenames or `name`.

## Required Frontmatter Fields

- ALWAYS define `name` as a string that uniquely identifies the agent.
- ALWAYS define `description` as a clear trigger-focused string for when to invoke the agent.
- ALWAYS define `user-invocable` as a boolean to control manual user selection.
- ALWAYS define `disable-model-invocation` as a boolean to control automatic model delegation.
- ALWAYS define `tools` as a string array using CLI-compatible tool names.
- ALWAYS set `description` to concise behavior and trigger scope.
- NEVER replace `tools` with `allowed-tools` in custom agent frontmatter.
- NEVER use non-boolean values for `user-invocable` or `disable-model-invocation`.

## Agent Body Structure

- ALWAYS start with a single `#` title that names the agent behavior.
- ALWAYS use `## Overview` as the first section heading to define responsibilities and hard boundaries.
- NEVER use `## Role` as a section heading in agent bodies.
- ALWAYS include `## Allowed Tools` to map each declared tool to a clear purpose.
- ALWAYS include `## Process` with ordered execution steps.
- ALWAYS include `## Anti-Patterns` when constraints or prohibited behavior must be explicit.
- NEVER include conflicting directives between body sections.
- NEVER omit operational boundaries when delegation or automation is expected.

## Tool Declarations

- ALWAYS use least-privilege tool declarations in `tools`.
- ALWAYS prefer explicit allowlists over `"*"` unless full access is required.
- ALWAYS use CLI-compatible tool names such as `agent`, `skill`, `sql`, `report_intent`, `view`, `bash`.
- ALWAYS use MCP tool syntax as `server-name/tool-name` or `server-name/*` when needed.
- ALWAYS keep tool aliases consistent with CLI expectations.
- NEVER declare tools that the body does not use.
- NEVER depend on ignored or unknown tool names for required behavior.
- ALWAYS use minimal examples like:
  - `tools: ["sql", "report_intent"]`
  - `tools: ["agent", "skill", "read_agent", "list_agents"]`
  - `tools: ["github/*", "fetch"]`
  - NEVER use `tools: ["*"]` unless it is a last-resort option with explicit justification.

## Anti-Patterns

- NEVER use missing frontmatter delimiters (`---`) around metadata.
- NEVER write vague `description` values that do not indicate trigger conditions.
- NEVER grant broad tool access when a narrow list can satisfy the workflow.
- NEVER define agent behavior that requires tools not declared in `tools`.
- NEVER mix CLI requirements with editor-only features as required dependencies.
- NEVER rely on retired `infer` semantics when `disable-model-invocation` and `user-invocable` can express intent.

## VS Code Exclusions

- NEVER require `mcp-servers` support as a VS Code custom-agent dependency.
- NEVER require `metadata` support as a VS Code custom-agent dependency.
- NEVER rely on `argument-hint` in CLI-targeted custom agent guidance.
- NEVER rely on `handoffs` in CLI-targeted custom agent guidance.
- NEVER assume model override behavior is portable across CLI, VS Code, and GitHub.com contexts.

## Linter-Enforceable Rules Exclusions

- NEVER define indentation rules in this file; `mise run format` enforces indentation.
- NEVER define trailing whitespace rules in this file; `mise run format` enforces whitespace normalization.
- NEVER define line length or shell syntax rules in this file; `mise run lint` enforces those checks.

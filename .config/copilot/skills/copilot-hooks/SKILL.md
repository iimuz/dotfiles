---
name: copilot-hooks
description: >-
  Use when creating or modifying GitHub Copilot CLI hook configuration files
  to enforce policy, security, and timeout rules.
user-invocable: true
disable-model-invocation: false
---

# GitHub Copilot CLI Hooks

## Official Documentation

When creating or modifying hook configuration files, use a subagent to fetch
the latest specification from the official documentation and return the
relevant specification details:

- [Using hooks - GitHub Docs](https://docs.github.com/en/copilot/customizing-copilot/extending-copilot-coding-agent/using-hooks)
- [Hooks configuration - GitHub Docs](https://docs.github.com/en/copilot/reference/hooks-configuration)

If the fetch fails, follow the overview described below instead.

## Hooks Specification Overview

- Place hook configuration JSON files inside the `.github/hooks/` directory.
- Basic structure: `{ "version": 1, "hooks": { "<hookType>": [...] } }`
- Available hook types: `sessionStart`, `sessionEnd`,
  `userPromptSubmitted`, `preToolUse`, `postToolUse`, `agentStop`,
  `subagentStop`, `errorOccurred`
- Each entry is a command object with `type`, `bash`/`powershell`, and `timeoutSec` properties.
- Only `preToolUse` hooks can control tool execution by returning a
  `permissionDecision` via stdout.

## Project Policy

- Every command object must include `timeoutSec`. Omitting it is not allowed.
- Most hooks should complete within 5 seconds.
- Sanitize all input received via stdin before use.
- Never output secrets, tokens, or credentials to stdout or stderr.
- Do not make blocking network calls inside hooks. Use async or background patterns instead.
- Offload heavy processing to background processes.

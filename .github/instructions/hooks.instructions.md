---
applyTo: "**/.github/hooks/**"
---

# GitHub Copilot CLI Hooks Instructions

- Purpose: Defines rules for creating and managing hook configuration files under `.github/hooks/`.

## 1. File Placement and Naming

- Location: Place files inside the `.github/hooks/` directory.
- Filename: `hooks.json` or any JSON file name (e.g., `policy.json`).
- Loading: GitHub Copilot CLI automatically loads all `.github/hooks/*.json` files.

## 2. Basic Structure

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [],
    "sessionEnd": [],
    "userPromptSubmitted": [],
    "preToolUse": [],
    "postToolUse": [],
    "agentStop": [],
    "subagentStop": [],
    "errorOccurred": []
  }
}
```

- `version`: Must be `1`.
- `hooks`: Each key is a hook type; the value is an array of command objects.

## 3. Hook Types

| Hook Type             | When It Fires                               | Use Cases                                          |
| --------------------- | ------------------------------------------- | -------------------------------------------------- |
| `sessionStart`        | When a session starts or resumes            | Environment init, audit log start, state check     |
| `sessionEnd`          | When a session ends                         | Temp resource cleanup, log archiving               |
| `userPromptSubmitted` | Immediately after the user submits a prompt | Log user requests, audit trail                     |
| `preToolUse`          | Before a tool executes                      | Allow/deny tool execution, enforce security policy |
| `postToolUse`         | After a tool executes (success or failure)  | Log results, collect metrics                       |
| `agentStop`           | When the main agent completes a response    | Notify completion                                  |
| `subagentStop`        | When a subagent completes                   | Verify subtask results                             |
| `errorOccurred`       | When an error occurs                        | Error logging, debug info collection               |

## 4. Command Object

Properties of each object inside a hook array:

| Property     | Required      | Description                                                              |
| ------------ | ------------- | ------------------------------------------------------------------------ |
| `type`       | Yes           | Must be `"command"`.                                                     |
| `bash`       | Yes (Unix)    | Shell command or script path to run on Unix-based systems.               |
| `powershell` | Yes (Windows) | PowerShell command or script path to run on Windows.                     |
| `cwd`        | No            | Working directory for the command (relative to the repository root).     |
| `env`        | No            | Additional environment variables (merged with the existing environment). |
| `timeoutSec` | Yes           | Maximum execution time in seconds. Omitting is a violation.              |

### stdin / stdout Specification

- Rule: Hook scripts receive a JSON context (tool name, arguments, etc.) via stdin.
- Rule: Only `preToolUse` hooks can control tool execution by writing JSON to stdout.
  For all other hook types, stdout output is ignored.

## 5. preToolUse permissionDecision Contract

- `preToolUse` hooks control tool execution by writing JSON to stdout.
- If no output is produced, the tool is allowed by default.
- `permissionDecisionReason` is shown to the user.

To allow:

```json
{ "permissionDecision": "allow" }
```

To deny:

```json
{
  "permissionDecision": "deny",
  "permissionDecisionReason": "Reason for denial"
}
```

## 6. Security Rules (Required)

- Rule: Sanitize all input received via stdin before use.
- Rule: Never output secrets, tokens, or credentials to stdout or stderr.
- Rule: Ensure script log output does not include sensitive environment variables.
- Rule: Validate tool name and arguments in `preToolUse` before processing.

## 7. Performance Rules (Required)

- Rule: All hooks execute synchronously. The CLI does not proceed to the next action until the hook completes.
- Rule: Every command object must specify `timeoutSec`. Omitting it is a violation.
- Rule: Keep hook execution time as short as possible (target under 5 seconds for most hooks).
- Rule: Avoid blocking network calls inside hooks. Use async logging patterns instead.
- Rule: Offload heavy processing to background processes.

## 8. Example Configuration

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "type": "command",
        "bash": "echo \"Session started: $(date)\" >> /tmp/copilot-hook-session.log",
        "powershell": "Add-Content -Path \"$env:TEMP\\copilot-hook-session.log\" -Value \"Session started: $(Get-Date)\"",
        "cwd": ".",
        "timeoutSec": 10
      }
    ],
    "preToolUse": [
      {
        "type": "command",
        "bash": "./.github/hooks/scripts/validate-tool.sh",
        "powershell": "./.github/hooks/scripts/validate-tool.ps1",
        "cwd": ".",
        "env": {
          "STRICT_MODE": "true"
        },
        "timeoutSec": 5
      }
    ]
  }
}
```

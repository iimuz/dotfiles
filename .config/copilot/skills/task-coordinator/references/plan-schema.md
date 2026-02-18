# plan.json Schema Reference

## Full Schema

```json
{
  "schema_version": "1.0",
  "run_id": "tc-20240101-120000",
  "goal": "One-line summary of the original user request",
  "tasks": [
    {
      "id": "T1",
      "agent_type": "explore",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T1-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T1-output.md",
      "depends_on": [],
      "description": "(optional) Short status line for dashboard",
      "model": "(optional) Model override, e.g. claude-opus-4.6"
    },
    {
      "id": "T2",
      "agent_type": "general-purpose",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T2-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T2-output.md",
      "depends_on": ["T1"]
    }
  ],
  "synthesis_output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/synthesis.md"
}
```

## Field Reference

### Top-level (all required)

| Field | Type | Description |
| :--- | :--- | :--- |
| `schema_version` | string | Always `"1.0"` |
| `run_id` | string | Unique run identifier: `tc-{YYYYMMDD}-{HHMMSS}` |
| `goal` | string | One-line summary of the user request (for dashboard and Synthesizer context) |
| `tasks` | array | Ordered list of task objects (`tasks.length >= 1`) |
| `synthesis_output_file` | string | Absolute path to write the Synthesizer output (pipeline mode only; required even for single-task plans) |

### Per-task (required fields)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | string | Unique task identifier within the run (e.g., `T1`, `T2`) |
| `agent_type` | string | One of: `explore`, `task`, `general-purpose`, `code-review`, or a custom agent name |
| `prompt_file` | string | Absolute path to the worker's prompt file under the run directory |
| `output_file` | string | Absolute path to the worker's output file under the run directory |
| `depends_on` | array | List of task `id` values that must complete before this task starts (empty array if none) |

### Per-task (optional fields)

| Field | Type | Description |
| :--- | :--- | :--- |
| `description` | string | Short human-readable label for dashboard entries |
| `model` | string | Model override for this task (see SKILL.md Agent Selection) |

## Validation Rules

Before dispatching workers, validate the plan:

1. Valid JSON — reject on parse error
2. All required top-level fields present
3. All required per-task fields present for every task object
4. Task `id` values are unique within the plan
5. All `depends_on` values reference existing task `id` values
6. Dependency graph is acyclic (no circular dependencies)
7. `tasks.length` is between 1 and 15 (inclusive)
8. All `prompt_file` paths exist on disk before workers are spawned
9. All paths are absolute; resolve each to canonical form and verify it begins with the expected `~/.copilot/session-state/{session_id}/files/{run_id}/` prefix — reject the plan if any path escapes the run directory
10. `run_id` matches pattern `^tc-\d{8}-\d{6}$`

## Inline Mode vs Pipeline Mode

| task_count | Mode | Behavior |
| :--- | :--- | :--- |
| 1 | Inline | Spawn single worker directly; skip Synthesizer; return inline result |
| 2+ | Pipeline | Spawn workers in parallel; spawn Synthesizer after; return compact receipt |

The mode is determined by `tasks.length` in `plan.json` — decided by the Planner, not the main agent.

## Example: Single-Task Plan (inline mode)

```json
{
  "schema_version": "1.0",
  "run_id": "tc-20240101-120000",
  "goal": "Find all TODO comments in src/",
  "tasks": [
    {
      "id": "T1",
      "agent_type": "explore",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T1-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/T1-output.md",
      "depends_on": []
    }
  ],
  "synthesis_output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-120000/synthesis.md"
}
```

## Example: Multi-Task Plan with Dependency (pipeline mode)

```json
{
  "schema_version": "1.0",
  "run_id": "tc-20240101-150000",
  "goal": "Audit API endpoints for security issues and generate a fix plan",
  "tasks": [
    {
      "id": "T1",
      "agent_type": "explore",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T1-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T1-output.md",
      "depends_on": [],
      "description": "Enumerate all API endpoints",
      "model": "claude-haiku-4.5"
    },
    {
      "id": "T2",
      "agent_type": "general-purpose",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T2-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T2-output.md",
      "depends_on": ["T1"],
      "description": "Analyze endpoints for auth/injection vulnerabilities",
      "model": "claude-opus-4.6"
    },
    {
      "id": "T3",
      "agent_type": "general-purpose",
      "prompt_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T3-prompt.md",
      "output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/T3-output.md",
      "depends_on": ["T1"],
      "description": "Analyze endpoints for rate-limiting gaps",
      "model": "gpt-5.3-codex"
    }
  ],
  "synthesis_output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/synthesis.md"
}
```

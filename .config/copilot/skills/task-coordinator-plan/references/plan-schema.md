# plan.json Schema Reference

```typescript
type Plan = {
  schema_version: string; // "1.0"
  run_id: string; // tc-{YYYYMMDD}-{HHMMSS}; pattern: ^tc-\d{8}-\d{6}$
  goal: string; // one-line summary of user request
  tasks: Task[]; // 1..15 items
  synthesis_output_file: string; // absolute path under run_dir
};

type AllowedModel = "claude-opus-4.6" | "gpt-5.4" | "gemini-3-pro-preview";

type Task = {
  id: string; // unique within plan, e.g. "T1"
  agent_type: string; // "explore" | "task" | "general-purpose" | "code-review" | <custom>
  prompt_file: string; // absolute path under run_dir; must exist before workers spawn
  output_file: string; // absolute path under run_dir
  depends_on: string[]; // task IDs; empty array if no dependencies
  description?: string; // optional — short label for task context
  model?: AllowedModel; // optional — model override; must be one of AllowedModel values
};
```

## Validation Rules

- Parse `plan.json` as valid JSON before any other checks.
- Require all mandatory top-level and per-task fields.
- Ensure every task `id` is unique within `tasks`.
- Ensure task dependencies do not contain cycles.
- Reject any path that escapes `run_dir`.
- Require every `prompt_file` path to exist before worker execution.
- Require `tasks.length` to be within the inclusive range `[1, 15]`.
- Require `run_id` to match `^tc-\d{8}-\d{6}$`.
- Require every `depends_on` item to reference an existing task `id`.
- Require every optional `model` value to be one of `AllowedModel`.

## Validation Failures

- If JSON parsing fails, abort with `plan.json: parse failure`.
- If a required field is missing, abort with `plan.json: missing field`.
- If task IDs are duplicated, abort with `plan.json: duplicate task ID`.
- If dependencies form a cycle, abort with `plan.json: dependency cycle`.
- If any path traverses outside `run_dir`, abort with `plan.json: path traversal rejected`.
- If any prompt file is missing, abort with `plan.json: prompt file not found`.
- If the task count is outside `[1, 15]`, abort with `plan.json: task count out of [1, 15] range`.
- If `run_id` format is invalid, abort with `plan.json: run_id format invalid`.
- If `depends_on` references an unknown task ID, abort with `plan.json: unknown depends_on reference`.
- If `model` is not in `AllowedModel`, abort with `plan.json: model not in AllowedModel set`.

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
      "description": "(optional) Short status line for task context",
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

| Field                   | Type   | Description                                                                                             |
| :---------------------- | :----- | :------------------------------------------------------------------------------------------------------ |
| `schema_version`        | string | Always `"1.0"`                                                                                          |
| `run_id`                | string | Unique run identifier: `tc-{YYYYMMDD}-{HHMMSS}`                                                         |
| `goal`                  | string | One-line summary of the user request (for Synthesizer context)                                          |
| `tasks`                 | array  | Ordered list of task objects (`tasks.length >= 1`)                                                      |
| `synthesis_output_file` | string | Absolute path to write the Synthesizer output (pipeline mode only; required even for single-task plans) |

### Per-task (required fields)

| Field         | Type   | Description                                                                               |
| :------------ | :----- | :---------------------------------------------------------------------------------------- |
| `id`          | string | Unique task identifier within the run (e.g., `T1`, `T2`)                                  |
| `agent_type`  | string | One of: `explore`, `task`, `general-purpose`, `code-review`, or `<custom-agent-name>`     |
| `prompt_file` | string | Absolute path to the worker's prompt file under the run directory                         |
| `output_file` | string | Absolute path to the worker's output file under the run directory                         |
| `depends_on`  | array  | List of task `id` values that must complete before this task starts (empty array if none) |

### Per-task (optional fields)

| Field         | Type   | Description                                                   |
| :------------ | :----- | :------------------------------------------------------------ |
| `description` | string | Short human-readable label for task context                   |
| `model`       | string | optional — model override; must be one of AllowedModel values |

## Inline Mode vs Pipeline Mode

| task_count | Mode     | Behavior                                                                   |
| :--------- | :------- | :------------------------------------------------------------------------- |
| 1          | Inline   | Spawn single worker directly; skip Synthesizer; return inline result       |
| 2+         | Pipeline | Spawn workers in parallel; spawn Synthesizer after; return compact receipt |

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
      "model": "claude-opus-4.6"
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
      "model": "gpt-5.4"
    }
  ],
  "synthesis_output_file": "/home/{user}/.copilot/session-state/{session_id}/files/tc-20240101-150000/synthesis.md"
}
```

# plan.json Schema Reference

```typescript
type Plan = {
  schema_version: string; // "1.0"
  run_id: string; // tc-{YYYYMMDD}-{HHMMSS}; pattern: ^tc-\d{8}-\d{6}$
  goal: string; // one-line summary of user request
  tasks: Task[]; // 1..15 items
  synthesis_output_file: string; // absolute path under run_dir
};

type Task = {
  id: string; // unique within plan, e.g. "T1"
  agent_type: string; // "explore" | "task" | "general-purpose" | "code-review" | <custom>
  prompt_file: string; // absolute path under run_dir; must exist before workers spawn
  output_file: string; // absolute path under run_dir
  depends_on: string[]; // task IDs; empty array if no dependencies
  description?: string; // optional — short label for dashboard
  model?: string; // optional — model override
};
```

```typespec
op validate(raw: unknown) -> Plan {
  // Verify JSON structure, field completeness, graph integrity, and path confinement
  invariant: (json_parse_error)                          => abort("plan.json: parse failure");
  invariant: (missing_required_field)                    => abort("plan.json: missing field");
  invariant: (duplicate_task_id)                         => abort("plan.json: duplicate task ID");
  invariant: (circular_dependency)                       => abort("plan.json: dependency cycle");
  invariant: (path_escapes_run_dir)                      => abort("plan.json: path traversal rejected");
  invariant: (prompt_file_absent)                        => abort("plan.json: prompt file not found");
  invariant: (tasks.length < 1 or tasks.length > 15)    => abort("plan.json: task count out of [1, 15] range");
  invariant: (run_id !~ /^tc-\d{8}-\d{6}$/)            => abort("plan.json: run_id format invalid");
  invariant: (depends_on_id_unknown)                     => abort("plan.json: unknown depends_on reference");
}
```

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

| Field                   | Type   | Description                                                                                             |
| :---------------------- | :----- | :------------------------------------------------------------------------------------------------------ |
| `schema_version`        | string | Always `"1.0"`                                                                                          |
| `run_id`                | string | Unique run identifier: `tc-{YYYYMMDD}-{HHMMSS}`                                                         |
| `goal`                  | string | One-line summary of the user request (for dashboard and Synthesizer context)                            |
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

| Field         | Type   | Description                                                 |
| :------------ | :----- | :---------------------------------------------------------- |
| `description` | string | Short human-readable label for dashboard entries            |
| `model`       | string | Model override for this task (see SKILL.md Agent Selection) |

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

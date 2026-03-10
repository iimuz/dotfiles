# Planner Protocol

## Types

```typescript
type PlannerContext = {
  request: string;
  session_id: string;
  run_id: string;
  run_dir: string;
};

type PlannerReceipt = {
  status: "PLANNER_OK";
  plan_file: string;
  task_count: number;
  mode: "inline" | "pipeline";
};

type PromptFile = {
  Objective: string;
  Scope: string;
  Constraints: string;
  Output_contract: string;
  Acceptance_criteria: string;
};
```

## Steps

Execute the following steps directly:

- request: {verbatim user request}
- session_id: {session_id}
- run_id: {run_id}
- run_dir: {absolute path to ~/.copilot/session-state/{session_id}/files/{run_id}/}

1. Decompose the request into a minimal set of executable subtasks.
2. Write a prompt file at `{run_dir}/T{n}-prompt.md` for each task. Include all required sections:
   Objective, Scope, Constraints, Output_contract, Acceptance_criteria. Every prompt file must
   include verbatim: "Rule: Do NOT spawn subagents."
3. Write `{run_dir}/plan.json` following the schema in `references/plan-schema.md`. All paths must
   be absolute. Do NOT return plan content inline.
4. Do NOT spawn additional subagents.
5. Return EXACTLY this line: `PLANNER_OK plan_file={run_dir}/plan.json task_count=<n> mode=<inline|pipeline>`

## Constraints

- Set `mode` to `inline` when `task_count == 1`.
- Set `mode` to `pipeline` when `task_count >= 2`.
- Include all required prompt sections in every prompt file: `Objective`, `Scope`, `Constraints`,
  `Output_contract`, and `Acceptance_criteria`.
- Include the exact line `Rule: Do NOT spawn subagents.` in every prompt file.
- Write prompt files and `plan.json` only inside `run_dir`.
- Write `plan.json` with absolute paths only.
- Do not return plan content inline.
- Do not spawn additional subagents.
- Output exactly one receipt line in this format: `PLANNER_OK plan_file={run_dir}/plan.json task_count=<n> mode=<inline|pipeline>`.

## Fault Handling

- If any prompt file is missing a required section, abort.
- If any prompt file path writes outside `run_dir`, abort.
- If `plan.json` is invalid, abort.
- If any required path is not absolute, abort.
- If the response contains extra lines, abort.

## Agent Type Reference

| agent_type value      | When to use                                                 |
| :-------------------- | :---------------------------------------------------------- |
| `explore`             | Read-only code investigation, symbol search, file discovery |
| `task`                | Build, test, lint, install commands — pass/fail output      |
| `general-purpose`     | Multi-step implementation, code editing, complex reasoning  |
| `code-review`         | Reviewing changes without modifying code                    |
| `<custom-agent-name>` | When a domain-specific custom agent is available            |

## Model Reference

| Model                | Best For                                                 |
| :------------------- | :------------------------------------------------------- |
| claude-opus-4.6      | Nuanced reasoning, code review, complex refactoring      |
| gpt-5.4              | Code generation, structured output, tool-heavy workflows |
| gemini-3-pro-preview | Broad knowledge synthesis, summarization, exploration    |

- Canonical source: plan-schema.md
- When `model` is unspecified in a task, the task tool uses its default model.

# Planner Subagent Protocol

## Planner Prompt Template

Use this template when spawning the Planner subagent. Replace `{...}` placeholders with actual values.

```
You are the Planner for a task-coordinator pipeline.

## Input

User request:
{verbatim user request}

Session context:
- session_id: {session_id}
- run_id: {run_id}
- run_dir: {absolute path to ~/.copilot/session-state/{session_id}/files/{run_id}/}

## Your Task

1. Decompose the user request into the minimal set of executable subtasks.
2. For each subtask, write a self-contained prompt file: {run_dir}/T{n}-prompt.md
3. Write the task manifest: {run_dir}/plan.json

## Execution Mode Rule

Count the subtasks you identify:
- If exactly 1 subtask → set mode = inline
- If 2 or more subtasks → set mode = pipeline

## plan.json Schema

Write plan.json per `references/plan-schema.md`. Required top-level fields: `schema_version`, `run_id`, `goal`, `tasks`, `synthesis_output_file`. Required per-task fields: `id`, `agent_type`, `prompt_file`, `output_file`, `depends_on`.

## Required Sections in Every T{n}-prompt.md

Each prompt file MUST contain these sections:

1. **Objective**: What this task must accomplish, in 1–3 sentences.
2. **Scope**: Exact files, paths, or resources in scope. List what is explicitly OUT of scope.
3. **Constraints**: What NOT to do (no spawning subagents, no writing outside output_file, etc.).
4. **Output contract**: Exact path and format of the output file.
5. **Acceptance criteria**: How to determine the task is complete.
6. **Rule**: "Do NOT spawn subagents."

## Hard Constraints

- Do NOT return plan content inline.
- Do NOT spawn subagents.
- Do NOT write files outside {run_dir}.
- Ensure plan.json is valid JSON (properly escaped, no trailing commas).
- All prompt_file and output_file paths must be absolute.

## Return Format

Return ONLY this single line — nothing else:

PLANNER_OK plan_file={run_dir}/plan.json task_count=<n> mode=<inline|pipeline>
```

## Planner Failure Handling

If the Planner returns more than 5 lines, treat it as a format violation:

1. Ignore the response body
2. Check whether `{run_dir}/plan.json` was written to disk
3. If the file exists and is valid, proceed normally
4. If the file is missing or invalid, retry the Planner once with the instruction: "Your previous response violated the return format contract. Return ONLY the `PLANNER_OK` receipt line. Write all content to files."
5. If the second attempt also fails, abort and report to the user

## Agent Type Reference

| agent_type value | When to use |
| :--- | :--- |
| `explore` | Read-only code investigation, symbol search, file discovery |
| `task` | Build, test, lint, install commands — pass/fail output |
| `general-purpose` | Multi-step implementation, code editing, complex reasoning |
| `code-review` | Reviewing changes without modifying code |
| custom agent name | When a domain-specific custom agent is available and matches the subtask |

Always select the narrowest-scoped agent type that satisfies the subtask requirements.

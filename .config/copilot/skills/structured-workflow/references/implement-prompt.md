# Implementation Request

## Goal

Implement code changes for the current iteration's scope. Do not fix pre-existing issues unrelated to the plan goal.

## Required Decomposition

Planner: create the following tasks with these `depends_on` relationships.

| Task ID     | Agent type        | depends_on  |
| :---------- | :---------------- | :---------- |
| load-scope  | `explore`         | —           |
| detect-lang | `explore`         | load-scope  |
| execute     | `general-purpose` | detect-lang |

### Task: load-scope

Determine the work scope for this iteration.

- If `iteration == 1`: read the plan file at `plan.session_state_file` and extract all tasks/changes to implement.
- If `iteration > 1`: filter `prior_issues` to severity "Critical" and "High" only.
- Exclude pre-existing issues unrelated to the current plan goal.

Output contract: write `{run_dir}/scope.json` — `{ "source": "plan"|"prior_issues", "items": ["..."] }`

### Task: detect-lang

Detect the primary programming language of files in scope.

- Detect from file extensions: `.go` → "go", `.py` → "python", `.ts`/`.tsx` → "typescript"/"react",
  `.rs` → "rust".
- Detect from project manifests: `go.mod` → "go", `pyproject.toml` → "python", `Cargo.toml` → "rust",
  `package.json` → "typescript"/"react".
- Output null if no supported language is detected.

Output contract: write `{run_dir}/language.json` —
`{ "language": "go"|"python"|"typescript"|"react"|"rust"|null }`

### Task: execute

Implement all changes from scope.

1. Read `{run_dir}/scope.json` for work items.
2. Read `{run_dir}/language.json` for the detected language.
3. If `language != null`: invoke `skill(name: "language-pro", language: {language})` before implementing.
4. If `tdd_mode == true`: invoke `skill(name: "test-driven-development")` and follow its workflow.
5. If `tdd_mode == false`: implement all scope items directly.
6. Implement ALL items in scope completely.
7. Do NOT call `task()` to spawn sub-agents.

## Input Context

Plan: {{plan}}
Iteration: {{iteration}}
Prior issues: {{prior_issues}}
TDD mode: {{tdd_mode}}

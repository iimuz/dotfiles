---
name: structured-workflow-implement
description: >
  Prepare implementation request for task-coordinator by
  analyzing scope, detecting language, and writing a
  request file. Sub-skill of structured-workflow.
user-invocable: false
disable-model-invocation: true
---

# Structured Workflow Implement

## Overview

Sub-skill that prepares a task-coordinator request file.
Determines the implementation scope from the plan or
prior review issues, detects the primary language, and
writes a natural-language request file that the main
agent passes to `task-coordinator`.

## Interface

```typescript
/**
 * @skill structured-workflow-implement
 * @input  ImplementInput
 * @output ImplementOutput
 */

type Issue = {
  severity: "Critical" | "High" | "Medium" | "Low";
  description: string;
};

type ImplementInput = {
  session_id: string;
  plan_filepath: string;
  iteration: number;
  prior_issues: Issue[];
  tdd_mode: boolean;
};

type ImplementOutput = {
  request_file: string;
};
```

## Operations

```typespec
op determine_scope(
  plan_filepath: string,
  iteration: integer,
  prior_issues: Issue[]
) -> ScopeResult {
  // iteration == 1: read plan_filepath, extract tasks
  // iteration > 1: filter prior_issues to
  //                Critical/High only
  // Exclude pre-existing issues unrelated to plan goal
}

op detect_language() -> LanguageResult {
  // File extensions:
  //   .go / go.mod          => "go"
  //   .py / pyproject.toml  => "python"
  //   .ts / .tsx / package.json => "typescript"
  //   .rs / Cargo.toml      => "rust"
  // No match => null
}

op write_request(
  session_id: string,
  iteration: integer,
  scope: ScopeResult,
  language: LanguageResult,
  tdd_mode: boolean
) -> ImplementOutput {
  // Build natural-language request for
  // task-coordinator and write to
  // {session_dir}/sw-implement-request-{iteration}.md
}
```

## Execution

```text
determine_scope -> detect_language -> write_request
```

### determine_scope

- If `iteration == 1`: read `plan_filepath` and extract
  all tasks/changes to implement.
- If `iteration > 1`: filter `prior_issues` to severity
  "Critical" and "High" only.
- Exclude pre-existing issues unrelated to the plan goal.

### detect_language

- Detect from file extensions: `.go` → "go",
  `.py` → "python", `.ts`/`.tsx` → "typescript",
  `.rs` → "rust".
- Detect from project manifests: `go.mod` → "go",
  `pyproject.toml` → "python", `Cargo.toml` → "rust",
  `package.json` → "typescript".
- Return null if no supported language detected.

### write_request

Build
`{session_dir}/sw-implement-request-{iteration}.md`
with this content structure:

```markdown
# Implementation Request

## Scope

{scope items as bullet list}

## Instructions

- Implement ALL scope items completely.
- Do not fix pre-existing issues unrelated to the scope.
  {if language detected:}
- Invoke skill(name: "language-pro") for {language}
  best practices.
  {if tdd_mode:}
- Invoke skill(name: "test-driven-development") and
  follow its Red-Green-Refactor workflow.
```

Return `{ request_file: path }`.

## Session Files

All files saved to
`~/.copilot/session-state/{session_id}/files/`:

| File                          | Written by    | Read by                  |
| ----------------------------- | ------------- | ------------------------ |
| `sw-implement-request-{n}.md` | write_request | structured-workflow main |

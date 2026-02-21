# Implementation Patterns

Variable binding contracts and session-path invariants for the multi-agent implementation planning workflow.
SKILL.md `## Operations` and `## Execution` are the single source of truth for pipeline orchestration.

## Invariants

```typespec
invariant: (sessionFilesDir not contains "session-state/{sessionId}/files/") => abort("Session path must include sessionId segment");
invariant: (timestamp not matches /^\d{14}$/) => abort("Timestamp must match YYYYMMDDHHMMSS");
invariant: (finalOutputFilename not matches /^[a-z]+-[a-z0-9-]+-\d+\.md$/) => abort("Final plan filename must match {purpose}-{component}-{version}.md");
invariant: (delegationOp redefines SKILL.md execution order) => abort("Delegation ops must not mirror or redefine SKILL.md pipeline; single source of truth is SKILL.md ## Execution");
```

## Appendix A: Variable Binding Contracts

Canonical mapping from legacy placeholders to camelCase variable names. This table is the single authoritative
dictionary — no other file may define an alternate mapping.

| Legacy Placeholder   | Canonical camelCase | Binding Owner (file / section)                                           |
| -------------------- | ------------------- | ------------------------------------------------------------------------ |
| `{user_request}`     | `userRequest`       | SKILL.md `analyze` op; analysis-prompt.md InputContext                   |
| `{codebase_context}` | `codebaseContext`   | SKILL.md `analyze` op; analysis-prompt.md InputContext                   |
| `{session-id}`       | `sessionId`         | SKILL.md `synthesize` op; synthesis-prompt.md InputContext               |
| `{output_filepath}`  | `outputFilepath`    | analysis-prompt.md InputContext; synthesis-prompt.md InputContext        |
| `{purpose}`          | `purpose`           | SKILL.md `@invariants` FinalNaming; synthesis-prompt.md `savePlan` op    |
| `{component}`        | `component`         | SKILL.md `@invariants` FinalNaming; synthesis-prompt.md `savePlan` op    |
| `{version}`          | `version`           | SKILL.md `@invariants` FinalNaming; synthesis-prompt.md `savePlan` op    |
| `{timestamp}`        | `timestamp`         | SKILL.md `@invariants` TimestampFormat; all delegation outputFilePattern |

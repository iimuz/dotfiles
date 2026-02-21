---
name: commit-staged
description: Commit staged changes using Conventional Commit parameters (validates inputs).
---

# Commit Staged Changes

## Overview

Execute a Conventional Commits 1.0.0-compliant git commit from already-staged changes, automatically deriving type
and message without user confirmation.

## Interface

```typescript
/**
 * @skill commit-staged
 * @input  { /* implicit: current git staged state */ }
 * @output { commit: CommitRef }
 */

type CommitType =
  | "build" | "chore" | "ci"   | "docs" | "feat" | "fix"
  | "i18n"  | "perf"  | "refactor" | "revert" | "style" | "test";

type CommitParams = {
  type:         CommitType;
  description:  string;   // imperative English, no trailing period, max 100 chars with type prefix
  body?:        string;   // optional; bullet lines each starting with "-"
};

type StagedDiff = { files: string[]; diff: string };

type CommitRef = { sha: string; message: string };

/**
 * @invariants
 * 1. Zero_Verbosity:      imperative sentences => remove
 * 2. Signature_Integrity: all ops fully typed
 * 3. Script_Root:         scripts => execute from git repository root, not skill directory
 * 4. Staged_Only:         never stage or unstage files; operate on current staged state only
 */
```

## Operations

```typespec
op inspect_staged() -> StagedDiff {
  bash(script: @scripts/staged-files.sh);
  invariant: (staged_empty) => abort("no staged files to commit");
}

op analyze(diff: StagedDiff) -> CommitParams {
  // Derive type from @references/types.md; description: natural language summary of what changed and why
  invariant: (description_is_filepath) => abort("description must be natural language, not a file path");
  invariant: (description_empty)       => abort("description is required");
}

op commit(params: CommitParams) -> CommitRef {
  bash(script: @scripts/commit.sh, args: {
    "--type": params.type, "--description": params.description, "--body": params.body
  });
  invariant: (type_invalid)   => abort("invalid type; see references/types.md");
  invariant: (commit_fails)   => abort("git commit failed");
}
```

## Execution

```text
inspect_staged -> analyze -> commit
```

Execute scripts via absolute path from the git repository root. Type reference: [`references/types.md`](references/types.md).

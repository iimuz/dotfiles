---
name: commit-staged
description: Commit staged changes using Conventional Commit parameters (validates inputs).
user-invocable: true
disable-model-invocation: false
---

# Commit Staged Changes

## Overview

Execute a Conventional Commits 1.0.0-compliant git commit from already-staged changes,
automatically deriving type and message without user confirmation.

Execution order: inspect staged files -> analyze diff -> commit.
Execute all scripts from the git repository root, not from the skill directory.
Never stage or unstage files; operate on the current staged state only.

## Input

No explicit input. The skill reads the current git staged state.

## Output

- `sha: string`: The commit SHA created by the commit script.
- `message: string`: The full commit message.

## Operations

### Inspect Staged Files

Run [`scripts/staged-files.sh`](scripts/staged-files.sh) to collect the staged file list
and diff. Abort if no files are staged.

### Analyze Diff

Derive the commit type from [`references/types.md`](references/types.md) and write a
natural-language description summarizing what changed and why. The description must be
imperative English, have no trailing period, and fit within 100 characters including the
type prefix. Abort if the description is empty or is a file path instead of natural language.
Optionally produce a body with bullet lines each starting with `-`.

### Commit

Run [`scripts/commit.sh`](scripts/commit.sh) with `--type`, `--description`, and
optionally `--body`. Abort if the type is not listed in
[`references/types.md`](references/types.md) or if git commit fails.

## Examples

- Happy: 3 files staged with a bug fix -- commit created as `fix: resolve token expiration`.
- Failure: no staged files -- abort with "no staged files to commit".

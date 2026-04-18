---
name: git-commit
description: Conventional Commits-compliant git commit execution logic.
user-invocable: true
disable-model-invocation: false
---

# Git Commit

## Overview

Execute a Conventional Commits 1.0.0-compliant git commit, automatically deriving
type and message from the current working tree or staged state. If no files are staged,
stage all changes before committing.

Execute all scripts from the git repository root, not from the skill directory.

## Output

- `sha: string`: The commit SHA created by the commit script.
- `message: string`: The full commit message.

## Operations

### Prepare Staged Changes

Run `git diff --staged --name-only` to detect staged files.

- If files are already staged, skip to collecting the diff.
- If nothing is staged, run `git add -A` to stage all changes.
- If still nothing is staged after `git add -A`, abort with "no changes to commit".

Collect the staged file list with `git diff --staged --name-only` and the full diff with
`git --no-pager diff --staged`.

### Analyze Diff

Derive the commit type from [`references/types.md`](references/types.md) and write a
natural-language description summarizing what changed and why. The description must be
imperative English, have no trailing period, and fit within 100 characters including the
type prefix. Abort if the description is empty or is a file path instead of natural language.
Optionally produce a body with bullet lines each starting with `-`.

### Commit

Run [`scripts/commit.sh`](scripts/commit.sh) with `--type`, `--description`, and
optionally `--body`, plus `--json` for structured output. Abort if the type is not listed
in [`references/types.md`](references/types.md) or if git commit fails.

Return the JSON output from commit.sh as the final result.

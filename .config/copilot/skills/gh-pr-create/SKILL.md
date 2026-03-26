---
name: gh-pr-create
description: Create GitHub pull request drafts using Conventional Commit parameters (validates inputs).
---

# PR Draft

## Overview

Create a draft pull request on GitHub with a Conventional Commits-style title and a
standardized body, using the shipped shell scripts.

Execute all scripts from the target git repository root, never from the skill directory.
Use only the shipped scripts; do not run extra git or gh commands. Title must be natural
language in imperative mood with no trailing period and no file paths. Title and body
default to English unless the user explicitly requests another language.

## Operations

### Check Branch Status

Run `bash scripts/check-branch-status.sh [--base <branch>]` to inspect uncommitted
changes, commit history, and diff statistics. Abort if the branch has no commits
differing from the base.

### Create Draft PR

Choose type from [references/type-reference.md](references/type-reference.md), write a
title and change bullets, then run `bash scripts/create-pr.sh` with accepted flags.
Pass `--changes` as bullet lines starting with `-`. The script validates type and
required parameters; abort on validation errors.

Accepted flags: `--type`, `--title`, `--changes`, `--related-urls`, `--confirmation`,
`--review-points`, `--limitations`, `--additional`, `--base`.

Output body structure: [references/output-format.md](references/output-format.md).

## Examples

- Happy: branch has 3 commits fixing auth -- draft PR created as `fix: resolve token expiration`.
- Failure: no differing commits from base branch -- abort after check-branch-status.

```bash
bash scripts/check-branch-status.sh --base main
bash scripts/create-pr.sh --type docs --title "clarify PR draft skill" \
  --changes "- rewrite the skill overview
- extract the type reference
- extract the PR body template" \
  --base main
```

```bash
bash scripts/check-branch-status.sh
bash scripts/create-pr.sh --type fix --title "resolve token expiration" \
  --changes "- update token refresh logic
- add proper error handling for expired tokens" \
  --confirmation "- tested token refresh flow" \
  --review-points "- token refresh timing" \
  --limitations "- requires frontend update for new error codes"
```

---
name: git-commit
description: >
  Create a git commit from current changes.
  Trigger on commit requests or after completing a code change task.
---

# Git Commit

## Overview

Analyze the current working tree, derive a Conventional Commits 1.0.0-compliant
message, and commit. Always execute from the git repository root.

## Process

### 1. Stage

1. Run `git diff --staged --name-only`.
2. If nothing staged, selectively stage only files related to the current task.
3. If still nothing staged, abort: "no changes to commit".

### 2. Analyze

1. Collect diff: `git --no-pager diff --staged`.
2. Derive type from [`references/types.md`](references/types.md).
3. Write description: imperative English, no trailing period, ≤100 chars including type prefix.
4. Optionally add body with `-` bullet lines.

### 3. Commit

Run [`scripts/commit.sh`](scripts/commit.sh) with the following options.
Do NOT read the script; use it as a black box.

- `--type <string>` (required): Commit type derived from step 2
- `--description <string>` (required): Commit description derived from step 2
- `--body <string>` (optional): Body text, may contain newlines
- `--json` (required): Flag. Enables JSON output (`sha`, `message`) to stdout

Example:

```bash
scripts/commit.sh \
  --type feat \
  --description "add user authentication endpoint" \
  --body "- add POST /auth/login route
- implement JWT token generation
- add input validation middleware" \
  --json
```

Return the JSON output as the final result.

## Constraints

- Abort if description is empty or is a file path.
- Abort if type is not in [`references/types.md`](references/types.md).
- Abort if git commit fails.

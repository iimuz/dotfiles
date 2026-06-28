---
name: git-commit
description: >
  Create a git commit from current changes.
  Trigger on commit requests or after completing a code change task.
user-invocable: true
disable-model-invocation: false
---

# Git Commit

## Overview

Analyze the current working tree, derive a Conventional Commits 1.0.0-compliant
message, and commit. Always execute from the git repository root.

SKILL_DIR is the absolute path of the directory containing this SKILL.md.
Derive it from the path at which Claude Code loaded this file.
Use it for all script references.

## Process

### 1. Stage

1. Run `git diff --staged --name-only` to check staged files.
2. If nothing staged:
   a. Run `git diff --name-only` to list unstaged tracked changes.
   b. Run `git ls-files --others --exclude-standard` to list untracked files.
   c. Using the conversation context (what task was just completed),
   file paths, and diff content, identify task-related files.
   d. Stage only the identified task-related files with `git add <file>...`.
3. If still nothing staged, abort with an informative message that lists
   the unstaged files found in step 2 (if any).

### 2. Analyze

1. Collect diff: `git --no-pager diff --staged`.
2. Derive type from [`references/types.md`](references/types.md).
3. Write description: imperative English, no trailing period, ≤100 chars including type prefix.
4. Optionally add body with `-` bullet lines.

### 3. Commit

Run `bash "${SKILL_DIR}/scripts/commit.sh"` with the following options.
Do NOT read the script; use it as a black box.

- `--type <string>` (required): Commit type derived from step 2
- `--description <string>` (required): Commit description derived from step 2
- `--body <string>` (optional): Body text, may contain newlines
- `--no-json` (optional): Flag. Disables JSON output to stdout (for human/interactive use).
- `--json` (optional): Flag. Accepted for backward compatibility. JSON output (`sha`, `message`) is on by default.

Example:

```bash
bash "${SKILL_DIR}/scripts/commit.sh" \
  --type feat \
  --description "add user authentication endpoint" \
  --body "- add POST /auth/login route
- implement JWT token generation
- add input validation middleware"
```

Return the JSON output as the final result.

## Constraints

- Abort if description is empty or is a file path.
- Abort if type is not in [`references/types.md`](references/types.md).
- Abort if git commit fails.

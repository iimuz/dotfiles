---
name: draft-review
description: Create pending PR review drafts with comments and suggestions.
user-invocable: true
disable-model-invocation: false
---

# Draft Review Skill

## Overview

Run `scripts/create_review.sh` to create a pending review on a GitHub PR. The
script accepts repository coordinates, a PR number, and a JSON array of inline
comments as CLI arguments. It validates inputs, calls the GitHub API via `gh`,
and prints a JSON result to stdout.

Required arguments:

- `--owner` — Repository owner.
- `--repo` — Repository name.
- `--pull-number` — PR number.
- `--comments-json` — JSON array of comment objects (see Schema).

Optional arguments:

- `--summary-body` — Review summary body text.

On success, stdout contains `{ "id": <number>, "html_url": "<url>" }`.
On failure, stderr contains an error message and the script exits non-zero.

## Schema

The `--comments-json` argument expects a JSON array where each element matches
the `ReviewComment` shape. The script output matches `ReviewResult`.

```typescript
type ReviewComment = {
  path: string;
  line: number;
  body: string;
  suggestion?: string;
  start_line?: number;
  side?: "LEFT" | "RIGHT";
};

type ReviewResult = {
  id: number;
  html_url: string;
};
```

Field descriptions for `ReviewComment`:

- `path` (required) — File path relative to the repository root.
- `line` (required) — Line number to attach the comment to.
- `body` (required) — Comment body text.
- `suggestion` (optional) — Code suggestion content. The script wraps it in a
  GitHub suggestion block automatically.
- `start_line` (optional) — Start line for multi-line comments.
- `side` (optional) — Diff side: `"LEFT"` or `"RIGHT"`.

## Constraints

- Invoke only `scripts/create_review.sh`; do not call the GitHub API directly.
- Pass all inputs as CLI arguments; do not use environment variables for review data.
- Provide `--comments-json` as a valid JSON array with at least one element.
- Include `path`, `line`, and `body` for every comment object.
- Keep suggestion text free of triple backticks because the script wraps suggestions
  in a fenced suggestion block.
- Treat created reviews as pending drafts; submit them manually via the GitHub UI.

## Examples

### Happy Path

```sh
bash ./scripts/create_review.sh \
  --owner "myorg" \
  --repo "myrepo" \
  --pull-number 42 \
  --summary-body "Looks good overall, a few nits." \
  --comments-json '[
    {"path":"src/main.py","line":10,"body":"Consider renaming this variable."},
    {"path":"src/utils.py","line":25,"body":"Suggested fix:","suggestion":"return value + 1"}
  ]'
```

Stdout: `{ "id": 12345, "html_url": "https://github.com/myorg/myrepo/pull/42#pullrequestreview-12345" }`

### Failure Path

```sh
bash ./scripts/create_review.sh \
  --owner "myorg" \
  --repo "myrepo" \
  --pull-number 42 \
  --comments-json '[{"path":"src/main.py"}]'
```

Stderr reports missing `line` and `body` fields. Exit code is non-zero.
Fix the comment object and rerun the command.

---
name: gh-pr-review
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

Invoke only `scripts/create_review.sh`; do not call the GitHub API directly.
Pass all inputs as CLI arguments; do not use environment variables for review data.
Provide `--comments-json` as a valid JSON array with at least one element.
Include `path`, `line`, and `body` for every comment object.
Keep suggestion text free of triple backticks because the script wraps suggestions
in a fenced suggestion block.
Treat created reviews as pending drafts; submit them manually via the GitHub UI.

## Input

- `--owner` (required): Repository owner.
- `--repo` (required): Repository name.
- `--pull-number` (required): PR number.
- `--comments-json` (required): JSON array of comment objects. Each object requires:
  - `path: string` — File path relative to the repository root.
  - `line: number` — Line number to attach the comment to.
  - `body: string` — Comment body text.
  - `suggestion: string` (optional) — Code suggestion content. The script wraps it
    in a GitHub suggestion block.
  - `start_line: number` (optional) — Start line for multi-line comments.
  - `side: "LEFT" | "RIGHT"` (optional) — Diff side.
- `--summary-body` (optional): Review summary body text.

## Output

On success, stdout contains `{ "id": {number}, "html_url": "{url}" }`.
On failure, stderr contains an error message and the script exits non-zero.

## Examples

- Happy: `--owner "myorg" --repo "myrepo" --pull-number 42 --comments-json '[...]'`
  — review created, returns JSON with id and url.
- Failure: comment object missing `line` and `body` — stderr error, non-zero exit.

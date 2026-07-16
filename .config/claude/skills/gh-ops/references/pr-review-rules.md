# PR Review Rules

Create a pending review on a GitHub PR with inline comments via
`scripts/create_review.sh`.

## Choosing the Script

- New review (no pending review on the PR): use `scripts/create_review.sh`.
- A pending review already exists: use `scripts/append_review.sh` to add
  comments to it.

`create_review.sh` detects an existing pending review and aborts with
`{"error": "pending_review_exists", "review_id": <id>}` instead of failing
with a raw API error. When you see this, switch to `append_review.sh`, or
submit/discard the existing review first.

## Procedure

Follow these steps in order. Stop on any failure.

### Step 1: Compose Comments

Prepare inline comments for the review. Each comment requires:

- `path: string` – File path relative to the repository root
- `line: number` – Line number to attach the comment to
- `body: string` – Comment body text

Optional per comment:

- `suggestion: string` – Code suggestion content. Do not include triple backticks;
  the script wraps it in a GitHub suggestion block automatically.
- `start_line: number` – Start line for multi-line comments
- `side: "LEFT" | "RIGHT"` – Diff side

Provide `--comments-json` as a valid JSON array with at least one element.

### Step 2: Create Review

Required flags:

- `--owner` – Repository owner
- `--repo` – Repository name
- `--pull-number` – PR number
- `--comments-json` – JSON array of comment objects (at least one element required)

Optional flags:

- `--summary-body` – Review summary body text

```bash
bash "${SKILL_DIR}/scripts/create_review.sh" \
  --owner "<owner>" \
  --repo "<repo>" \
  --pull-number <number> \
  --comments-json '<json array>' \
  [--summary-body "<text>"]
```

On success, stdout contains `{ "id": {number}, "html_url": "{url}" }`.
On failure, stderr contains an error message and the script exits non-zero.

If the script reports `pending_review_exists`, do not retry `create_review.sh`.
Append the comments with `scripts/append_review.sh` instead:

```bash
bash "${SKILL_DIR}/scripts/append_review.sh" \
  --owner "<owner>" \
  --repo "<repo>" \
  --pull-number <number> \
  --comments-json '<json array>'
```

On success, stdout contains
`{ "review_id": "<id>", "added": <count>, "thread_ids": [ ... ] }`.
`append_review.sh` takes the same comment objects as `create_review.sh` but
has no `--summary-body` flag. If no pending review exists it reports
`{"error": "no_pending_review"}`; use `create_review.sh` in that case.

### Step 3: Do Not Submit the Review

The review is created as a pending draft. Do not submit it via the CLI. The
user will submit it manually via the GitHub UI when ready.

## Output

On success: `{ "id": {number}, "html_url": "{url}" }`

On failure: error message on stderr, non-zero exit code.

## Examples

```bash
bash "${SKILL_DIR}/scripts/create_review.sh" \
  --owner "myorg" \
  --repo "myrepo" \
  --pull-number 42 \
  --comments-json '[{"path":"src/auth.py","line":42,"body":"Add null check here"}]'
```

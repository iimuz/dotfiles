# Issue Comment Rules

## Overview

Post a structured comment to a GitHub Issue with a visible summary and zero or more
collapsible details sections. The script enforces the output format via jq validation;
the AI composes content, confirms with the user, then posts.

Execution order: compose content -> confirm with user -> post comment.
Execute the script from the git repository root, not from the skill directory.

## Input

- `repo: string` (required): Target repository, passed as `--repo OWNER/REPO`.
- `issue_number: number` (required): Target issue number, passed as `--issue NUMBER`.
- `summary: string` (required, markdown): Visible summary for the comment body. Keep it
  self-contained so the reader can understand the conclusion and next actions without
  expanding details.
- `details: array<{ label: string, content: string }>`: Optional collapsible sections
  passed in stdin JSON. Each entry uses `label: string` (required) for the `<summary>`
  text and `content: string` (required, markdown) for the section body.

Content is provided via stdin JSON:

```json
{
  "summary": "string",
  "details": [{ "label": "string", "content": "string" }]
}
```

If `details` is omitted or empty, a summary-only comment is posted.

## Operations

### Compose Content

Prepare summary and details from investigation results, review findings, or incident
analysis. The summary must be self-contained, while each details entry should capture
one evidence set, analysis thread, or supporting report section.

### Confirm with User

Present the composed summary and details to the user and get explicit approval before
posting. Do not post without that confirmation.

### Post Comment

Run `bash scripts/post-comment.sh` with `--repo OWNER/REPO` and `--issue NUMBER`.
Pipe the composed JSON payload through stdin.

The script validates the JSON, assembles the comment body, and posts via
`gh issue comment`. On success it prints the comment URL to stdout.

## Output

- `url: string`: URL of the posted comment returned by `gh issue comment`.

## Examples

### Multi-Details

```bash
cat <<'EOF' | bash scripts/post-comment.sh --repo "owner/repo" --issue 42
{
  "summary": "## Investigation Results\n\nRoot cause identified. Creating a fix PR.",
  "details": [
    {
      "label": "Log Analysis",
      "content": "Error log details..."
    },
    {
      "label": "Reproduction Steps",
      "content": "1. Step A\n2. Step B"
    }
  ]
}
EOF
```

### Summary-Only

```bash
cat <<'EOF' | bash scripts/post-comment.sh --repo "owner/repo" --issue 42
{
  "summary": "## Completion Report\n\nAll checks passed successfully."
}
EOF
```

## Notes

- If the body exceeds 65536 characters, shorten the details before retrying.
- When a temporary file is needed for inspection or retry logic, keep using
  `gh issue comment --body-file` rather than inline shell quoting.

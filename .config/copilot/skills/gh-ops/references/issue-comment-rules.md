# Issue Comment Rules

Post a structured comment to a GitHub Issue with a visible summary and zero or more
collapsible details sections.

## Procedure

Follow these steps in order. Stop on any failure.

### Step 1: Compose Content

Prepare summary and details from investigation results, review findings, or incident
analysis.

Provide content as stdin JSON:

```json
{
  "summary": "string (required, markdown)",
  "details": [{ "label": "string", "content": "string" }]
}
```

- `summary`: Visible summary for the comment body. Keep it self-contained so the reader
  can understand the conclusion and next actions without expanding details.
- `details`: Optional array of collapsible sections. Each entry requires:
  - `label: string` – Text for the `<summary>` element
  - `content: string` – Markdown body for the collapsible section

If `details` is omitted or empty, a summary-only comment is posted.

### Step 2: Confirm with User

Present the composed summary and details. Proceed only after explicit approval.

### Step 3: Post Comment

Required flags:

- `--repo OWNER/REPO` – Target repository
- `--issue NUMBER` – Target issue number

```bash
cat <<'EOF' | bash scripts/post-comment.sh --repo "OWNER/REPO" --issue NUMBER
{
  "summary": "...",
  "details": [...]
}
EOF
```

The script validates the JSON, assembles the comment body, and posts it.
On success it prints the comment URL to stdout.

If the body exceeds 65536 characters, shorten the details before retrying.

## Output

- `url: string`: URL of the posted comment printed to stdout by the script.

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

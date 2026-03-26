# Invocation Examples

## Multi-Details

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

## Summary-Only

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

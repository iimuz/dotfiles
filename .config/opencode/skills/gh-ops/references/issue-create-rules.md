# Issue Create Rules

## Overview

Create a GitHub Issue with a structured body using one of two templates:
product-backlog (parent issue) or feature (work item). The script validates input,
builds the body from the selected template, and creates the issue via gh issue create.

Execution order: determine type -> compose content -> confirm with user -> create issue.
Execute the script from the git repository root, not from the skill directory.

## Input

- `type: string` (required): Issue type, passed as `--type`. Must be `product-backlog`
  or `feature`. See Issue Type Reference below.
- `repo: string` (optional): Target repository, passed as `--repo OWNER/REPO`. Defaults
  to the current repository.
- `labels: string` (optional): Comma-separated labels, passed as `--labels`.
- `assignees: string` (optional): Comma-separated assignees, passed as `--assignees`.
- `project: string` (optional): Project name, passed as `--project`.

Content is provided via stdin JSON:

```json
{
  "title": "string (required)",
  "overview": "string (product-backlog)",
  "details": "string",
  "goal": "string",
  "notes": "string (product-backlog)",
  "related_urls": "string (feature)"
}
```

## Issue Type Reference

- product-backlog: Parent issue defining a product goal and its scope. Contains
  overview, details, goal, and notes sections.
- feature: Work item issue linked to a product backlog. Contains related URLs, goal,
  and details sections.

## Operations

### Determine Type

Ask the user which issue type to create (product-backlog or feature). Infer from
context when the intent is clear.

### Compose Content

Prepare title and body fields based on the selected template. See Body Templates below.

### Confirm with User

Present the composed issue content to the user and get explicit approval before
creating. Do not create without that confirmation.

### Create Issue

Run `bash scripts/create-issue.sh` with `--type` and optional metadata flags. Pipe
the composed JSON payload through stdin.

The script validates the JSON, builds the body from the template, and creates the
issue via `gh issue create`. On success it prints the issue URL to stdout.

## Body Templates

### Product Backlog Body Template

The script builds the product-backlog issue body from this section structure.
Each {field} is replaced with the corresponding JSON input value.
Sections with empty content include only the header.

```markdown
## Overview

{overview}

## Details

{details}

## Goal

{goal}

## Notes

{notes}
```

### Feature Body Template

The script builds the feature issue body from this section structure.
Each {field} is replaced with the corresponding JSON input value.
Sections with empty content include only the header.

```markdown
## Related URLs

{related_urls}

## Goal

{goal}

## Details

{details}
```

## Output

- `url: string`: URL of the created issue returned by `gh issue create`.
- With `--json`: `{ "number": number, "url": string }`.

## Examples

```bash
cat <<'EOF' | bash scripts/create-issue.sh --type product-backlog --labels "backlog"
{
  "title": "User authentication system",
  "overview": "Implement user authentication to support login and registration flows.",
  "details": "Use OAuth 2.0 with JWT tokens for session management.",
  "goal": "Users can sign up, log in, and maintain authenticated sessions.",
  "notes": "Consider rate limiting for login endpoints."
}
EOF
```

```bash
cat <<'EOF' | bash scripts/create-issue.sh --type feature --repo "owner/repo" --labels "feature" --assignees "@me"
{
  "title": "Implement login endpoint",
  "related_urls": "- parent: #42",
  "goal": "POST /api/login returns a valid JWT token for correct credentials.",
  "details": "Validate email and password against the user store. Return 401 for invalid credentials."
}
EOF
```

# Issue Create Rules

Create a GitHub Issue with a structured body using one of two templates:
product-backlog (parent issue) or feature (work item).

## Procedure

Follow these steps in order. Stop on any failure.

### Step 1: Determine Type

Select one based on intent:

- `product-backlog` – Parent issue defining a product goal and its scope. Contains
  overview, details, goal, and notes sections.
- `feature` – Work item issue linked to a product backlog. Contains related URLs, goal,
  and details sections.

Ask the user which type to create. Infer from context when intent is clear.

### Step 2: Compose Content

Prepare title and body fields based on the selected template. See Body Templates below.

Provide content as stdin JSON:

```json
{
  "title": "string (required)",
  "overview": "string (product-backlog only)",
  "details": "string",
  "goal": "string",
  "notes": "string (product-backlog only)",
  "related_urls": "string (feature only)"
}
```

### Step 3: Confirm with User

Present the composed issue content. Proceed only after explicit approval.

### Step 4: Create Issue

Required flags:

- `--type` – Issue type from Step 1

Optional flags:

- `--repo OWNER/REPO` – Target repository (defaults to current repository)
- `--labels` – Comma-separated labels
- `--assignees` – Comma-separated assignees
- `--project` – Project name

Recommended JSON fields per type:

- `product-backlog`: `title` (required), `overview`, `details`, `goal`, `notes`
- `feature`: `title` (required), `related_urls`, `goal`, `details`

```bash
cat <<'EOF' | bash scripts/create-issue.sh --type <type> [optional flags]
{
  "title": "...",
  ...
}
EOF
```

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

- `url: string`: URL of the created issue printed to stdout by the script.
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

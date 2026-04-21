# Jira Analysis Rules

Read a single Jira issue in full and produce a structured summary focused
on the user's activity within a specified date range. Fetch the complete
history to understand context, then scope the summary to the target period.

The caller provides these parameters:

- `key`: Jira issue key (e.g., `API-15`)
- `project_name`: Project display name (e.g., `基盤API Team`)
- `cloud_id`: Atlassian cloud ID
- `date`: Start date of the target period (YYYY-MM-DD)
- `end_date`: End date of the target period (YYYY-MM-DD)
- `atlassian_user_id`: Atlassian account ID of the target user
- `output_filepath`: Absolute path where the summary markdown file must be written

## Procedure

1. Fetch the full issue using `atlassian-getJiraIssue` with:
   - `cloudId`: the provided `cloud_id`
   - `issueIdOrKey`: the provided `key`
   - `fields`: `["summary", "status", "issuetype", "priority",
"description", "comment", "assignee", "reporter", "created",
"updated", "labels", "parent"]`
   - `responseContentFormat`: `markdown`

2. Read the complete issue including description and all comments to
   understand the full context.
3. Identify actions taken by the target user (matching `atlassian_user_id`
   against comment author account IDs) within the `date` to `end_date`
   period (inclusive). Look for:
   - Comments authored by the user
   - Status changes (visible in comment text or status field)
   - Assignment changes

4. Produce the summary in the output format below.

## Output

Write the summary as a markdown file to `output_filepath`. Capture the
full context while focusing on the target period. Write in the same
language as the issue content (Japanese if the content is in Japanese).

```md
# Jira Activity Summary

- Source: Jira
- Project: project_name (PROJECT_KEY)
- Key: PROJECT-123
- Title: Issue title
- URL: https://site.atlassian.net/browse/PROJECT-123
- Status: status name
- Type: issue type
- Period: YYYY-MM-DD - YYYY-MM-DD

## Context

Brief overview of what this issue is about, based on the full history.
Include background and purpose so a reader unfamiliar with the project
can understand the significance.

## User Activity in Period

- Specific action 1 with timestamp context
- Specific action 2 with timestamp context

## Outcomes

- Concrete result or current status as of the period end

## Decisions

- Decision made during the period and its rationale
```

Omit the Decisions section if no decisions were identified during the period.

If the user had no direct activity during the period (only assigned or
mentioned), still produce the summary but note the indirect involvement.

# Activity Analysis Rules

Read a single GitHub issue or pull request in full and produce a structured
summary focused on the user's activity within a specified date range. Fetch
the complete history to understand context, then scope the summary to the
target period.

The caller provides these parameters:

- `type`: `issue` or `pr`
- `owner`: Repository owner
- `repo`: Repository name
- `number`: Issue or PR number
- `date`: Start date of the target period (YYYY-MM-DD)
- `end_date`: End date of the target period (YYYY-MM-DD)
- `github_user`: GitHub username of the target user
- `output_filepath`: Absolute path where the summary markdown file must be written

## Procedure

1. Fetch the full issue or PR with all comments and metadata.
2. Read the complete history to understand the full context.
3. Identify actions taken by `github_user` within the `date` to `end_date`
   period (inclusive).
4. Produce the summary in the output format below.

### Fetching Data

For issues:

```bash
gh issue view NUMBER --repo OWNER/REPO --json title,body,comments,labels,state,createdAt,closedAt,author,assignees,url
```

For pull requests:

```bash
gh pr view NUMBER --repo OWNER/REPO --json title,body,comments,reviews,files,labels,state,createdAt,closedAt,mergedAt,mergedBy,author,assignees,url,headRefName,baseRefName,additions,deletions
```

### Identifying User Activity

Scan the full timeline for actions by `github_user` within the date range:

- Comments authored by the user
- Reviews submitted by the user (for PRs)
- State changes (opened, closed, merged, reopened) by the user
- Label or assignee changes by the user (if visible in comments)
- Code changes pushed by the user (for PRs, visible in review comments or
  commit references)

If no activity by the user is found within the date range, still produce the
summary but note that the user's involvement was indirect (mentioned,
assigned, or subscribed).

## Output

Write the summary as a markdown file to `output_filepath`. Capture the full
context while focusing on the target period. Write in the same language as
the issue/PR content (Japanese if the content is in Japanese).

```md
# Activity Summary

- Type: Issue | Pull Request
- Repository: owner/repo
- Number: #N
- Title: Title text
- URL: https://github.com/...
- State: open | closed | merged
- Branch: head-ref -> base-ref (PRs only, omit for issues)
- Period: YYYY-MM-DD - YYYY-MM-DD

## Context

Brief overview of what this issue/PR is about, based on the full history.
Include background and purpose so a reader unfamiliar with the project can
understand the significance.

## User Activity in Period

- Specific action 1 with timestamp context
- Specific action 2 with timestamp context

## Outcomes

- Concrete result or current status as of the period end

## Decisions

- Decision made during the period and its rationale
```

Omit the Decisions section if no decisions were identified during the period.
Omit the Branch line for issues.

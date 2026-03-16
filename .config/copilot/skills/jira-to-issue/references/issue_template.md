# Issue Template

Use this template when creating GitHub Issues from JIRA tickets.

## Title Format

`[{Ticket ID}] {Jira Summary}`

Example: `[PROJ-123] Fix login button not responding on mobile devices`

## Body Structure

### Related Information

Jira Ticket: `[{Ticket ID}]({JiraURL})`

### Overview

Jira description or event details.

### Details

Organize detailed Jira information into sections:

Prerequisites: any required setup or conditions.

Reproduction Steps: numbered list of step-by-step instructions to reproduce the issue.

Expected Results: what should happen.

Actual Results: what actually happens.

Error Messages or Logs: any relevant error output or log entries.

### Additional Notes

Include any extra information if available: test environment details, specification document
links, related tickets or issues, workarounds or temporary fixes, screenshots or attachments.

## Label Requirements

Always add the `sqa-report` label to issues created from JIRA tickets.

## Command Example

```bash
gh issue create \
  --title "[PROJ-123] Issue title from JIRA summary" \
  --body "$(cat issue_body.md)" \
  --label "sqa-report" \
  --repo owner/repository
```

## Notes

- Preserve all relevant information from the JIRA ticket
- Use proper Markdown formatting for readability
- Include the direct link to the JIRA ticket in the Related Information section
- Organize reproduction steps as numbered lists for clarity
- Keep the structure consistent across all created issues

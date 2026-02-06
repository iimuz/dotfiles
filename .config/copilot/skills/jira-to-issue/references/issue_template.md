# Issue Template

Use this template when creating GitHub Issues from JIRA tickets.

## Title Format

```
[{Ticket ID}] {Jira Summary}
```

**Example:** `[PROJ-123] Fix login button not responding on mobile devices`

## Body Structure

```markdown
## Related Information

Jira Ticket: [{Ticket ID}]({JiraURL})

## Overview

{Jira description or event details}

## Details

{Organize detailed Jira information into Markdown sections:}

### Prerequisites
{Any required setup or conditions}

### Reproduction Steps
1. {Step-by-step instructions to reproduce the issue}
2. {Continue numbering each step}

### Expected Results
{What should happen}

### Actual Results
{What actually happens}

### Error Messages or Logs
{Any relevant error output or log entries}

## Additional Notes

{Include any extra information if available:}
- Test environment details
- Specification document links
- Related tickets or issues
- Workarounds or temporary fixes
- Screenshots or attachments
```

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

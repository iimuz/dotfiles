---
name: Convert JIRA Bug to GitHub Issue
description: Read a specified JIRA bug ticket and create a GitHub Issue with its details using a standardized Markdown template.
tools:
  - bash
  - gh
  - shell(gh issue create:*)
  - atlassian/getJiraIssue
---

Read the contents of the specified Jira ticket and create a GitHub Issue in the target repository.

## Input Information

- Jira Ticket: `{Jira Ticket URL}`
- Target Repository: `{GitHub Repository Name}`

## Procedure

1. Read the contents of the Jira ticket
2. Create the GitHub Issue body following the above template
3. Appropriately organize Jira details into corresponding Markdown sections
4. Create the Issue in the target repository
5. Add the `sqa-report` label

## Issue Template

### Title

`[{Ticket ID}] {Jira Summary}`

### Body Structure

```markdown
## Related Information

Jira Ticket: [{Ticket ID}]({JiraURL})

## Overview

{Jira description or event details}

## Details

{Organize detailed Jira information (prerequisites, reproduction steps, expected results, etc.) into Markdown sections}

## Additional Notes

{Include any extra information if available (test environment, specification document links, etc.)}
```

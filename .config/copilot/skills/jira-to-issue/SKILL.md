---
name: jira-to-issue
description: Convert JIRA bug tickets to GitHub Issues using a standardized Markdown template with proper formatting and labels.
---

# Jira To Issue

## Overview

Convert JIRA bug tickets to GitHub Issues by reading JIRA ticket details and creating properly formatted GitHub Issues with standardized structure and appropriate labels.

## When to Use

Use this skill when:
- User requests creating a GitHub Issue from a JIRA ticket
- User provides a JIRA ticket URL and wants it tracked in GitHub
- Need to migrate JIRA bug reports to GitHub Issues
- Converting SQA reports from JIRA to GitHub for tracking

## Workflow

Follow these steps to convert a JIRA ticket to a GitHub Issue:

### 1. Gather Required Information

- Obtain JIRA ticket URL from user
- Confirm target GitHub repository (owner/repo format)
- Verify access to both JIRA and GitHub

### 2. Read JIRA Ticket

- Use `atlassian/getJiraIssue` tool to fetch ticket details
- Extract key information:
  - Ticket ID
  - Summary/title
  - Description
  - Detailed information (reproduction steps, expected/actual results, etc.)
  - Any additional notes or attachments

### 3. Format Issue Content

Follow the template structure defined in `references/issue_template.md`:

**Title Format:**
```
[{Ticket ID}] {Jira Summary}
```

**Body Sections:**
- Related Information: Link back to original JIRA ticket
- Overview: Main description or event details
- Details: Organized sections for prerequisites, reproduction steps, expected results, actual results
- Additional Notes: Test environment, spec docs, workarounds

### 4. Create GitHub Issue

- Use `gh issue create` command with formatted content
- Apply the `sqa-report` label to categorize the issue
- Verify issue creation was successful

### 5. Confirm Completion

- Report the created issue URL to user
- Verify the issue contains all required information from JIRA
- Confirm proper labeling

## References

- Issue template structure: `references/issue_template.md`
- Always use imperative mood for instructions in the issue body
- Maintain Markdown formatting consistency across all created issues

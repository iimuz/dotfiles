---
mode: "agent"
tools: ['git_diff', 'git_log', 'git_show', 'git_status', 'create_pull_request']
description: "Create PR."
---

## Creating Pull Requests

Follow these steps when creating pull requests:

1. Check Branch Status.
   - `git_status`
   - `git_diff`
   - `git_diff` from develop to HEAD
   - `git_log`
1. Analyze Changes.
   - Check all commits since branching from develop
   - Understand the nature and purpose of the changes
   - Evaluate the impact on the project
   - Check for sensitive information
1. Confirm the PR title and description with the user.
1. Create Pull Request as **DRAFT** using `create_pull_request`.

## Important Notice

Use tools.
DO NOT use git command and gh command.

## Pull Request Example

Title

`:art: Improve error handling with Result type`

Body

```markdown
## Related URLs

## Changes

- Introduction of Result type using never throw
- Explicit type definition for error cases
- Addition of test cases

## Confirmation Results

<!-- Describe preconditions, steps, and results of confirmation if any -->

## Review Points

- Is the Result type used appropriately?
- Comprehensiveness of error cases
- Sufficiency of tests

## Limitations

<!-- Describe known limitations of this change or items to be addressed in a separate PR if any -->
```

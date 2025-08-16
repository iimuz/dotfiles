## Creating Pull Requests

Follow these steps when creating pull requests:

1. Check Branch Status
   - `git status`: Check for uncommitted changes
   - `git diff`: Check changes
   - `git diff main...HEAD`: Check differences from merge base
   - `git log`: Check commit history
1. Analyze Changes
   - Check all commits since branching from develop
   - Understand the nature and purpose of the changes
   - Evaluate the impact on the project
   - Check for sensitive information
1. Confirm the PR title and description with the user
1. Create Pull Request as Draft: `gh pr create --draft --title "title" --body "body"`

## Important Notes

1. Pull Request Related
   - Analyze all changes
1. Operations to Avoid
   - Using interactive git commands (-i flag)
   - Pushing directly to the remote repository
   - Changing git settings

## Pull Request Example

```bash
# Create pull request as draft
gh pr create --draft --title ":art: Improve error handling with Result type" --body "$(cat <<'EOF'
## Related URLs

## Changes

- Introduction of Result type using neverthrow
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
EOF
)"
```

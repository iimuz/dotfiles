---
name: gh-ops
description: >
  Use for GitHub operations: creating issues, posting issue comments,
  creating draft PRs, and adding PR review comments.
---

# GitHub Operations

## Global Constraints

- Execute all scripts from the git repository root
- Use only shipped scripts; do not run extra git or gh commands
- Do NOT read the script; use it as a black box.
- Always confirm content with the user before any write operation
- Default language is English unless user explicitly requests otherwise
- On script validation error or API failure: show raw error, stop

## Routing

- Issue Create: [`references/issue-create-rules.md`](references/issue-create-rules.md)
- Issue Comment: [`references/issue-comment-rules.md`](references/issue-comment-rules.md)
- PR Create: [`references/pr-create-rules.md`](references/pr-create-rules.md)
- PR Review: [`references/pr-review-rules.md`](references/pr-review-rules.md)

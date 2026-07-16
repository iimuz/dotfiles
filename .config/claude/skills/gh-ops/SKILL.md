---
name: gh-ops
description: >
  Use for GitHub operations: creating issues, posting issue comments,
  creating draft PRs, and adding PR review comments.
---

# GitHub Operations

## Global Constraints

- SKILL_DIR is the absolute path of the directory containing this SKILL.md;
  derive it from the path at which Claude Code loaded this file
- Execute all scripts using absolute paths: `bash "${SKILL_DIR}/scripts/<name>"`
- Use only shipped scripts; do not run extra git or gh commands
- Do NOT read the script; use it as a black box.
- Write only when the user has explicitly requested the operation; do not ask
  for pre-write content approval
- Default language is English unless user explicitly requests otherwise
- On script validation error or API failure: show raw error, stop

## Routing

- Issue Create: [`references/issue-create-rules.md`](references/issue-create-rules.md)
- Issue Comment: [`references/issue-comment-rules.md`](references/issue-comment-rules.md)
- PR Create: [`references/pr-create-rules.md`](references/pr-create-rules.md)
- PR Review: [`references/pr-review-rules.md`](references/pr-review-rules.md)
  (new review via `create_review.sh`; append to an existing pending review via
  `append_review.sh`)

---
name: gh-ops
description: Use for GitHub operations such as creating issues, posting issue comments, creating PRs, and adding PR review comments.
user-invocable: true
disable-model-invocation: false
---

# GitHub Operations

## Overview

Perform GitHub operations: create issues, post issue comments, create draft PRs, and
add PR review drafts. Execute all scripts from the git repository root.

Derive `refs_dir` from the `Base directory` field in the skill-context header:
`refs_dir = {skill_base_dir}/references/`

## Operations

Route to the appropriate operation based on user intent. Read the corresponding
rules file for the full procedure, script usage, and output format.

### Issue Create

Read `{refs_dir}/issue-create-rules.md` for the full procedure.

Create a GitHub Issue with a structured body using one of two templates
(product-backlog or feature). Confirm content with the user before creating.

### Issue Comment

Read `{refs_dir}/issue-comment-rules.md` for the full procedure.

Post a structured comment to a GitHub Issue with a visible summary and optional
collapsible details sections. Confirm content with the user before posting.

### PR Create

Read `{refs_dir}/pr-create-rules.md` for the full procedure.

Create a draft pull request with a Conventional Commits-style title and standardized
body. Check branch status first; abort if no differing commits exist.

### PR Review

Read `{refs_dir}/pr-review-rules.md` for the full procedure.

Create a pending review draft on a GitHub PR with inline comments. Treat created
reviews as pending drafts; submit them manually via the GitHub UI.

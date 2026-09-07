---
name: superpowers-conventions
description: >-
  Use when running any superpowers skill (brainstorming, writing-plans,
  subagent-driven-development, executing-plans), when handling the design and plan
  files those skills produce, or when creating a PR for work that used them.
---

# Superpowers Conventions

## Overview

Personal rules layered on top of the superpowers workflow. superpowers owns the
order of work. This skill defines when the user approves its files, that they are
never committed, and how they are recorded on GitHub.

## File location

Follow save-conventions. It is the single source for where design and plan files go.

## Approval gates

- After writing the design file, stop and ask the user to review it. Do not start
  writing-plans until they approve.
- After writing the plan file, stop and ask the user to review it. Do not start
  implementation until they approve.
- Approval is given on the file, not on a chat summary. Present the path and wait.

## Do not commit

Files under `docs/superpowers/` and `.superpowers/` are never committed. They are
gitignored in repositories that follow save-conventions; where they are not, leave
them unstaged.

## Recording as comments

When the user has asked for design and plan files to be recorded on GitHub as part of this
workflow, post them as comments with gh-ops at these points. gh-ops and CLAUDE.md still require
the user's explicit instruction before any write; this section only defines the timing and
content once that instruction is in place.

- Design, task started from an issue: post to the issue after the plan is approved
  and before implementation starts.
- Design, task not started from an issue: post to the PR right after creating it.
- Plan: post to the PR right after creating it.

Before posting:

- Update the text to the final state of the file. The design and plan may have
  changed since it was written.
- Make it readable on its own: state the topic in the first line, and inline or
  remove any reference to files outside git (the spec and plan files themselves,
  scratch notes).

## Common Mistakes

- Starting implementation while approval of the plan is still pending because it
  "looks fine".
- Staging `docs/superpowers/` with `git add -A`.
- Posting the plan with a "see docs/superpowers/plans/..." link the reader cannot
  open.
- Posting the design before the plan is approved.

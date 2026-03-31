---
name: git-commit
description: >-
  Use when committing changes with Conventional Commit format.
  Handles staging and commit message derivation automatically.
user-invocable: true
disable-model-invocation: false
---

# Git Commit

## Overview

Thin orchestrator that delegates the entire commit workflow to a sub-agent.
The sub-agent stages changes if needed, analyzes the diff, derives a Conventional Commit
message, and executes the commit. The main agent receives only the final result.

## Output

- `sha: string`: The commit SHA.
- `message: string`: The full commit message.

## Execution

Launch a sub-agent to handle the complete workflow:

task(general-purpose, model=claude-sonnet-4.6):

> Invoke `skill(git-commit-execute)` and return its result.
> The skill handles staging, diff analysis, commit message derivation, and commit execution.
> Return the JSON output containing sha and message.
> If the skill fails, report the error.

Report the sub-agent result (sha and message) to the caller.
Do not read diffs, git status, or any intermediate output in the main agent.

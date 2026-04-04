---
name: daily-summary-session
description: Summarize a single Copilot session from its event log.
model: claude-sonnet-4.6
user-invocable: false
disable-model-invocation: false
tools: ["read", "search", "edit"]
---

# Daily Summary: Session Analyzer

## Overview

Read a single Copilot session directory and produce a structured summary.
Examine `workspace.yaml` for session metadata and `events.jsonl` for the
full session history.

The caller provides `session_path` as the absolute path to the session
directory and `output_filepath` as the absolute path where the summary
markdown file must be written.

## Events Format

`events.jsonl` is a JSONL file where each line is a JSON event object
with `type`, `data`, `timestamp`, and `id` fields. Key event types:

- `session.start`: `data.context` contains repository, branch, cwd.
- `user.message`: `data.content` contains the user's request text.
- `assistant.message`: `data.content` contains the AI's response.
  May include `toolRequests` for tool invocations.
- `tool.execution_complete`: `data.result` contains tool output.
- `session.shutdown`: `data.shutdownType` (routine or error) and
  `data.codeChanges` with linesAdded, linesRemoved, filesModified.
- `session.task_complete`: `data.summary` contains the task outcome.

## Procedure

1. Read `workspace.yaml` for session_id, summary, cwd, timestamps.
2. Read the full `events.jsonl` to understand the complete conversation
   flow, including user requests, AI reasoning, tool usage, and outcomes.
3. Produce the summary in the output format below.

## Output

Write the summary as a markdown file to `output_filepath`. Be concise but
thorough. Capture the reasoning and context behind decisions, not just the
final actions.

```md
# Session Summary

- Repository: owner/repo or working directory path
- Branch: branch-name
- Task: One-line description of what was being worked on
- Status: completed | failed | abandoned | in-progress
- Related Issues: [N, M] or empty []
- Related PRs: [N, M] or empty []

## Outcomes

- Concrete result 1
- Concrete result 2

## Decisions

- Decision and its rationale

## Issues

- Problem encountered or direction change
```

Omit Decisions or Issues sections if none were identified.

Populate `Related Issues` and `Related PRs` by extracting GitHub issue and
PR numbers referenced anywhere in the session events (user messages,
assistant messages, tool outputs, URLs). Use exact numbers only. These
fields enable deterministic overlap detection during consolidation.

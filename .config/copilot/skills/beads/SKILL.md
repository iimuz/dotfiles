---
name: beads
description: >-
  Use when work spans sessions, has blockers, or needs context recovery after
  compaction. Trigger on "create task", "track this work", "show tasks".
user-invocable: true
disable-model-invocation: false
---

# Beads - Persistent Task Memory

Graph-based issue tracker that survives conversation compaction. Provides
persistent memory for multi-session work with complex dependencies.

Run `bd prime` at session start if not auto-loaded by hooks. Run `bd <command> --help`
for specific command usage. Append `--json` to commands whose output will be parsed.

## Prerequisites

- `bd` CLI installed and in PATH (`bd --version` reports v0.60.0+).
- Git repository initialized.
- Beads database initialized (`bd init <prefix>` run once by user).

## bd vs TodoWrite

Use the 2-week test: "Would bd help me resume this work after 2 weeks?"

- Same session, linear steps, all context in conversation -> TodoWrite.
- Multiple sessions, dependencies, exploratory, needs resumability -> bd.

Transition from TodoWrite to bd when complexity emerges mid-session:
discovering blockers, realizing work will not complete this session, or
finding related issues.

## Session Protocol

1. `bd show <id> --long` - Read full task context assigned by user.
2. `bd update <id> --claim` - Claim and start work atomically.
3. Work on the task. Add notes as you progress for compaction survival.
4. If discoveries arise, create linked issues (see Issue Discovery below).
5. `bd close <id> --reason "..."` - Complete the task with a summary.

After closing, check whether dependent issues are now unblocked.

## Dependency Types

Four dependency types exist. Only `blocks` affects the `bd ready` queue.

### blocks (Hard Blocker)

`bd dep add A B --type blocks` means A depends on B. B must close before A
becomes ready.

- Use for prerequisites and sequential ordering.
- Direction trap: "Setup must complete before Implementation" means
  `bd dep add implementation setup`, not the reverse.

### related (Soft Link)

`bd dep add A B --type related` creates a bidirectional context link.

- Use for cross-references and "see also" connections.
- Does not affect ready queue.

### parent-child (Hierarchical)

`bd dep add child parent --type parent-child` establishes epic/subtask
hierarchy.

- Parent tracks overall progress; children are individual work items.
- Closing all children may make the parent close-eligible.

### discovered-from (Provenance)

`bd dep add new-issue current-issue --type discovered-from` tracks that
new-issue was found while working on current-issue.

- Use when finding bugs, TODOs, or related work during task execution.
- Documents work expansion and "how we got here" context.

### Decision Guide

- Must complete X before Y? -> `blocks`.
- Found this while working on that? -> `discovered-from`.
- These are related but independent? -> `related`.
- This is a subtask of an epic? -> `parent-child`.

When unsure, prefer `related`. It adds context without constraining execution.

## Writing Notes for Compaction Survival

Write notes as if explaining to a future AI session with zero prior context.
Notes are the primary mechanism for surviving conversation compaction.

### What to Include

- Current status and what was accomplished.
- Key decisions made and their rationale.
- Working code snippets, API responses, or error messages that were hard to
  discover.
- Next steps and known blockers.
- File paths and line numbers relevant to the work.

### Format

```bash
bd comments add <id> 'COMPLETED: [what was done]
KEY DECISION: [decision and why]
IN PROGRESS: [current work]
NEXT: [immediate next steps]
BLOCKERS: [if any]'
```

### Anti-patterns

- Vague notes like "worked on auth" (no resumable context).
- Omitting code snippets that took time to discover.
- Skipping rationale for decisions.

## Issue Discovery

During task execution, create issues for bugs, TODOs, or related work found
along the way.

### When to Create Directly (No User Confirmation)

- Bug reports with clear scope.
- Technical TODOs discovered during implementation.
- Side quest capture that needs tracking.

### When to Ask User First

- Strategic work with fuzzy boundaries.
- Potential duplicates of existing issues.
- Large epics with unclear scope.
- Major changes in direction.

Rule of thumb: if you can write a clear, specific title in one sentence,
create directly. If you need user input to clarify the work, ask first.

### Linking Discovered Issues

Always link discovered issues to the current task:

```bash
bd create 'Found: [description]' -t bug -p 2 --json  # priority: scale 0-4; 2 = medium
bd dep add <new-id> <current-id> --type discovered-from
```

## Git Worktree Support

Always use `bd worktree` instead of raw `git worktree` commands in projects
with beads.

`bd worktree create` wraps `git worktree add` and auto-configures:

- Beads database redirect files (worktree points to main `.beads/` DB).
- Proper gitignore entries.
- Embedded mode for worktree operations.

Using `git worktree add` directly causes `bd` commands to fail with
"database not found" in the worktree.

### Commands

```bash
bd worktree create .worktrees/<name> --branch feature/<name>
bd worktree list
bd worktree remove .worktrees/<name>
```

### Architecture

All worktrees share one `.beads/` database via redirect files:

```text
main-repo/
  .beads/              <- Single source of truth
  .worktrees/
    feature-a/
      .beads           <- Redirect file (not directory)
    feature-b/
      .beads           <- Redirect file
```

### Debugging

```bash
bd where              # Shows actual .beads location (follows redirects)
bd doctor --deep      # Validates graph integrity across all refs
```

## Error Handling

- `database not found` -> Run `bd init <prefix>` in project root. In a
  worktree, verify `bd where` points to the main `.beads/` directory.
- `not in a git repository` -> Run `git init` first.
- `disk I/O error (522)` -> Move `.beads/` off cloud-synced filesystem.
- Unexpected behavior -> Run `bd doctor` for diagnostics.

## CLI Reference

Do not memorize CLI syntax. Use these dynamic sources:

- `bd prime` - AI-optimized workflow context (run at session start if hooks are unavailable).
- `bd <command> --help` - Specific command usage and flags.
- `bd --help` - Full command list.

Status icons: `○` open, `◐` in_progress, `●` blocked, `✓` closed, `deferred`.

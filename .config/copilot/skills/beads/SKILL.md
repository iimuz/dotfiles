---
name: beads
description: This skill should be used when work spans multiple sessions, has dependencies or blockers, or needs context recovery after conversation compaction. Provides git-backed issue tracking with persistent memory for multi-session work.
---

# Beads - Persistent Task Memory for AI Agents

Graph-based issue tracker that survives conversation compaction. Provides persistent memory for multi-session work with complex dependencies.

## Purpose

Beads enables AI agents to maintain task context across conversation boundaries. When conversations are compacted or sessions end, traditional task tracking is lost. Beads solves this by providing a git-backed issue tracker designed for AI workflows, preserving task state, dependencies, and critical context.

Beads uses the `bd` CLI for all operations.

## When to Use This Skill

Use this skill when:

- Work spans multiple conversation sessions
- Tasks have dependencies or blockers that need tracking
- Context recovery is needed after conversation compaction
- Multi-step work requires persistent state across sessions
- Task history and decision rationale need preservation

## Prerequisites

Verify bd CLI is available:

```bash
bd --version
```

Requirements:

- bd CLI installed and in PATH
- Git repository (bd requires git for sync)

## Workflow Protocol

### Discover Available Work

To get comprehensive AI-optimized workflow context (unblocked tasks, current state, dependencies), run `bd prime`. This provides a complete snapshot for session initialization.

To find specific unblocked work items only, run `bd ready`.

**When to use which:**

- Use `bd prime` at session start for full context
- Use `bd ready` during active work to check for new unblocked tasks

### Standard Session Flow

0. **Sync state**: `bd sync` — Pull latest state from git before starting
1. **Find work**: `bd ready` — Identify unblocked tasks
2. **Load context**: `bd show <id>` — Retrieve full issue details
3. **Start work**: `bd update <id> --status in_progress` — Mark task as active
4. **Document progress**: Add notes throughout work (critical for compaction survival)
5. **Complete**: `bd close <id> --reason "..."` — Mark task complete with summary
6. **Sync state**: `bd sync` — Push state to git at session end

### Create Issues

Create issues with complete context:

```bash
bd create "Title" --description "Details..." --type task --priority 2
```

Issue types: task, bug, feature, investigation
Priority levels: 1 (highest) to 5 (lowest)

### Update Issues

Add or modify issue descriptions:

```bash
bd update <id> --description "Details..."
```

Update status or other fields:

```bash
bd update <id> --status blocked --priority 1
```

## Writing Effective Issue Descriptions

Write self-contained descriptions that remain comprehensible without external files. Structure descriptions to provide complete context:

- **Background**: Why this work is needed
- **Current State**: What exists today (include concrete examples/data)
- **Problem**: What's wrong and why it matters
- **Proposal**: Specific solution with code examples if applicable
- **Impact**: Files/areas affected by the change
- **References**: Related context (not required to understand the issue)

**Critical Rules**:

- Never use file links (`path/to/file.md`) in descriptions
- Include all essential information inline
- Make issues understandable without external files
- Add notes during work to preserve decision rationale

## Additional Commands

Get help for any command:

```bash
bd <command> --help
```

Common commands:

- `bd list` — View all issues
- `bd graph` — Visualize dependencies
- `bd depends <id> --on <other-id>` — Create dependency
- `bd note <id> "..."` — Add timestamped note

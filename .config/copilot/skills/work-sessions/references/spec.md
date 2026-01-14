# Work Sessions spec

This skill implements the repository-local work-session file format and operations described in `session_memory.md`.

## Storage

- Root directory: `.agent/work-sessions/`
- Archive directory (excluded from list/search): `.agent/work-sessions/archive/`

## Filename format

- `{YYYYMMDD}_{task_slug}.md`
- `task_slug` is snake_case ASCII (lowercase letters, digits, underscore)

## Frontmatter

Required keys (fixed):

- `title` (string)
- `description` (string)
- `created` (RFC3339-like timestamp)

## Body (recommended)

- `# {title}`
- `## Summary`
- `## Context`
- `## Next Steps`
- `## Notes`

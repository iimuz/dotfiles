---
name: commit-staged
description: Commit staged changes using Conventional Commit parameters (validates inputs).
---

# Commit Staged Changes Skill

## Purpose

Standardized git commits following Conventional Commits 1.0.0 with type validation and emojis.

## Contract

- Use only the scripts shipped with this skill (do not run extra git commands)
- Commits **only** what is already staged (never stages/unstages files)
- Description must be natural-language summary (not file paths)
- Subject/body in English; subject is imperative, no trailing period

## Workflow

1. Review staged changes:

   ```bash
   bash scripts/staged-files.sh
   ```

2. Analyze the diff and determine appropriate `--type`, `--description`, and optional `--body`

3. Execute the commit:

   ```bash
   bash scripts/commit.sh --type <type> --description "<summary>" [--body "<bullets>"]
   ```

## Scripts

**staged-files.sh** - Show staged files and diff:
```bash
bash scripts/staged-files.sh
```

**commit.sh** - Execute commit with validation:
```bash
bash scripts/commit.sh --type <type> --description <description> [--body <body>]
```

Parameters:
- `--type`: Required. Valid types in `references/types.md`
- `--description`: Required. Natural language summary (max 100 chars with type/emoji)
- `--body`: Optional. Bullet points starting with "-"

## Message Guidelines

- Summarize _what_ changed (and ideally _why_) in natural language
- Do **not** use file-path lists (e.g. ".github/.../file.go, ...")
- English, imperative mood, no trailing period
- Valid types: see `references/types.md`

## Examples

Simple commit:
```bash
bash scripts/commit.sh --type feat --description "add user authentication"
```

With body:
```bash
bash scripts/commit.sh \
  --type fix \
  --description "resolve token expiration" \
  --body "- update token refresh logic
- add error handling for expired tokens"
```

Output format: `<type>: <emoji> <description>`

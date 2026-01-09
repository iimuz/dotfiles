---
name: commit-staged
description: Commit staged changes only using Conventional Commit parameters (validates inputs).
---

# Commit Staged Changes Skill

## Purpose

This skill provides standardized git commit message formatting and execution according to Conventional Commits 1.0.0 specification. It ensures consistent commit message structure with proper type validation and emojis.

## Clarification: this skill does not generate messages

This skill **does not** decide the commit message content from diffs by itself; it only **validates** and **executes** a commit using the provided `--type`/`--description`/`--body`.
If you want automatic message generation with a specific LLM model, use a dedicated agent to derive those parameters from `git diff --staged`, and then call `commit.sh` to perform the commit.

## Contract

- Use only the scripts shipped with this skill (do not run extra git commands)
  - Review staged changes via `bash scripts/staged-files.sh`
  - Create the commit via `bash scripts/commit.sh ...`
- Commits **only** what is already staged (never stages/unstages files)
- Requires `--description` to be a natural-language summary (not file paths)
- Subject/body must be English; subject is imperative, no trailing period

## Workflow

1. Review staged changes (file list + diff; stop if empty):

   ```bash
   bash scripts/staged-files.sh
   ```

2. Choose `--type`, `--description`, and optional `--body` based on the staged diff.
   - Subject/body must be English; subject is imperative, no trailing period
   - If using `--body`, write bullet points starting with "-"

3. Execute the commit using `scripts/commit.sh` (it runs `git commit` internally):

   ```bash
   bash scripts/commit.sh --type <type> --description "<summary>" [--body "<bullets>"]
   ```

## Available Tools

### staged-files.sh

A bash script that prints staged file paths and the staged diff (fails if nothing is staged).

**Location**: `scripts/staged-files.sh`

**Usage**:

```bash
bash scripts/staged-files.sh
```

### commit.sh

A bash script that formats and executes git commits with standardized format.

**Location**: `scripts/commit.sh`

**Usage**:

```bash
bash scripts/commit.sh --type <type> --description <description> [--body <body>]
```

**Parameters**:

- `--type`: (Required) Commit type. Must be one of: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test, i18n
- `--description`: (Required) Short description of the change (max 100 chars including type and emoji)
- `--body`: (Optional) Detailed description with bullet points

**Output Format**:

```
<type>: <emoji> <description>

[optional body]
```

**Validation**:

- Only `--type`, `--description`, and `--body` parameters are allowed
- Type must be from the allowed list
- Fails if there are no staged files
- Returns exit code 1 on validation errors

## Writing a good message (important)

Write **natural language** based on `git diff --staged`:

- Summarize _what_ changed (and ideally _why_) in a few words
- Do **not** use a file-path list as the description (e.g. ".github/.../file.go, ...")
- Must be in English, imperative mood, no trailing period

## Type Reference

| Type     | Description                                 |
| -------- | ------------------------------------------- |
| build    | Build system or external dependency changes |
| chore    | Maintenance tasks, scripts, config          |
| ci       | CI configuration and scripts                |
| docs     | Documentation changes                       |
| feat     | New features                                |
| fix      | Bug fixes                                   |
| perf     | Performance improvements                    |
| refactor | Code refactoring                            |
| revert   | Revert previous commits                     |
| style    | Code style changes (formatting, whitespace) |
| test     | Test additions or corrections               |
| i18n     | Internationalization                        |

## Examples

### Simple commit with description only

```bash
bash scripts/commit.sh --type feat --description "add user authentication"
```

### Commit with body

```bash
bash scripts/commit.sh \
  --type fix \
  --description "resolve authentication token expiration" \
  --body "- update token refresh logic
- add proper error handling for expired tokens
- improve token validation"
```

## Rules and Guidelines

1. **Subject Line**:
   - Format: `<type>: <emoji> <description>`
   - Use imperative mood
   - No capitalization
   - No period at the end
   - Max 100 characters per line
   - Must be in English

2. **Body** (if provided):
   - Use bullet points with "-"
   - Max 100 characters per line
   - Use line breaks for long bullet points
   - Explain what and why
   - Must be in English

3. **Validation**:
   - Unknown parameters will cause an error
   - Invalid type will cause an error
   - Missing required parameters will cause an error

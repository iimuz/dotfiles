---
name: pr-draft
description: Create GitHub pull request drafts using Conventional Commit parameters (validates inputs).
---

# PR Draft Skill

## Purpose

This skill provides standardized GitHub pull request creation with Conventional Commits style formatting. It ensures consistent PR structure with proper type validation and emojis.

## Prerequisites

**IMPORTANT**: All scripts must be executed from the **git repository root directory** where you want to create the PR.

Example:
```bash
# Correct: Execute from repo root
cd /path/to/your/repo
bash /path/to/skill/scripts/check-branch-status.sh

# Incorrect: Execute from skill directory
cd /path/to/skill
bash scripts/check-branch-status.sh  # This may operate on the wrong repo!
```

Requirements:
- Working directory must be a git repository
- Current branch should have commits that differ from its base branch
- Repository must have a remote named 'origin'

## Contract

- Use only the scripts shipped with this skill (do not run extra git/gh commands)
  - Review branch status via `bash scripts/check-branch-status.sh` (from repo root)
  - Create the PR via `bash scripts/create-pr.sh ...` (from repo root)
- Creates draft PRs only
- Requires `--title` to be a natural-language summary (not file paths)
- Title/body default to English (use specified language if explicitly requested); title is imperative, no trailing period

## Workflow

1. **Change to repository root directory first**:

   ```bash
   cd /path/to/your/repo
   ```

2. Review branch status (uncommitted changes, commit history, diff; stop if issues):

   ```bash
   bash /path/to/skill/scripts/check-branch-status.sh [--base <branch>]
   ```

   The script displays repository information and compares with the specified base branch (or remote HEAD branch if not specified)

3. Choose `--type`, `--title`, `--changes`, and optional sections based on the changes.
   - Title/body default to English (use specified language if explicitly requested); title is imperative, no trailing period
   - `--changes` should use bullet points starting with "-"

4. Execute the PR creation using `scripts/create-pr.sh`:

   ```bash
   bash /path/to/skill/scripts/create-pr.sh \
     --type <type> \
     --title "<summary>" \
     --changes "<bullets>" \
     [--related-urls "<urls>"] \
     [--confirmation "<results>"] \
     [--review-points "<points>"] \
     [--limitations "<limitations>"] \
     [--additional "<notes>"] \
     [--base "<branch>"]
   ```

## Available Tools

### check-branch-status.sh

A bash script that displays branch status information for PR creation.

**Location**: `scripts/check-branch-status.sh`

**Usage**:

```bash
bash scripts/check-branch-status.sh [--base <branch>]
```

**Parameters**:

- `--base`: (Optional) Base branch name to compare against. If not specified, uses the remote HEAD branch

**Output**:
- Repository information (current branch, base branch for comparison)
- Uncommitted changes (git status)
- Commit history comparing with base branch
- Diff statistics from merge base with base branch
- Note: When --base is not specified, displays a note that `gh pr create` will automatically determine the actual base branch

### create-pr.sh

A bash script that formats and executes GitHub PR creation with standardized format.

**Location**: `scripts/create-pr.sh`

**Usage**:

```bash
bash scripts/create-pr.sh \
  --type <type> \
  --title <title> \
  --changes <changes> \
  [--related-urls <urls>] \
  [--confirmation <results>] \
  [--review-points <points>] \
  [--limitations <limitations>] \
  [--additional <notes>] \
  [--base <branch>]
```

**Parameters**:

- `--type`: (Required) PR type. Must be one of: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test, i18n
- `--title`: (Required) Short description of the change (max 100 chars including type and emoji)
- `--changes`: (Required) Description of changes with bullet points
- `--related-urls`: (Optional) Related URLs or issue links
- `--confirmation`: (Optional) Confirmation test results
- `--review-points`: (Optional) Points to review
- `--limitations`: (Optional) Known limitations
- `--additional`: (Optional) Additional notes
- `--base`: (Optional) Base branch name for the pull request. If not specified, GitHub will use the default branch

**Output Format**:

PR Title:
```
<type>: <emoji> <title>
```

PR Body:
```markdown
## Related URLs
<related-urls or empty>

## Changes
<changes>

## Confirmation Results
<confirmation or empty comment>

## Review Points
<review-points or empty comment>

## Limitations
<limitations or empty comment>

<additional if provided>
```

**Validation**:

- Only allowed parameters are accepted
- Type must be from the allowed list
- Returns exit code 1 on validation errors

## Writing a good PR (important)

Write **natural language** based on branch changes:

- Summarize _what_ changed (and ideally _why_) in a few words
- Do **not** use a file-path list as the title (e.g. ".github/.../file.go, ...")
- Default to English (use specified language if explicitly requested), imperative mood, no trailing period

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

### Simple PR with minimal sections

```bash
bash scripts/create-pr.sh \
  --type feat \
  --title "add user authentication" \
  --changes "- implement JWT-based authentication
- add login/logout endpoints
- add user session management"
```

### Full PR with all sections

```bash
bash scripts/create-pr.sh \
  --type fix \
  --title "resolve authentication token expiration" \
  --related-urls "Fixes #123" \
  --changes "- update token refresh logic
- add proper error handling for expired tokens
- improve token validation" \
  --confirmation "- tested token refresh flow
- verified error handling with expired tokens" \
  --review-points "- token refresh timing
- error message clarity
- backward compatibility" \
  --limitations "- requires frontend update for new error codes"
```

### PR with custom base branch

```bash
# Create PR from feature branch to develop branch
bash scripts/create-pr.sh \
  --type feat \
  --title "add user profile editing" \
  --changes "- implement profile edit form
- add validation for user inputs
- update API endpoints" \
  --base develop
```

## Rules and Guidelines

1. **Title**:
   - Format: `<type>: <emoji> <title>`
   - Use imperative mood
   - No capitalization
   - No period at the end
   - Max 100 characters per line
   - Default to English (use specified language if explicitly requested)

2. **Body Sections**:
   - Use bullet points with "-" for lists
   - Max 100 characters per line
   - Use line breaks for long bullet points
   - Explain what and why
   - Default to English (use specified language if explicitly requested)

3. **Validation**:
   - Unknown parameters will cause an error
   - Invalid type will cause an error
   - Missing required parameters will cause an error

4. **PR Type**:
   - Always created as draft
   - Can be marked ready for review later via GitHub UI

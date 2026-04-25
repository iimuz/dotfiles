# PR Create Rules

Create a draft pull request with a Conventional Commits-style title and
standardized body.

## Procedure

Follow these steps in order. Stop on any failure.

### Step 1: Check Branch Status

Run `bash scripts/check-branch-status.sh [--base <branch>]`.
Inspects uncommitted changes, commit history, and diff statistics.
Abort if no commits differ from the base branch.

### Step 2: Determine PR Type

Select one based on the changes:

- `build` – Build system or external dependency changes
- `chore` – Maintenance tasks, scripts, config
- `ci` – CI configuration and scripts
- `docs` – Documentation changes
- `feat` – New features
- `fix` – Bug fixes
- `i18n` – Internationalization
- `perf` – Performance improvements
- `refactor` – Code refactoring
- `revert` – Revert previous commits
- `style` – Code style changes (formatting, whitespace)
- `test` – Test additions or corrections

### Step 3: Compose Title

Format: imperative mood, concise, no trailing period, no file paths.

- Good: `"clarify PR draft skill"`, `"resolve token expiration"`
- Bad: `"clarified the PR draft skill."`, `"update src/auth/token.ts"`

### Step 4: Compose Body Content

Required flags:

- `--type` – PR type from Step 2
- `--title` – Title from Step 3
- `--changes` – Bullet lines starting with `-`

Optional flags:

- `--related-urls` – Related issue/PR URLs
- `--confirmation` – Verification steps performed
- `--review-points` – Areas needing reviewer attention
- `--limitations` – Known limitations or follow-up needed
- `--additional` – Any extra context
- `--base` – Base branch (default: repo default branch)

### Step 5: Confirm with User

Present the composed title, type, and body content. Proceed only after explicit
approval.

### Step 6: Create Draft PR

```bash
bash scripts/create-pr.sh \
  --type <type> \
  --title "<title>" \
  --changes "<bullet lines>" \
  [--related-urls "<urls>"] \
  [--confirmation "<results>"] \
  [--review-points "<points>"] \
  [--limitations "<limitations>"] \
  [--additional "<context>"] \
  [--base <branch>]
```

The script validates type and required parameters. Abort on validation errors.

## PR Body Format

```markdown
## Related URLs

{related_urls}

## Changes

{changes}

## Confirmation Results

{confirmation_results}

## Review Points

{review_points}

## Limitations

{limitations}

{additional}
```

## Examples

Minimal:

```bash
bash scripts/check-branch-status.sh --base main
bash scripts/create-pr.sh --type docs --title "clarify PR draft skill" \
  --changes "- rewrite the skill overview
- extract the type reference
- extract the PR body template" \
  --base main
```

Full:

```bash
bash scripts/check-branch-status.sh
bash scripts/create-pr.sh --type fix --title "resolve token expiration" \
  --changes "- update token refresh logic
- add proper error handling for expired tokens" \
  --confirmation "- tested token refresh flow" \
  --review-points "- token refresh timing" \
  --limitations "- requires frontend update for new error codes"
```

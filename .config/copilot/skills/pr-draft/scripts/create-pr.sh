#!/usr/bin/env bash

set -euo pipefail

# Verify we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not in a git repository" >&2
  echo "Please run this script from within a git repository" >&2
  exit 1
fi

# Type to emoji mapping (portable)
ALLOWED_TYPES=(build chore ci docs feat fix perf refactor revert style test i18n)

get_emoji() {
  case "$1" in
  build) echo ":building_construction:" ;;
  chore) echo ":wrench:" ;;
  ci) echo ":construction_worker:" ;;
  docs) echo ":memo:" ;;
  feat) echo ":sparkles:" ;;
  fix) echo ":bug:" ;;
  perf) echo ":zap:" ;;
  refactor) echo ":recycle:" ;;
  revert) echo ":rewind:" ;;
  style) echo ":lipstick:" ;;
  test) echo ":white_check_mark:" ;;
  i18n) echo ":globe_with_meridians:" ;;
  *) echo "" ;;
  esac
}

# Initialize variables
TYPE=""
TITLE=""
RELATED_URLS=""
CHANGES=""
CONFIRMATION=""
REVIEW_POINTS=""
LIMITATIONS=""
ADDITIONAL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --type)
    TYPE="$2"
    shift 2
    ;;
  --title)
    TITLE="$2"
    shift 2
    ;;
  --related-urls)
    RELATED_URLS="$2"
    shift 2
    ;;
  --changes)
    CHANGES="$2"
    shift 2
    ;;
  --confirmation)
    CONFIRMATION="$2"
    shift 2
    ;;
  --review-points)
    REVIEW_POINTS="$2"
    shift 2
    ;;
  --limitations)
    LIMITATIONS="$2"
    shift 2
    ;;
  --additional)
    ADDITIONAL="$2"
    shift 2
    ;;
  *)
    echo "Error: Unknown parameter '$1'" >&2
    echo "Allowed parameters: --type, --title, --related-urls, --changes, --confirmation, --review-points, --limitations, --additional" >&2
    exit 1
    ;;
  esac
done

# Validate required parameters
if [[ -z "$TYPE" ]]; then
  echo "Error: --type is required" >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  echo "Error: --title is required" >&2
  exit 1
fi

if [[ -z "$CHANGES" ]]; then
  echo "Error: --changes is required" >&2
  exit 1
fi

# Get emoji for type and validate
EMOJI=$(get_emoji "$TYPE")
if [[ -z "$EMOJI" ]]; then
  echo "Error: Invalid type '$TYPE'" >&2
  echo "Allowed types: ${ALLOWED_TYPES[*]}" >&2
  exit 1
fi

# Build PR title: <type>: <emoji> <title>
PR_TITLE="${TYPE}: ${EMOJI} ${TITLE}"

# Build PR body
PR_BODY="## Related URLs"
if [[ -n "$RELATED_URLS" ]]; then
  PR_BODY="${PR_BODY}
${RELATED_URLS}"
fi

PR_BODY="${PR_BODY}

## Changes
${CHANGES}

## Confirmation Results"
if [[ -n "$CONFIRMATION" ]]; then
  PR_BODY="${PR_BODY}
${CONFIRMATION}"
else
  PR_BODY="${PR_BODY}

<!-- Describe preconditions, steps, and results of confirmation if any -->"
fi

PR_BODY="${PR_BODY}

## Review Points"
if [[ -n "$REVIEW_POINTS" ]]; then
  PR_BODY="${PR_BODY}
${REVIEW_POINTS}"
fi

PR_BODY="${PR_BODY}

## Limitations"
if [[ -n "$LIMITATIONS" ]]; then
  PR_BODY="${PR_BODY}
${LIMITATIONS}"
else
  PR_BODY="${PR_BODY}

<!-- Describe known limitations of this change or items to be addressed in a separate PR if any -->"
fi

if [[ -n "$ADDITIONAL" ]]; then
  PR_BODY="${PR_BODY}

${ADDITIONAL}"
fi

# Execute gh pr create
gh pr create --draft --title "$PR_TITLE" --body "$PR_BODY"

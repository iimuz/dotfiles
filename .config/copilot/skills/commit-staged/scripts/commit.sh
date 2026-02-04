#!/usr/bin/env bash

set -euo pipefail

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
DESCRIPTION=""
BODY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --type)
    TYPE="$2"
    shift 2
    ;;
  --description)
    DESCRIPTION="$2"
    shift 2
    ;;
  --body)
    BODY="$2"
    shift 2
    ;;
  *)
    echo "Error: Unknown parameter '$1'" >&2
    echo "Allowed parameters: --type, --description, --body" >&2
    exit 1
    ;;
  esac
done

# Validate required parameters
if [[ -z "$TYPE" ]]; then
  echo "Error: --type is required" >&2
  exit 1
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "Error: --description is required" >&2
  exit 1
fi

# Normalize description
DESCRIPTION=$(printf %s "$DESCRIPTION" | sed -E 's/[[:space:]]+$//; s/,+$//')
if [[ -z "$DESCRIPTION" ]]; then
  echo "Error: --description is required" >&2
  exit 1
fi

# Guard against accidental file-path-only descriptions
if [[ "$DESCRIPTION" == .* && "$DESCRIPTION" == */* ]]; then
  echo "Error: --description must be a natural-language summary, not a file path" >&2
  exit 1
fi

# Ensure there are staged files
if ! git diff --staged --name-only | grep -q .; then
  echo "Error: no staged files to commit" >&2
  exit 1
fi

# Get emoji for type and validate
EMOJI=$(get_emoji "$TYPE")
if [[ -z "$EMOJI" ]]; then
  echo "Error: Invalid type '$TYPE'" >&2
  echo "Allowed types: ${ALLOWED_TYPES[*]}" >&2
  exit 1
fi

# Build commit message
COMMIT_MSG="${TYPE}: ${EMOJI} ${DESCRIPTION}"

if [[ -n "$BODY" ]]; then
  COMMIT_MSG="${COMMIT_MSG}

${BODY}"
fi

# Execute git commit
git commit -m "$COMMIT_MSG"

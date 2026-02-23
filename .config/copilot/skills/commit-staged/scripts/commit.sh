#!/usr/bin/env bash

set -euo pipefail

# Allowed commit types
ALLOWED_TYPES=(build chore ci docs feat fix perf refactor revert style test i18n)

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

# Validate type
pattern=" ${TYPE} "
if [[ ! " ${ALLOWED_TYPES[*]} " =~ $pattern ]]; then
  echo "Error: Invalid type '$TYPE'" >&2
  echo "Allowed types: ${ALLOWED_TYPES[*]}" >&2
  exit 1
fi

# Build commit message
COMMIT_MSG="${TYPE}: ${DESCRIPTION}"

if [[ -n "$BODY" ]]; then
  COMMIT_MSG="${COMMIT_MSG}

${BODY}"
fi

# Execute git commit
git commit -m "$COMMIT_MSG"

#!/usr/bin/env bash

set -euo pipefail

STAGED_FILES="$(git diff --staged --name-only)"
if [[ -z "$STAGED_FILES" ]]; then
  echo "Error: no staged files" >&2
  exit 1
fi

echo "=== Staged files ==="
printf '%s\n' "$STAGED_FILES"

echo

echo "=== Staged diff ==="
git --no-pager diff --staged

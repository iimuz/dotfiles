#!/usr/bin/env bash

set -euo pipefail

# Parse arguments
BASE_BRANCH_ARG=""
while [[ $# -gt 0 ]]; do
  case $1 in
  --base)
    BASE_BRANCH_ARG="$2"
    shift 2
    ;;
  *)
    echo "Error: Unknown parameter '$1'" >&2
    echo "Usage: $0 [--base <branch>]" >&2
    exit 1
    ;;
  esac
done

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Determine base branch
if [[ -n "$BASE_BRANCH_ARG" ]]; then
  BASE_BRANCH="$BASE_BRANCH_ARG"
else
  # Get remote HEAD branch (what origin points to as default)
  REMOTE_HEAD_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
  if [[ -z "$REMOTE_HEAD_BRANCH" ]]; then
    REMOTE_HEAD_BRANCH="main"
  fi
  BASE_BRANCH="$REMOTE_HEAD_BRANCH"
fi

echo "=== Repository Information ==="
echo "Current branch: $CURRENT_BRANCH"
if [[ -z "$BASE_BRANCH_ARG" ]]; then
  echo "Remote HEAD branch: $BASE_BRANCH"
fi
echo "Base branch for comparison: $BASE_BRANCH"
if [[ -z "$BASE_BRANCH_ARG" ]]; then
  echo ""
  echo "Note: 'gh pr create' will automatically determine the base branch"
  echo "      based on the branch configuration and remote tracking."
fi

echo
echo "=== Uncommitted changes ==="
git status --short

echo
echo "=== Commit history (comparing with base: $BASE_BRANCH) ==="
git log "$BASE_BRANCH..HEAD" --oneline || echo "No commits ahead of $BASE_BRANCH"

echo
echo "=== Diff statistics (from merge base with base branch) ==="
git diff "$BASE_BRANCH...HEAD" --stat || echo "No differences from $BASE_BRANCH"

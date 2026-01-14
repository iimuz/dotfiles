#!/usr/bin/env bash

set -euo pipefail

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get remote HEAD branch (what origin points to as default)
REMOTE_HEAD_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
if [[ -z "$REMOTE_HEAD_BRANCH" ]]; then
  REMOTE_HEAD_BRANCH="main"
fi

echo "=== Repository Information ==="
echo "Current branch: $CURRENT_BRANCH"
echo "Remote HEAD branch: $REMOTE_HEAD_BRANCH"
echo ""
echo "Note: 'gh pr create' will automatically determine the base branch"
echo "      based on the branch configuration and remote tracking."

echo
echo "=== Uncommitted changes ==="
git status --short

echo
echo "=== Commit history (comparing with remote HEAD: $REMOTE_HEAD_BRANCH) ==="
git log "$REMOTE_HEAD_BRANCH..HEAD" --oneline || echo "No commits ahead of $REMOTE_HEAD_BRANCH"

echo
echo "=== Diff statistics (from merge base with remote HEAD) ==="
git diff "$REMOTE_HEAD_BRANCH...HEAD" --stat || echo "No differences from $REMOTE_HEAD_BRANCH"

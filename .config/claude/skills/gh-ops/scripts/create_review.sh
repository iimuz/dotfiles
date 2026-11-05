#!/usr/bin/env bash
set -euo pipefail

# Resolve the directory of this script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! type python3 >/dev/null 2>&1; then
  printf '%s\n' "Error: python3 is required but was not found in PATH." >&2
  exit 1
fi

if ! type gh >/dev/null 2>&1; then
  printf '%s\n' "Error: gh is required but was not found in PATH." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  if [ "${GH_CONFIG_DIR:-}" = "$HOME/.config/gh-agent" ]; then
    printf '%s\n' "Error: GitHub CLI authentication failed in a session switched to the GitHub App bot. The bot token may have expired; 'gh auth login' does not renew it." >&2
  else
    printf '%s\n' "Error: GitHub CLI is not authenticated. Run 'gh auth login' and try again." >&2
  fi
  exit 1
fi

# Call the Python script with all arguments
python3 "$SCRIPT_DIR/create_review.py" "$@"

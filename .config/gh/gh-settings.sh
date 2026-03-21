#!/usr/bin/env bash
#
# gh command Settings Script

# Guard if command does not exist.
if ! type gh >/dev/null 2>&1; then return 0; fi

function set_gh_token_from_pass() {
  if ! type pass >/dev/null 2>&1; then
    echo "pass command not found. Please install pass to use this function." >&2
    return 1
  fi
  if ! pass show gh/github.com >/dev/null 2>&1; then
    echo "No GitHub token found in pass. Please store your GitHub token at 'gh/github.com'." >&2
    return 1
  fi

  local gh_token=""
  gh_token=$(pass show gh/github.com 2>/dev/null)
  readonly gh_token
  export GH_TOKEN="$gh_token"
}

#!/usr/bin/env bash
# Shared helper functions sourced by setup scripts.

# Create symlink if link does not exist.
function create_symlink() {
  local -r src=$1
  local -r dst=$2

  if [ -e "$dst" ]; then
    echo "already exist $dst"
    return 0
  fi

  echo "symlink $src to $dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
}

# Create hardlink if link does not exist.
function create_hardlink() {
  local -r src=$1
  local -r dst=$2

  if [ -e "$dst" ]; then
    echo "already exist $dst"
    return 0
  fi

  echo "symlink $src to $dst"
  mkdir -p "$(dirname "$dst")"
  ln "$src" "$dst"
}

# Add loading file in .bashrc or .zshrc.
function set_bashrc() {
  local -r filename="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local -r rcfile="$HOME/.zshrc"
  else
    # bashを想定している
    local -r rcfile="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep -qF -- "$filename" "$rcfile" >/dev/null 2>&1; then
    echo "already setting in $rcfile: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in $rcfile: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >>"$rcfile"
}

# Register an MCP server at Claude Code user scope unless it already exists.
# Usage: add_claude_mcp <name> <json>
# User scope definitions live in ~/.claude.json, shared with other state, so they cannot be
# distributed by symlink. Registration is detected by the exit code of `claude mcp get`
# because the not-registered message varies by environment.
function add_claude_mcp() {
  local -r name="$1"
  local -r json="$2"

  if claude mcp get "$name" >/dev/null 2>&1; then
    echo "already exist claude mcp: $name"
    return 0
  fi

  echo "add claude mcp: $name"
  claude mcp add-json --scope user "$name" "$json"
}

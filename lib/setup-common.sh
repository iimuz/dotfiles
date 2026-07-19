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

# Add Claude Code user-scope MCP server if not already configured.
#
# Claude Code のユーザーレベル MCP 設定は他の情報がありリポジトリで管理できないので設定で対応する
# Usage: add_claude_mcp <name> <cmd> [args...]
function add_claude_mcp() {
  local -r name=$1
  shift

  local output
  output=$(claude mcp get "$name" 2>&1 || true)
  if ! echo "$output" | grep -qF "No MCP server found"; then
    echo "already exist claude mcp: $name"
    return 0
  fi

  echo "add claude mcp: $name"
  claude mcp add --transport stdio --scope user "$name" -- "$@"
}

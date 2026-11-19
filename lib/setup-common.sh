#!/usr/bin/env bash
# Shared helper functions sourced by setup scripts.

# Create symlink if link does not exist.
# A broken symlink (target missing) is replaced; anything that exists is left alone.
function create_symlink() {
  local -r src=$1
  local -r dst=$2

  if [ -L "$dst" ] && [ ! -e "$dst" ]; then
    echo "replace broken symlink $dst"
    rm "$dst"
  fi

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

# 1 つの張り先ディレクトリを、一覧の skill だけを skill 単位の symlink で張った状態にする。
# Usage: sync_skill_links <checkout_dir> <src_dir> <dst_dir> [<name>...]
# 自分の link とみなすのは checkout の中を指す symlink だけで、Orca や playwright-cli など
# ほかの道具が置いたものには触らない。readlink の生の文字列で比べ、正規化しない。
# 自分の link は、指す先が残っていても実体の場所と違えば張り直す。古い skill の
# ディレクトリに gitignore されたものが残り、link が壊れないことがあるため。
function sync_skill_links() {
  local -r checkout_dir=$1
  local -r src_dir=$2
  local -r dst_dir=$3
  shift 3
  local entry name target

  if [ -L "$dst_dir" ]; then
    echo "replace symlink $dst_dir (-> $(readlink "$dst_dir")) with a directory"
    rm "$dst_dir"
  fi
  mkdir -p "$dst_dir"

  for entry in "$dst_dir"/*; do
    [ -L "$entry" ] || continue
    target=$(readlink "$entry")
    [[ "$target" == "$checkout_dir/"* ]] || continue
    name=$(basename "$entry")
    if [ ! -e "$entry" ] || ! _skill_listed "$name" "$@"; then
      echo "remove $entry"
      rm "$entry"
    fi
  done

  for name in "$@"; do
    if [ ! -d "$src_dir/$name" ]; then
      echo "skill not found: $src_dir/$name"
      continue
    fi
    entry="$dst_dir/$name"
    if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then
      echo "symlink $src_dir/$name to $entry"
      ln -s "$src_dir/$name" "$entry"
      continue
    fi
    target=""
    [ -L "$entry" ] && target=$(readlink "$entry")
    if [[ "$target" != "$checkout_dir/"* ]]; then
      echo "skip $entry: not a link placed by setup"
    elif [ "$target" = "$src_dir/$name" ]; then
      echo "already exist $entry"
    else
      echo "relink $entry to $src_dir/$name"
      rm "$entry"
      ln -s "$src_dir/$name" "$entry"
    fi
  done
  return 0
}

# 先頭の名前が、続く名前の中にあるかを返す。
function _skill_listed() {
  local -r want=$1
  shift
  local n
  for n in "$@"; do
    [ "$n" = "$want" ] && return 0
  done
  return 1
}

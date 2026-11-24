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

# Copy src to dst only if dst does not exist.
# エージェントが書き込む設定の雛形用。link にすると端末ごとの記録が dotfiles に入る。
# -e だけだと指す先の無い symlink を無いものとみなし、その先に書いてしまう。
function create_copy() {
  local -r src=$1
  local -r dst=$2

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "already exist $dst"
    return 0
  fi

  echo "copy $src to $dst"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
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
# 片づけで消すのは checkout の中を指す symlink だけで、Orca や playwright-cli など
# ほかの道具が置いたものは消さない。一覧の名前の壊れた link は、指す先を問わず張り直す。
function sync_skill_links() {
  local -r checkout_dir=$1
  local -r src_dir=$2
  local -r dst_dir=$3
  shift 3
  local entry name target

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
    create_symlink "$src_dir/$name" "$dst_dir/$name"
  done
  return 0
}

function _skill_listed() {
  local -r want=$1
  shift
  local n
  for n in "$@"; do
    [ "$n" = "$want" ] && return 0
  done
  return 1
}

# Claude Code と Codex が読む skill を、それぞれの一覧のとおりに張る。
# Usage: link_agent_skills <checkout_dir>
function link_agent_skills() {
  local -r checkout_dir=$1
  local -r src_dir="$checkout_dir/.config/agents/skills"

  # 新しい skill は、見せたい側の一覧に名前を足すまでどちらからも見えない。
  local -r claude_skills=(
    diagram
    doc-conventions
    gh-ops
    gh-pr-resolve
    gh-pr-review
    git-commit
    js-page-fetch
    subagent-first
    superpowers-conventions
  )
  local -r codex_skills=()

  sync_skill_links "$checkout_dir" "$src_dir" "$HOME/.claude/skills" "${claude_skills[@]}"
  sync_skill_links "$checkout_dir" "$src_dir" "$HOME/.agents/skills" ${codex_skills[@]+"${codex_skills[@]}"}
  return 0
}

# setup は <dir> を指す設定 (rc の source 行や symlink) を $HOME に残す。linked worktree は
# 後で消えるので正本にしてはいけない。古い git は未知の --path-format をそのまま出力して
# 0 を返すため、2 つの値が絶対パスでなければ判定しない。
# Usage: refuse_linked_worktree <dir>
function refuse_linked_worktree() {
  local -r dir="$1"
  local git_dir common_dir
  git_dir=$(git -C "$dir" rev-parse --path-format=absolute --git-dir 2>/dev/null) || return 0
  common_dir=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 0
  case "$git_dir" in /*) ;; *) return 0 ;; esac
  case "$common_dir" in /*) ;; *) return 0 ;; esac
  [ "$git_dir" = "$common_dir" ] && return 0

  echo "error: run setup from the primary checkout, not a linked worktree: $dir" >&2
  echo "primary checkout: ${common_dir%/*}" >&2
  return 1
}

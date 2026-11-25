#!/usr/bin/env bats

# Tests for the agent-codex function in .config/codex/codex.sh.

CODEX_SH="$BATS_TEST_DIRNAME/../.config/codex/codex.sh"

setup() {
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX
  HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.config/gh-agent"
  ln -s "$BATS_TEST_DIRNAME/../.config/agents" "$HOME/.config/agents"
  REPO="$BATS_TEST_TMPDIR/repo"
}

make_repo() {
  git init -q "$REPO"
  git -C "$REPO" remote add origin "$1"
}

# Orca がペインのシェルに codex 関数を定義する状況に合わせ、codex は関数で置き換える。
# 呼び出しの後に GH_CONFIG_DIR を出し、名義が呼んだシェルに残らないことを確かめる。
run_agent_codex() {
  cd "$REPO"
  run env -u GH_CONFIG_DIR -u GIT_AUTHOR_NAME -u GIT_CONFIG_COUNT HOME="$HOME" CODEX_SH="$CODEX_SH" \
    "${AGENT_SHELL:-bash}" -c '
      codex() {
        echo "GH_CONFIG_DIR=${GH_CONFIG_DIR:-}"
        echo "GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-}"
        echo "args=$*"
      }
      . "$CODEX_SH"
      agent-codex "$@" || exit
      echo "after=${GH_CONFIG_DIR:-}"
    ' agent-codex "$@"
}

@test "agent-codex: switches to the bot and passes arguments through" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_agent_codex --no-daemon -c disable_paste_burst=true "do it"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=$HOME/.config/gh-agent" ]
  [ "${lines[1]}" = "GIT_AUTHOR_NAME=iimuz-agent[bot]" ]
  [ "${lines[2]}" = "args=--no-daemon -c disable_paste_burst=true do it" ]
  [ "${lines[3]}" = "after=" ]
}

@test "agent-codex: works the same in zsh" {
  command -v zsh >/dev/null || skip "zsh is not installed"
  make_repo https://github.com/iimuz/dotfiles.git
  AGENT_SHELL=zsh run_agent_codex -C"$REPO" "do it"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=$HOME/.config/gh-agent" ]
  [ "${lines[2]}" = "args=-C$REPO do it" ]
  [ "${lines[3]}" = "after=" ]
}

@test "agent-codex: keeps the environment for another owner" {
  make_repo https://github.com/other/dotfiles.git
  run_agent_codex hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=" ]
  [ "${lines[1]}" = "GIT_AUTHOR_NAME=" ]
  [ "${lines[2]}" = "args=hello" ]
}

@test "agent-codex: fails without starting codex when the hook script is missing" {
  make_repo https://github.com/iimuz/dotfiles.git
  rm "$HOME/.config/agents"
  run_agent_codex hello
  [ "$status" -ne 0 ]
  [[ "$output" != *"args="* ]]
}

@test "agent-codex: judges the identity by the directory given with -C" {
  make_repo https://github.com/iimuz/dotfiles.git
  OTHER="$BATS_TEST_TMPDIR/other"
  git init -q "$OTHER"
  git -C "$OTHER" remote add origin https://github.com/other/dotfiles.git
  run_agent_codex -C "$OTHER" hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=" ]
  [ "${lines[2]}" = "args=-C $OTHER hello" ]
}

@test "agent-codex: judges the identity by the directory given with --cd=" {
  make_repo https://github.com/other/dotfiles.git
  MINE="$BATS_TEST_TMPDIR/mine"
  git init -q "$MINE"
  git -C "$MINE" remote add origin https://github.com/iimuz/dotfiles.git
  run_agent_codex --cd="$MINE" hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=$HOME/.config/gh-agent" ]
  [ "${lines[2]}" = "args=--cd=$MINE hello" ]
}

@test "agent-codex: judges the identity by the directory given with --cd" {
  make_repo https://github.com/other/dotfiles.git
  MINE="$BATS_TEST_TMPDIR/mine"
  git init -q "$MINE"
  git -C "$MINE" remote add origin https://github.com/iimuz/dotfiles.git
  run_agent_codex --cd "$MINE" hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=$HOME/.config/gh-agent" ]
  [ "${lines[2]}" = "args=--cd $MINE hello" ]
}

@test "agent-codex: judges the identity by the directory attached to -C" {
  make_repo https://github.com/iimuz/dotfiles.git
  OTHER="$BATS_TEST_TMPDIR/other"
  git init -q "$OTHER"
  git -C "$OTHER" remote add origin https://github.com/other/dotfiles.git
  run_agent_codex -C"$OTHER" hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=" ]
  [ "${lines[2]}" = "args=-C$OTHER hello" ]
}

@test "agent-codex: judges the identity by the directory given with -C=" {
  make_repo https://github.com/iimuz/dotfiles.git
  OTHER="$BATS_TEST_TMPDIR/other"
  git init -q "$OTHER"
  git -C "$OTHER" remote add origin https://github.com/other/dotfiles.git
  run_agent_codex -C="$OTHER" hello
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=" ]
  [ "${lines[2]}" = "args=-C=$OTHER hello" ]
}

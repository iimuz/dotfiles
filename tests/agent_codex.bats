#!/usr/bin/env bats

# Tests for .config/codex/bin/agent-codex.

AGENT_CODEX="$BATS_TEST_DIRNAME/../.config/codex/bin/agent-codex"

setup() {
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX
  HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.config/gh-agent"
  ln -s "$BATS_TEST_DIRNAME/../.config/agents" "$HOME/.config/agents"
  REPO="$BATS_TEST_TMPDIR/repo"
  BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$BIN"
  cat >"$BIN/codex" <<'SH'
#!/usr/bin/env bash
echo "GH_CONFIG_DIR=${GH_CONFIG_DIR:-}"
echo "GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-}"
echo "args=$*"
echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE:-}"
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID-unset}"
SH
  chmod +x "$BIN/codex"
}

make_repo() {
  git init -q "$REPO"
  git -C "$REPO" remote add origin "$1"
}

run_agent_codex() {
  cd "$REPO"
  run env -u AWS_CONFIG_FILE -u GH_CONFIG_DIR -u GIT_AUTHOR_NAME -u GIT_CONFIG_COUNT HOME="$HOME" PATH="$BIN:$PATH" "$AGENT_CODEX" "$@"
}

@test "agent-codex: switches to the bot and passes arguments through" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_agent_codex --no-daemon -c disable_paste_burst=true "do it"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GH_CONFIG_DIR=$HOME/.config/gh-agent" ]
  [ "${lines[1]}" = "GIT_AUTHOR_NAME=iimuz-agent[bot]" ]
  [ "${lines[2]}" = "args=--no-daemon -c disable_paste_burst=true do it" ]
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

@test "agent-codex: points AWS at the agent config for any owner" {
  make_repo https://github.com/other/dotfiles.git
  run_agent_codex hello
  [ "$status" -eq 0 ]
  [ "${lines[3]}" = "AWS_CONFIG_FILE=$HOME/.aws/agent/config" ]
}

@test "agent-codex: clears inherited AWS keys" {
  make_repo https://github.com/iimuz/dotfiles.git
  export AWS_ACCESS_KEY_ID=dummy
  run_agent_codex hello
  [ "$status" -eq 0 ]
  [ "${lines[4]}" = "AWS_ACCESS_KEY_ID=unset" ]
}

@test "agent-codex: fails without starting codex when the aws hook fails" {
  make_repo https://github.com/iimuz/dotfiles.git
  rm "$HOME/.config/agents"
  mkdir -p "$HOME/.config/agents/hooks"
  ln -s "$BATS_TEST_DIRNAME/../.config/agents/hooks/gh-identity.sh" "$HOME/.config/agents/hooks/gh-identity.sh"
  run_agent_codex hello
  [ "$status" -ne 0 ]
  [[ "$output" != *"args="* ]]
}

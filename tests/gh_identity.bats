#!/usr/bin/env bats

# Tests for .config/claude/hooks/gh-identity.sh.

HOOK="$BATS_TEST_DIRNAME/../.config/claude/hooks/gh-identity.sh"

setup() {
  # Under a git hook these point at the outer repository and would redirect `git init` there.
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX
  HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.config/gh-agent"
  ENV_FILE="$BATS_TEST_TMPDIR/claude_env"
  REPO="$BATS_TEST_TMPDIR/repo"
}

make_repo() {
  git init -q "$REPO"
  git -C "$REPO" remote add origin "$1"
}

run_hook() {
  run env -u CLAUDE_KEEP_GH_IDENTITY -u GIT_CONFIG_COUNT "$@" \
    HOME="$HOME" CLAUDE_ENV_FILE="$ENV_FILE" CLAUDE_PROJECT_DIR="$REPO" "$HOOK" </dev/null
}

expected_lines() {
  local n=$1
  cat <<LINES
export GH_CONFIG_DIR='$HOME/.config/gh-agent'
export GH_CONFIG_DIR_AGENT='$HOME/.config/gh-agent'
export CLAUDE_GH_APP_SLUG='iimuz-agent'
export GIT_AUTHOR_NAME='iimuz-agent[bot]'
export GIT_AUTHOR_EMAIL='351267992+iimuz-agent[bot]@users.noreply.github.com'
export GIT_COMMITTER_NAME='iimuz-agent[bot]'
export GIT_COMMITTER_EMAIL='351267992+iimuz-agent[bot]@users.noreply.github.com'
export GIT_CONFIG_KEY_$n='url.https://github.com/iimuz/.insteadOf'
export GIT_CONFIG_VALUE_$n='git@github.com:iimuz/'
export GIT_CONFIG_KEY_$((n + 1))='url.https://github.com/iimuz/.insteadOf'
export GIT_CONFIG_VALUE_$((n + 1))='ssh://git@github.com/iimuz/'
export GIT_CONFIG_COUNT=$((n + 2))
unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
LINES
}

assert_switched() {
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  diff <(expected_lines "$1") "$ENV_FILE"
}

assert_skipped() {
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$ENV_FILE" ]
}

@test "gh-identity.sh: switches for https origin under iimuz" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook
  assert_switched 0
}

@test "gh-identity.sh: switches for https origin without .git suffix" {
  make_repo https://github.com/iimuz/dotfiles
  run_hook
  assert_switched 0
}

@test "gh-identity.sh: switches for scp-like ssh origin" {
  make_repo git@github.com:iimuz/dotfiles.git
  run_hook
  assert_switched 0
}

@test "gh-identity.sh: switches for ssh:// origin" {
  make_repo ssh://git@github.com/iimuz/dotfiles.git
  run_hook
  assert_switched 0
}

@test "gh-identity.sh: switches when CLAUDE_KEEP_GH_IDENTITY is not 1" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook CLAUDE_KEEP_GH_IDENTITY=0
  assert_switched 0
  rm "$ENV_FILE"
  run_hook CLAUDE_KEEP_GH_IDENTITY=
  assert_switched 0
}

@test "gh-identity.sh: appends without removing existing lines" {
  make_repo https://github.com/iimuz/dotfiles.git
  echo "export FOO=bar" >"$ENV_FILE"
  run_hook
  [ "$status" -eq 0 ]
  [ "$(head -n 1 "$ENV_FILE")" = "export FOO=bar" ]
  diff <(expected_lines 0) <(tail -n +2 "$ENV_FILE")
}

@test "gh-identity.sh: indexes git config after the inherited GIT_CONFIG_COUNT" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook GIT_CONFIG_COUNT=1
  assert_switched 1
}

@test "gh-identity.sh: restarts git config index on a non-numeric GIT_CONFIG_COUNT" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook GIT_CONFIG_COUNT=abc
  assert_switched 0
}

rewritten_url() {
  run env HOME="$HOME" GIT_CONFIG_NOSYSTEM=1 \
    bash -c '. "$1"; git ls-remote --get-url "$2"' _ "$ENV_FILE" "$1"
}

@test "gh-identity.sh: rewrites personal ssh urls to https" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook
  rewritten_url git@github.com:iimuz/dotfiles.git
  [ "$output" = "https://github.com/iimuz/dotfiles.git" ]
  rewritten_url ssh://git@github.com/iimuz/dotfiles.git
  [ "$output" = "https://github.com/iimuz/dotfiles.git" ]
}

@test "gh-identity.sh: leaves other owners' ssh urls" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook
  rewritten_url git@github.com:someone/repo.git
  [ "$output" = "git@github.com:someone/repo.git" ]
}

@test "gh-identity.sh: skips when CLAUDE_KEEP_GH_IDENTITY=1" {
  make_repo https://github.com/iimuz/dotfiles.git
  run_hook CLAUDE_KEEP_GH_IDENTITY=1
  assert_skipped
}

@test "gh-identity.sh: skips when the agent gh config dir is missing" {
  make_repo https://github.com/iimuz/dotfiles.git
  rm -r "$HOME/.config/gh-agent"
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips for another owner" {
  make_repo https://github.com/someone/repo.git
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips for an owner sharing the prefix" {
  make_repo https://github.com/iimuz-other/repo.git
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips an owner differing in case" {
  make_repo https://github.com/IIMUZ/dotfiles.git
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips ssh origin of another owner" {
  make_repo git@github.com:someone/repo.git
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips outside a git repository" {
  mkdir -p "$REPO"
  run_hook
  assert_skipped
}

@test "gh-identity.sh: skips a repository without origin" {
  git init -q "$REPO"
  run_hook
  assert_skipped
}

@test "gh-identity.sh: does nothing without CLAUDE_ENV_FILE" {
  make_repo https://github.com/iimuz/dotfiles.git
  run env -u CLAUDE_ENV_FILE -u CLAUDE_KEEP_GH_IDENTITY HOME="$HOME" \
    CLAUDE_PROJECT_DIR="$REPO" "$HOOK" </dev/null
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$ENV_FILE" ]
}

@test "gh-identity.sh: leaves an existing env file untouched when CLAUDE_KEEP_GH_IDENTITY=1" {
  make_repo https://github.com/iimuz/dotfiles.git
  echo "export FOO=bar" >"$ENV_FILE"
  run_hook CLAUDE_KEEP_GH_IDENTITY=1
  [ "$status" -eq 0 ]
  [ "$(cat "$ENV_FILE")" = "export FOO=bar" ]
}

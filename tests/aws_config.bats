#!/usr/bin/env bats

# Tests for .config/agents/hooks/aws-config.sh.

HOOK="$BATS_TEST_DIRNAME/../.config/agents/hooks/aws-config.sh"

setup() {
  HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  ENV_FILE="$BATS_TEST_TMPDIR/claude_env"
}

run_hook() {
  run env -u AWS_CONFIG_FILE "$@" HOME="$HOME" CLAUDE_ENV_FILE="$ENV_FILE" "$HOOK" </dev/null
}

expected_lines() {
  cat <<LINES
export AWS_CONFIG_FILE='$HOME/.aws/agent/config'
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_CREDENTIAL_EXPIRATION
LINES
}

@test "aws-config.sh: appends the exports to CLAUDE_ENV_FILE" {
  run_hook
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  diff <(expected_lines) "$ENV_FILE"
}

@test "aws-config.sh: keeps lines already in CLAUDE_ENV_FILE" {
  echo "export FOO='bar'" >"$ENV_FILE"
  run_hook
  [ "$status" -eq 0 ]
  diff <(
    echo "export FOO='bar'"
    expected_lines
  ) "$ENV_FILE"
}

@test "aws-config.sh: points at the agent config even when it does not exist" {
  run_hook
  [ "$status" -eq 0 ]
  diff <(expected_lines) "$ENV_FILE"
  [ ! -e "$HOME/.aws/agent/config" ]
}

@test "aws-config.sh: does nothing without CLAUDE_ENV_FILE" {
  run env -u CLAUDE_ENV_FILE HOME="$HOME" "$HOOK" </dev/null
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$ENV_FILE" ]
}

@test "aws-config.sh --print: prints the same exports" {
  run env -u CLAUDE_ENV_FILE HOME="$HOME" "$HOOK" --print </dev/null
  [ "$status" -eq 0 ]
  [ "$output" = "$(expected_lines)" ]
}

@test "aws-config.sh: sourcing the exports clears inherited AWS keys" {
  run_hook
  run bash -c 'export AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy AWS_SESSION_TOKEN=dummy; . "$1"; echo "${AWS_ACCESS_KEY_ID-unset} ${AWS_SECRET_ACCESS_KEY-unset} ${AWS_SESSION_TOKEN-unset} $AWS_CONFIG_FILE"' _ "$ENV_FILE"
  [ "$output" = "unset unset unset $HOME/.aws/agent/config" ]
}

@test "aws-config.sh: quotes a HOME that contains a space" {
  HOME="$BATS_TEST_TMPDIR/my home"
  mkdir -p "$HOME"
  run_hook
  run bash -c '. "$1"; echo "$AWS_CONFIG_FILE"' _ "$ENV_FILE"
  [ "$output" = "$BATS_TEST_TMPDIR/my home/.aws/agent/config" ]
}

@test "aws-config.sh: quotes a HOME that contains a single quote" {
  HOME="$BATS_TEST_TMPDIR/it's home"
  mkdir -p "$HOME"
  run_hook
  run bash -c '. "$1"; echo "$AWS_CONFIG_FILE"' _ "$ENV_FILE"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TEST_TMPDIR/it's home/.aws/agent/config" ]
}

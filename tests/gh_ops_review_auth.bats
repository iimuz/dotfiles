#!/usr/bin/env bats

# Tests for the gh auth failure message of the gh-ops review scripts.

bats_require_minimum_version 1.5.0

SCRIPTS="$BATS_TEST_DIRNAME/../.config/claude/skills/gh-ops/scripts"

setup() {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/gh" <<'STUB'
#!/bin/bash
exit 1
STUB
  cat >"$stub_bin/python3" <<'STUB'
#!/bin/bash
exit 0
STUB
  chmod +x "$stub_bin"/*
  PATH="$stub_bin:$PATH"
}

@test "create_review.sh: names the expired bot token in a bot session" {
  run --separate-stderr env GH_CONFIG_DIR="$HOME/.config/gh-agent" "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"The bot token may have expired; 'gh auth login' does not renew it."* ]]
  [[ "$stderr" != *"Run 'gh auth login' and try again."* ]]
}

@test "create_review.sh: keeps the gh auth login hint without GH_CONFIG_DIR" {
  run --separate-stderr env -u GH_CONFIG_DIR "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

@test "create_review.sh: keeps the gh auth login hint in another gh config dir" {
  run --separate-stderr env GH_CONFIG_DIR="$BATS_TEST_TMPDIR/other-gh" "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: names the expired bot token in a bot session" {
  run --separate-stderr env GH_CONFIG_DIR="$HOME/.config/gh-agent" "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"The bot token may have expired; 'gh auth login' does not renew it."* ]]
  [[ "$stderr" != *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: keeps the gh auth login hint without GH_CONFIG_DIR" {
  run --separate-stderr env -u GH_CONFIG_DIR "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: keeps the gh auth login hint in another gh config dir" {
  run --separate-stderr env GH_CONFIG_DIR="$BATS_TEST_TMPDIR/other-gh" "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

@test "reply_review.sh: names the expired bot token in a bot session" {
  run --separate-stderr env GH_CONFIG_DIR="$HOME/.config/gh-agent" "$SCRIPTS/reply_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"The bot token may have expired; 'gh auth login' does not renew it."* ]]
  [[ "$stderr" != *"Run 'gh auth login' and try again."* ]]
}

@test "reply_review.sh: keeps the gh auth login hint without GH_CONFIG_DIR" {
  run --separate-stderr env -u GH_CONFIG_DIR "$SCRIPTS/reply_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

@test "reply_review.sh: keeps the gh auth login hint in another gh config dir" {
  run --separate-stderr env GH_CONFIG_DIR="$BATS_TEST_TMPDIR/other-gh" "$SCRIPTS/reply_review.sh"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Run 'gh auth login' and try again."* ]]
}

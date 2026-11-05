#!/usr/bin/env bats

# Tests for the gh auth failure message of the gh-ops review scripts.

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
  run env GH_CONFIG_DIR="$HOME/.config/gh-agent" "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"The bot token may have expired; 'gh auth login' does not renew it."* ]]
  [[ "$output" != *"Run 'gh auth login' and try again."* ]]
}

@test "create_review.sh: keeps the gh auth login hint without GH_CONFIG_DIR" {
  run env -u GH_CONFIG_DIR "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Run 'gh auth login' and try again."* ]]
}

@test "create_review.sh: keeps the gh auth login hint in another gh config dir" {
  run env GH_CONFIG_DIR="$BATS_TEST_TMPDIR/other-gh" "$SCRIPTS/create_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: names the expired bot token in a bot session" {
  run env GH_CONFIG_DIR="$HOME/.config/gh-agent" "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"The bot token may have expired; 'gh auth login' does not renew it."* ]]
  [[ "$output" != *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: keeps the gh auth login hint without GH_CONFIG_DIR" {
  run env -u GH_CONFIG_DIR "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Run 'gh auth login' and try again."* ]]
}

@test "append_review.sh: keeps the gh auth login hint in another gh config dir" {
  run env GH_CONFIG_DIR="$BATS_TEST_TMPDIR/other-gh" "$SCRIPTS/append_review.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Run 'gh auth login' and try again."* ]]
}

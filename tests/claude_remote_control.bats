#!/usr/bin/env bats

# Tests for claude_remote_control in .config/claude/claude.sh.

SCRIPT="$BATS_TEST_DIRNAME/../.config/claude/claude.sh"

setup() {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/claude" <<'STUB'
#!/bin/bash
echo "trusted=$MISE_TRUSTED_CONFIG_PATHS"
STUB
  chmod +x "$stub_bin/claude"
  PATH="$stub_bin:$PATH"
  WORK_DIR="$BATS_TEST_TMPDIR/work"
  mkdir -p "$WORK_DIR"
}

@test "passes the worktrees directory as trusted mise config path" {
  cd "$WORK_DIR"
  source "$SCRIPT"
  run claude_remote_control x
  [ "$status" -eq 0 ]
  [ "$output" = "trusted=$PWD/.claude/worktrees/" ]
}

@test "overrides an existing MISE_TRUSTED_CONFIG_PATHS and does not leak it" {
  cd "$WORK_DIR"
  source "$SCRIPT"
  export MISE_TRUSTED_CONFIG_PATHS=/existing
  run claude_remote_control x
  [ "$output" = "trusted=$PWD/.claude/worktrees/" ]
  [ "$MISE_TRUSTED_CONFIG_PATHS" = "/existing" ]
}

@test "does not set MISE_TRUSTED_CONFIG_PATHS in the calling shell" {
  cd "$WORK_DIR"
  source "$SCRIPT"
  unset MISE_TRUSTED_CONFIG_PATHS
  claude_remote_control x >/dev/null
  [ -z "${MISE_TRUSTED_CONFIG_PATHS+set}" ]
}

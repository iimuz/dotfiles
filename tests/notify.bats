#!/usr/bin/env bats

# Tests for .config/claude/hooks/notify.sh cmux/herdr/Orca guard behavior.

NOTIFY_SH="$BATS_TEST_DIRNAME/../.config/claude/hooks/notify.sh"

setup() {
  # Stub osascript that records its arguments instead of showing a dialog.
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  ARGS_LOG="$BATS_TEST_TMPDIR/osascript_args.log"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/osascript" <<STUB
#!/bin/bash
echo "\$@" >> "$ARGS_LOG"
STUB
  chmod +x "$stub_bin/osascript"
  PATH="$stub_bin:$PATH"
}

@test "notify.sh: skips osascript inside cmux (CMUX_CLAUDE_HOOK_CMUX_BIN set)" {
  run env -u HERDR_ENV -u CLAUDE_CODE_ENTRYPOINT \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CMUX_CLAUDE_HOOK_CMUX_BIN="/fake/cmux/bin" "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: calls osascript outside cmux and herdr" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    -u CLAUDE_CODE_ENTRYPOINT "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

@test "notify.sh: skips osascript inside herdr (HERDR_ENV=1)" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u CLAUDE_CODE_ENTRYPOINT \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    HERDR_ENV=1 "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: skips osascript in Claude Desktop (CLAUDE_CODE_ENTRYPOINT=claude-desktop)" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=claude-desktop "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: skips osascript in headless sessions (CLAUDE_CODE_ENTRYPOINT=sdk-cli)" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=sdk-cli "$NOTIFY_SH" stop
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: skips notification events in headless sessions (CLAUDE_CODE_ENTRYPOINT=sdk-cli)" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=sdk-cli "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: calls osascript from the cli entrypoint" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=cli "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

@test "notify.sh: skips osascript inside Orca (ORCA_AGENT_HOOK_PORT and ORCA_PANE_KEY set)" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=cli ORCA_AGENT_HOOK_PORT=50000 ORCA_PANE_KEY=tab:pane \
    "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: skips stop events inside Orca when only ORCA_AGENT_PANE identifies the pane" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV -u ORCA_PANE_KEY \
    CLAUDE_CODE_ENTRYPOINT=cli ORCA_AGENT_HOOK_PORT=50000 ORCA_AGENT_PANE=tab:pane \
    "$NOTIFY_SH" stop
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: calls osascript in an Orca terminal without Orca's hook variables" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV \
    -u ORCA_AGENT_HOOK_PORT -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=cli TERM_PROGRAM=Orca "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

@test "notify.sh: calls osascript when only ORCA_AGENT_HOOK_PORT is set" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV -u ORCA_PANE_KEY -u ORCA_AGENT_PANE \
    CLAUDE_CODE_ENTRYPOINT=cli ORCA_AGENT_HOOK_PORT=50000 "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

@test "notify.sh: calls osascript when only a pane key is set without ORCA_AGENT_HOOK_PORT" {
  run env -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV -u ORCA_AGENT_HOOK_PORT \
    CLAUDE_CODE_ENTRYPOINT=cli ORCA_PANE_KEY=tab:pane ORCA_AGENT_PANE=tab:pane \
    "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

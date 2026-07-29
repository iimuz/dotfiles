#!/usr/bin/env bats

# Tests for .config/claude/hooks/notify.sh cmux guard behavior.

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

@test "notify.sh: skips osascript inside cmux (CMUX_SURFACE_ID set)" {
  run env -u TMUX -u TMUX_PANE CMUX_SURFACE_ID="test-surface" "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: calls osascript outside cmux (CMUX_SURFACE_ID unset)" {
  run env -u TMUX -u TMUX_PANE -u CMUX_SURFACE_ID "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

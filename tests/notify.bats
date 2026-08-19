#!/usr/bin/env bats

# Tests for .config/claude/hooks/notify.sh cmux/herdr guard behavior.

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
  run env -u TMUX -u TMUX_PANE -u HERDR_ENV CMUX_CLAUDE_HOOK_CMUX_BIN="/fake/cmux/bin" "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

@test "notify.sh: calls osascript outside cmux and herdr" {
  run env -u TMUX -u TMUX_PANE -u CMUX_CLAUDE_HOOK_CMUX_BIN -u HERDR_ENV "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ -f "$ARGS_LOG" ]
  grep -qF "display notification" "$ARGS_LOG"
}

@test "notify.sh: skips osascript inside herdr (HERDR_ENV=1)" {
  run env -u TMUX -u TMUX_PANE -u CMUX_CLAUDE_HOOK_CMUX_BIN HERDR_ENV=1 "$NOTIFY_SH" notification
  [ "$status" -eq 0 ]
  [ ! -f "$ARGS_LOG" ]
}

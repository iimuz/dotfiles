#!/usr/bin/env bats

# Tests for the draft function in .config/bash/command.sh.

setup() {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  ARGS_LOG="$BATS_TEST_TMPDIR/nvim_args.log"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/nvim" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >"$ARGS_LOG"
STUB
  chmod +x "$stub_bin/nvim"
  PATH="$stub_bin:$PATH"
  source "$BATS_TEST_DIRNAME/../.config/bash/command.sh"
}

@test "draft: creates the drafts directory under XDG_DATA_HOME and opens three tabs" {
  export XDG_DATA_HOME="$BATS_TEST_TMPDIR/data"
  run draft
  [ "$status" -eq 0 ]
  [ -d "$XDG_DATA_HOME/drafts" ]
  [ "$(cat "$ARGS_LOG")" = "$(printf '%s\n' -p "$XDG_DATA_HOME/drafts/1.md" "$XDG_DATA_HOME/drafts/2.md" "$XDG_DATA_HOME/drafts/3.md")" ]
}

@test "draft: falls back to HOME/.local/share when XDG_DATA_HOME is unset" {
  unset XDG_DATA_HOME
  export HOME="$BATS_TEST_TMPDIR/home"
  run draft
  [ "$status" -eq 0 ]
  [ -d "$HOME/.local/share/drafts" ]
  [ "$(sed -n 2p "$ARGS_LOG")" = "$HOME/.local/share/drafts/1.md" ]
}

@test "draft: passes paths containing spaces as single arguments" {
  export XDG_DATA_HOME="$BATS_TEST_TMPDIR/with space"
  run draft
  [ "$status" -eq 0 ]
  [ "$(wc -l <"$ARGS_LOG" | tr -d ' ')" -eq 4 ]
  [ "$(sed -n 2p "$ARGS_LOG")" = "$XDG_DATA_HOME/drafts/1.md" ]
}

@test "draft: returns without opening nvim when the drafts directory cannot be created" {
  export XDG_DATA_HOME="$BATS_TEST_TMPDIR/data"
  mkdir -p "$XDG_DATA_HOME"
  touch "$XDG_DATA_HOME/drafts"
  run draft
  [ "$status" -ne 0 ]
  [ ! -e "$ARGS_LOG" ]
}

#!/usr/bin/env bats

# Tests for lib/setup-common.sh shared helper functions.

setup() {
  source "$BATS_TEST_DIRNAME/../lib/setup-common.sh"
}

# --- create_symlink ---

@test "create_symlink: creates a symlink from src to dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/dst_link"
  echo "content" >"$src"

  run create_symlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"symlink"* ]]
  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "create_symlink: auto-creates missing parent directories of dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/a/b/c/dst_link"
  echo "content" >"$src"

  run create_symlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "create_symlink: returns 0 and does not modify existing dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/existing_dst"
  echo "content" >"$src"
  echo "existing" >"$dst"

  run create_symlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  # dst is still a regular file, not a symlink
  [ ! -L "$dst" ]
  [ "$(cat "$dst")" = "existing" ]
}

# --- create_hardlink ---

# Reads a file's inode number. Portable across GNU stat (Linux, `-c`) and
# BSD stat (macOS, `-f`).
get_inode() {
  stat -c %i "$1" 2>/dev/null || stat -f %i "$1"
}

@test "create_hardlink: creates a hard link from src to dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/dst_link"
  echo "content" >"$src"

  run create_hardlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [ -e "$dst" ]
  [ ! -L "$dst" ]
  # Hard link shares inode
  local src_inode dst_inode
  src_inode=$(get_inode "$src")
  dst_inode=$(get_inode "$dst")
  [ "$src_inode" = "$dst_inode" ]
}

@test "create_hardlink: auto-creates missing parent directories of dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/a/b/c/dst_link"
  echo "content" >"$src"

  run create_hardlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [ -e "$dst" ]
  local src_inode dst_inode
  src_inode=$(get_inode "$src")
  dst_inode=$(get_inode "$dst")
  [ "$src_inode" = "$dst_inode" ]
}

@test "create_hardlink: returns 0 and does not modify existing dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/existing_dst"
  echo "content" >"$src"
  echo "existing" >"$dst"
  local original_inode
  original_inode=$(get_inode "$dst")

  run create_hardlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  # dst unchanged: same inode, same content
  local dst_inode
  dst_inode=$(get_inode "$dst")
  [ "$dst_inode" = "$original_inode" ]
  [ "$(cat "$dst")" = "existing" ]
}

# --- set_bashrc ---

@test "set_bashrc: appends source line to .bashrc when SHELL=/bin/bash" {
  local home_dir="$BATS_TEST_TMPDIR/fakehome"
  mkdir -p "$home_dir"
  HOME="$home_dir"
  SHELL=/bin/bash

  run set_bashrc "/some/file.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"set load setting"* ]]
  grep -qF "/some/file.sh" "$home_dir/.bashrc"
}

@test "set_bashrc: appends source line to .zshrc when SHELL=/bin/zsh" {
  local home_dir="$BATS_TEST_TMPDIR/fakehome"
  mkdir -p "$home_dir"
  HOME="$home_dir"
  SHELL=/bin/zsh

  run set_bashrc "/some/file.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"set load setting"* ]]
  grep -qF "/some/file.sh" "$home_dir/.zshrc"
  # .bashrc should NOT exist
  [ ! -f "$home_dir/.bashrc" ]
}

@test "set_bashrc: calling twice does not duplicate the entry" {
  local home_dir="$BATS_TEST_TMPDIR/fakehome"
  mkdir -p "$home_dir"
  HOME="$home_dir"
  SHELL=/bin/bash

  run set_bashrc "/some/file.sh"
  [ "$status" -eq 0 ]

  run set_bashrc "/some/file.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already setting"* ]]

  # Count occurrences: should be exactly 1
  local count
  count=$(grep -cF "/some/file.sh" "$home_dir/.bashrc")
  [ "$count" -eq 1 ]
}

# --- add_claude_mcp ---

QMD_MCP_JSON='{"type":"http","url":"http://localhost:8181/mcp","timeout":180000}'

@test "add_claude_mcp: adds the server with add-json when claude mcp get fails" {
  local bin_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin_dir"
  local args_log="$BATS_TEST_TMPDIR/claude_args.log"

  # Exit 1 without any message, so the helper cannot depend on the wording.
  cat >"$bin_dir/claude" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >>"$args_log"
if [ "\$1" = "mcp" ] && [ "\$2" = "get" ]; then
  exit 1
fi
STUB
  chmod +x "$bin_dir/claude"
  PATH="$bin_dir:$PATH"

  # Same shell options as the setup scripts.
  run bash -c 'set -eu -o pipefail; . "$1"; add_claude_mcp "$2" "$3"; echo "after add_claude_mcp"' \
    _ "$BATS_TEST_DIRNAME/../lib/setup-common.sh" qmd "$QMD_MCP_JSON"
  [ "$status" -eq 0 ]
  [[ "$output" == *"add claude mcp: qmd"* ]]
  [[ "$output" == *"after add_claude_mcp"* ]]

  local expected
  expected=$(printf '%s\n' mcp get qmd mcp add-json --scope user qmd "$QMD_MCP_JSON")
  [ "$(cat "$args_log")" = "$expected" ]
}

@test "add_claude_mcp: skips when claude mcp get succeeds even if the server is down" {
  local bin_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin_dir"
  local args_log="$BATS_TEST_TMPDIR/claude_args.log"

  cat >"$bin_dir/claude" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >>"$args_log"
if [ "\$1" = "mcp" ] && [ "\$2" = "get" ]; then
  echo "qmd:"
  echo "  Scope: User config (available in all your projects)"
  echo "  Status: ✘ Failed to connect"
  exit 0
fi
STUB
  chmod +x "$bin_dir/claude"
  PATH="$bin_dir:$PATH"

  run add_claude_mcp qmd "$QMD_MCP_JSON"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist claude mcp: qmd"* ]]

  local expected
  expected=$(printf '%s\n' mcp get qmd)
  [ "$(cat "$args_log")" = "$expected" ]
}

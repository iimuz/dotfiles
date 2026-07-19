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
  src_inode=$(stat -c %i "$src")
  dst_inode=$(stat -c %i "$dst")
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
  src_inode=$(stat -c %i "$src")
  dst_inode=$(stat -c %i "$dst")
  [ "$src_inode" = "$dst_inode" ]
}

@test "create_hardlink: returns 0 and does not modify existing dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/existing_dst"
  echo "content" >"$src"
  echo "existing" >"$dst"
  local original_inode
  original_inode=$(stat -c %i "$dst")

  run create_hardlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  # dst unchanged: same inode, same content
  local dst_inode
  dst_inode=$(stat -c %i "$dst")
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

@test "add_claude_mcp: calls claude mcp add when MCP server not found" {
  # Create a stub claude that records args and returns "No MCP server found"
  local bin_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin_dir"
  local args_log="$BATS_TEST_TMPDIR/claude_args.log"

  cat >"$bin_dir/claude" <<STUB
#!/bin/bash
echo "\$@" >> "$args_log"
if [ "\$1" = "mcp" ] && [ "\$2" = "get" ]; then
  echo "No MCP server found"
fi
STUB
  chmod +x "$bin_dir/claude"
  PATH="$bin_dir:$PATH"

  run add_claude_mcp "my-server" "npx" "-y" "some-mcp"
  [ "$status" -eq 0 ]
  [[ "$output" == *"add claude mcp: my-server"* ]]

  # Verify claude mcp add was called with correct args
  grep -qF "mcp add --transport stdio --scope user my-server -- npx -y some-mcp" "$args_log"
}

@test "add_claude_mcp: skips when MCP server already exists" {
  # Create a stub claude that returns something other than "No MCP server found"
  local bin_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin_dir"
  local args_log="$BATS_TEST_TMPDIR/claude_args.log"

  cat >"$bin_dir/claude" <<STUB
#!/bin/bash
echo "\$@" >> "$args_log"
if [ "\$1" = "mcp" ] && [ "\$2" = "get" ]; then
  echo "my-server: connected"
fi
STUB
  chmod +x "$bin_dir/claude"
  PATH="$bin_dir:$PATH"

  run add_claude_mcp "my-server" "npx" "-y" "some-mcp"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist claude mcp: my-server"* ]]

  # Verify claude mcp add was NOT called (only mcp get should appear)
  if [ -f "$args_log" ]; then
    ! grep -qF "mcp add" "$args_log"
  fi
}

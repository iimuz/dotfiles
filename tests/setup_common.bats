#!/usr/bin/env bats

# Tests for lib/setup-common.sh shared helper functions.

setup() {
  # git hook の下では、これらが外側のリポジトリを指して一時リポジトリの判定を変える。
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX
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

@test "create_symlink: replaces a broken symlink at dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/broken_link"
  echo "content" >"$src"
  ln -s "$BATS_TEST_TMPDIR/missing_target" "$dst"

  run create_symlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "create_symlink: keeps a symlink that points to an existing file" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local other="$BATS_TEST_TMPDIR/other_file"
  local dst="$BATS_TEST_TMPDIR/live_link"
  echo "content" >"$src"
  echo "other" >"$other"
  ln -s "$other" "$dst"

  run create_symlink "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  [ "$(readlink "$dst")" = "$other" ]
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

# --- create_copy ---

@test "create_copy: copies src to a missing dst and creates its parents" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/a/b/dst_file"
  echo "content" >"$src"

  run create_copy "$src" "$dst"
  [ "$status" -eq 0 ]
  [ ! -L "$dst" ]
  [ "$(cat "$dst")" = "content" ]
  [ "$(get_inode "$src")" != "$(get_inode "$dst")" ]
}

@test "create_copy: keeps an existing dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local dst="$BATS_TEST_TMPDIR/dst_file"
  echo "content" >"$src"
  echo "existing" >"$dst"

  run create_copy "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  [ "$(cat "$dst")" = "existing" ]
}

@test "create_copy: does not write through a symlink at dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local target="$BATS_TEST_TMPDIR/target_file"
  local dst="$BATS_TEST_TMPDIR/dst_link"
  echo "content" >"$src"
  echo "target" >"$target"
  ln -s "$target" "$dst"

  run create_copy "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  [ -L "$dst" ]
  [ "$(cat "$target")" = "target" ]
}

@test "create_copy: does not write through a dangling symlink at dst" {
  local src="$BATS_TEST_TMPDIR/src_file"
  local target="$BATS_TEST_TMPDIR/missing_target"
  local dst="$BATS_TEST_TMPDIR/dst_link"
  echo "content" >"$src"
  ln -s "$target" "$dst"

  run create_copy "$src" "$dst"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  [ ! -e "$target" ]
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

# --- sync_skill_links ---

# fixture: checkout / src (alpha, beta) / dst の変数を作る
make_skill_fixture() {
  checkout="$BATS_TEST_TMPDIR/checkout"
  src="$checkout/.config/agents/skills"
  dst="$BATS_TEST_TMPDIR/home/.claude/skills"
  mkdir -p "$src/alpha" "$src/beta" "$(dirname "$dst")"
  : >"$src/alpha/SKILL.md"
  : >"$src/beta/SKILL.md"
}

run_sync() {
  run bash -c 'set -eu -o pipefail; . "$1"; shift; sync_skill_links "$@"' \
    _ "$BATS_TEST_DIRNAME/../lib/setup-common.sh" "$checkout" "$src" "$dst" "$@"
}

@test "sync_skill_links: creates dst dir and links only the listed names" {
  make_skill_fixture
  run_sync alpha
  [ "$status" -eq 0 ]
  [ -d "$dst" ] && [ ! -L "$dst" ]
  [ "$(readlink "$dst/alpha")" = "$src/alpha" ]
  [ ! -e "$dst/beta" ]
}

@test "sync_skill_links: leaves a dst dir symlinked to the source dir and its contents as they are" {
  make_skill_fixture
  mkdir "$src/other"
  : >"$src/note.txt"
  ln -s "$src" "$dst"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ "$(readlink "$dst")" = "$src" ]
  [ -d "$src/alpha" ] && [ ! -L "$src/alpha" ]
  [ -d "$src/beta" ] && [ -d "$src/other" ] && [ -f "$src/note.txt" ]
}

@test "sync_skill_links: relinks its own broken link" {
  make_skill_fixture
  mkdir -p "$dst"
  ln -s "$checkout/old/missing" "$dst/alpha"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ "$(readlink "$dst/alpha")" = "$src/alpha" ]
}

@test "sync_skill_links: removes its own links for names not listed and its own broken links" {
  make_skill_fixture
  mkdir -p "$dst"
  ln -s "$src/beta" "$dst/beta"
  ln -s "$checkout/x/gone" "$dst/gone"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ ! -L "$dst/beta" ] && [ ! -L "$dst/gone" ]
  [ -d "$src/beta" ]
}

@test "sync_skill_links: keeps entries setup did not place" {
  make_skill_fixture
  mkdir -p "$dst" "$BATS_TEST_TMPDIR/elsewhere/orca-cli" "${checkout}2/sib" "$dst/synced" "$dst/playwright-cli"
  ln -s "$BATS_TEST_TMPDIR/elsewhere/orca-cli" "$dst/orca-cli"
  ln -s "$BATS_TEST_TMPDIR/nowhere" "$dst/ext-broken"
  ln -s "${checkout}2/sib" "$dst/sib"
  ln -s "../rel-target" "$dst/rel"
  : >"$dst/file.txt"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ "$(readlink "$dst/orca-cli")" = "$BATS_TEST_TMPDIR/elsewhere/orca-cli" ]
  [ "$(readlink "$dst/ext-broken")" = "$BATS_TEST_TMPDIR/nowhere" ]
  [ "$(readlink "$dst/sib")" = "${checkout}2/sib" ]
  [ "$(readlink "$dst/rel")" = "../rel-target" ]
  [ -d "$dst/synced" ] && [ ! -L "$dst/synced" ]
  [ -d "$dst/playwright-cli" ] && [ ! -L "$dst/playwright-cli" ]
  [ -f "$dst/file.txt" ]
}

@test "sync_skill_links: keeps a same-name entry that is not a symlink" {
  make_skill_fixture
  mkdir -p "$dst/alpha"
  : >"$dst/alpha/mine"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ ! -L "$dst/alpha" ]
  [ -f "$dst/alpha/mine" ]
  [[ "$output" == *"already exist $dst/alpha"* ]]
}

@test "sync_skill_links: keeps a same-name live symlink that points outside the checkout" {
  make_skill_fixture
  mkdir -p "$dst" "$BATS_TEST_TMPDIR/elsewhere/alpha"
  ln -s "$BATS_TEST_TMPDIR/elsewhere/alpha" "$dst/alpha"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ "$(readlink "$dst/alpha")" = "$BATS_TEST_TMPDIR/elsewhere/alpha" ]
  [[ "$output" == *"already exist $dst/alpha"* ]]
}

@test "sync_skill_links: relinks a same-name broken symlink that points outside the checkout" {
  make_skill_fixture
  mkdir -p "$dst"
  ln -s "$BATS_TEST_TMPDIR/deleted-worktree/.config/agents/skills/alpha" "$dst/alpha"
  run_sync alpha
  [ "$status" -eq 0 ]
  [ "$(readlink "$dst/alpha")" = "$src/alpha" ]
}

@test "sync_skill_links: warns and continues when a listed skill is missing" {
  make_skill_fixture
  run_sync ghost alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"skill not found"* ]]
  [ ! -e "$dst/ghost" ] && [ ! -L "$dst/ghost" ]
  [ -L "$dst/alpha" ]
}

@test "sync_skill_links: accepts an empty list under set -u" {
  make_skill_fixture
  mkdir -p "$dst"
  ln -s "$src/alpha" "$dst/alpha"
  run_sync
  [ "$status" -eq 0 ]
  [ ! -L "$dst/alpha" ]
  run_sync
  [ "$status" -eq 0 ]
}

@test "sync_skill_links: is idempotent" {
  make_skill_fixture
  run_sync alpha beta
  [ "$status" -eq 0 ]
  local first_a first_b
  first_a=$(readlink "$dst/alpha")
  first_b=$(readlink "$dst/beta")
  run_sync alpha beta
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exist"* ]]
  [[ "$output" != *"remove"* ]]
  [ "$(readlink "$dst/alpha")" = "$first_a" ]
  [ "$(readlink "$dst/beta")" = "$first_b" ]
}

# --- link_agent_skills ---

run_link_agent_skills() {
  local -r shell=$1
  local -r repo="$BATS_TEST_DIRNAME/.."
  HOME="$BATS_TEST_TMPDIR/home" run "$shell" -c 'set -eu -o pipefail; . "$1"; link_agent_skills "$2"' \
    _ "$repo/lib/setup-common.sh" "$repo"
}

@test "link_agent_skills: every tracked skill is on a list and every listed name exists" {
  local -r repo="$BATS_TEST_DIRNAME/.."
  run_link_agent_skills bash
  [ "$status" -eq 0 ]
  [[ "$output" != *"skill not found"* ]]
  local h="$BATS_TEST_TMPDIR/home" name link missing="" seen=0
  [ -d "$h/.claude/skills" ] && [ ! -L "$h/.claude/skills" ]
  [ -d "$h/.agents/skills" ] && [ ! -L "$h/.agents/skills" ]
  while IFS= read -r name; do
    seen=$((seen + 1))
    if [ ! -L "$h/.claude/skills/$name" ] && [ ! -L "$h/.agents/skills/$name" ]; then
      missing="$missing $name"
    fi
  done < <(git -C "$repo" ls-files .config/agents/skills | awk -F/ 'NF >= 5 { print $4 }' | sort -u)
  # 置き場所のパスを誤ると一覧の照合が空回りして通るので、skill を 1 つ以上見たことを確かめる
  [ "$seen" -gt 0 ]
  if [ -n "$missing" ]; then
    echo "add these skills to a list in link_agent_skills (lib/setup-common.sh):$missing"
    return 1
  fi
  for link in "$h/.claude/skills"/* "$h/.agents/skills"/*; do
    [ -L "$link" ] || continue
    [ -e "$link" ]
  done
}

@test "link_agent_skills: runs under /bin/bash" {
  [ -x /bin/bash ] || skip "no /bin/bash"
  run_link_agent_skills /bin/bash
  [ "$status" -eq 0 ]
  [[ "$output" != *"skill not found"* ]]
}

@test "link_agent_skills: shows git-commit, doc-conventions, and gh-ops to Codex" {
  run_link_agent_skills bash
  [ "$status" -eq 0 ]
  local h="$BATS_TEST_TMPDIR/home" name
  for name in doc-conventions gh-ops git-commit; do
    [ -L "$h/.agents/skills/$name" ]
    [ -f "$h/.agents/skills/$name/SKILL.md" ]
  done
}

# --- refuse_linked_worktree ---

make_primary_and_worktree() {
  git init -q "$BATS_TEST_TMPDIR/primary"
  git -C "$BATS_TEST_TMPDIR/primary" -c user.name=t -c user.email=t@example.com \
    commit -q --allow-empty -m init
  git -C "$BATS_TEST_TMPDIR/primary" worktree add -q "$BATS_TEST_TMPDIR/wt"
  PRIMARY_REAL=$(cd "$BATS_TEST_TMPDIR/primary" && pwd -P)
}

@test "refuse_linked_worktree: fails for a linked worktree and names the primary checkout" {
  make_primary_and_worktree
  cd "$BATS_TEST_TMPDIR"
  run refuse_linked_worktree "$BATS_TEST_TMPDIR/wt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"linked worktree"* ]]
  [[ "$output" == *"$PRIMARY_REAL"* ]]
}

@test "refuse_linked_worktree: passes for the primary checkout even when cwd is inside a linked worktree" {
  make_primary_and_worktree
  cd "$BATS_TEST_TMPDIR/wt"
  run refuse_linked_worktree "$BATS_TEST_TMPDIR/primary"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "refuse_linked_worktree: passes for the primary checkout reached through a symlink" {
  make_primary_and_worktree
  ln -s "$BATS_TEST_TMPDIR/primary" "$BATS_TEST_TMPDIR/link"
  run refuse_linked_worktree "$BATS_TEST_TMPDIR/link"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "refuse_linked_worktree: passes for a directory that is not a git checkout" {
  mkdir "$BATS_TEST_TMPDIR/plain"
  run refuse_linked_worktree "$BATS_TEST_TMPDIR/plain"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "refuse_linked_worktree: passes when git fails" {
  make_primary_and_worktree
  mkdir "$BATS_TEST_TMPDIR/bin"
  printf '#!/bin/sh\nexit 127\n' >"$BATS_TEST_TMPDIR/bin/git"
  chmod +x "$BATS_TEST_TMPDIR/bin/git"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run refuse_linked_worktree "$BATS_TEST_TMPDIR/wt"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "refuse_linked_worktree: fails for a linked worktree with a git that lacks --path-format" {
  make_primary_and_worktree
  local real_git
  real_git=$(command -v git)
  mkdir "$BATS_TEST_TMPDIR/bin"
  # git 2.31 より前は未知の --path-format をそのまま出力して 0 を返す。
  printf '#!/bin/sh\nfor a in "$@"; do case "$a" in --path-format=*) echo "$a"; exit 0 ;; esac; done\nexec "%s" "$@"\n' \
    "$real_git" >"$BATS_TEST_TMPDIR/bin/git"
  chmod +x "$BATS_TEST_TMPDIR/bin/git"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run refuse_linked_worktree "$BATS_TEST_TMPDIR/wt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"$PRIMARY_REAL"* ]]
}

@test "refuse_linked_worktree: ignores GIT_DIR and GIT_WORK_TREE from the environment" {
  make_primary_and_worktree
  GIT_DIR="$BATS_TEST_TMPDIR/primary/.git" GIT_WORK_TREE="$BATS_TEST_TMPDIR/primary" \
    run refuse_linked_worktree "$BATS_TEST_TMPDIR/wt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"linked worktree"* ]]
}

@test "refuse_linked_worktree: does not trip set -euo pipefail outside a checkout" {
  mkdir "$BATS_TEST_TMPDIR/plain"
  run bash -c 'set -euo pipefail; . "$1"; refuse_linked_worktree "$2"; echo reached' _ \
    "$BATS_TEST_DIRNAME/../lib/setup-common.sh" "$BATS_TEST_TMPDIR/plain"
  [ "$status" -eq 0 ]
  [[ "$output" == *reached* ]]
}

@test "setup scripts: call refuse_linked_worktree right after sourcing setup-common.sh" {
  local count=0 f next
  for f in "$BATS_TEST_DIRNAME"/../setup_*.sh; do
    echo "$f"
    next=$(awk 'f && !/^[[:space:]]*(#|$)/ {gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print; exit} /^\. "\$SCRIPT_DIR\/lib\/setup-common.sh"/ {f=1}' "$f")
    [ "$next" = 'refuse_linked_worktree "$SCRIPT_DIR" || exit 1' ]
    count=$((count + 1))
  done
  [ "$count" -ge 3 ]
}

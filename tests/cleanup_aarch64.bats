#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  CLEANUP="$BATS_TEST_DIRNAME/../cleanup_aarch64.sh"
  TEST_HOME="$BATS_TEST_TMPDIR/home"
  STUB_BIN="$BATS_TEST_TMPDIR/bin"
  SYS_BIN="$BATS_TEST_TMPDIR/sys"
  STUB_LOG="$BATS_TEST_TMPDIR/stub.log"
  STAMP="$TEST_HOME/.local/state/dotfiles/cleanup-aarch64-weekly"
  mkdir -p "$STUB_BIN" "$SYS_BIN"
  : >"$STUB_LOG"

  cat >"$STUB_BIN/stub" <<'STUB'
#!/bin/bash
name=$(basename "$0")
echo "$name $*" >>"$STUB_LOG"
echo "$name $* @ $PWD" >>"$STUB_LOG.pwd"
case "$name $*" in "${STUB_FAIL:-<none>}"*) exit 1 ;; esac
exit 0
STUB
  chmod +x "$STUB_BIN/stub"
  for c in docker uv df sudo mise; do
    ln -s stub "$STUB_BIN/$c"
  done

  cat >"$STUB_BIN/flock" <<'STUB'
#!/bin/bash
echo "flock $*" >>"$STUB_LOG"
exit "${STUB_FLOCK_RC:-0}"
STUB
  chmod +x "$STUB_BIN/flock"

  # PATH に /usr/bin を入れると本物の docker や uv に届くので、必要な実コマンドだけを置く
  for c in cat date dirname mkdir rm basename flock; do
    if command -v "$c" >/dev/null 2>&1; then
      ln -s "$(command -v "$c")" "$SYS_BIN/$c"
    fi
  done

  for d in .npm/_cacache .npm/_npx .cache/npm/_cacache .cache/npm/_npx \
    .cache/uv .cache/ms-playwright/chromium-1 .cache/mise .cache/huggingface/hub; do
    mkdir -p "$TEST_HOME/$d"
  done
  : >"$TEST_HOME/.cache/uv/.lock"
  : >"$TEST_HOME/.cache/ms-playwright/chromium-1/chrome"
  : >"$TEST_HOME/.cache/mise/keep"
  : >"$TEST_HOME/.cache/huggingface/hub/model"
}

run_cleanup() {
  run --separate-stderr env -i HOME="$TEST_HOME" PATH="$STUB_BIN:$SYS_BIN" \
    STUB_LOG="$STUB_LOG" "$@" /bin/bash "$CLEANUP"
}

write_stamp() {
  mkdir -p "$(dirname "$STAMP")"
  echo "$1" >"$STAMP"
}

line_of() {
  grep -n "^$1" "$STUB_LOG" | head -n 1 | cut -d: -f1
}

assert_untouchables_remain() {
  [ -e "$TEST_HOME/.cache/ms-playwright/chromium-1/chrome" ]
  [ -e "$TEST_HOME/.cache/mise/keep" ]
  [ -e "$TEST_HOME/.cache/huggingface/hub/model" ]
}

@test "cleanup_aarch64.sh: image prune runs first and every run" {
  write_stamp "$(($(date +%s) - 86400))"
  run_cleanup
  [ "$status" -eq 0 ]
  [ "$(sed -n 1p "$STUB_LOG" | cut -d' ' -f1)" = df ]
  [ "$(sed -n 2p "$STUB_LOG")" = "docker image prune --force" ]
  [ "$(tail -n 1 "$STUB_LOG" | cut -d' ' -f1)" = df ]
  ! grep -qE "^docker image prune.* (--all|-a)( |$)" "$STUB_LOG" || false
  ! grep -q "^docker builder prune" "$STUB_LOG" || false
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  ! grep -q "^flock" "$STUB_LOG" || false
  [ -d "$TEST_HOME/.npm/_cacache" ]
  [[ "$output" == *"Free space before:"*"Free space after:"* ]]
}

@test "cleanup_aarch64.sh: never calls sudo or mise" {
  run_cleanup
  [ "$status" -eq 0 ]
  ! grep -qE "^(sudo|mise) " "$STUB_LOG" || false
}

@test "cleanup_aarch64.sh: no stamp runs weekly cleanup in order and records success" {
  run_cleanup
  [ "$status" -eq 0 ]
  [ "$(line_of 'docker image prune --force$')" -lt "$(line_of 'docker builder prune --all --force$')" ]
  [ "$(line_of 'docker builder prune --all --force$')" -lt "$(line_of "uv cache prune --cache-dir $TEST_HOME/.cache/uv\$")" ]
  grep -qx "flock -n -E 75 $TEST_HOME/.cache/uv/.lock true" "$STUB_LOG"
  ! grep "^uv cache prune" "$STUB_LOG" | grep -q -- --force || false
  [ ! -e "$TEST_HOME/.npm/_cacache" ]
  [ ! -e "$TEST_HOME/.cache/npm/_cacache" ]
  [ -d "$TEST_HOME/.npm/_npx" ]
  [ -d "$TEST_HOME/.cache/npm/_npx" ]
  assert_untouchables_remain
  [[ "$(cat "$STAMP")" =~ ^[0-9]+$ ]]
}

@test "cleanup_aarch64.sh: stamp 7 days old runs weekly cleanup" {
  old=$(($(date +%s) - 7 * 86400))
  write_stamp "$old"
  run_cleanup
  [ "$status" -eq 0 ]
  grep -q "^docker builder prune" "$STUB_LOG"
  [ "$(cat "$STAMP")" -gt "$old" ]
}

@test "cleanup_aarch64.sh: corrupt stamp runs weekly cleanup" {
  write_stamp "abc"
  run_cleanup
  [ "$status" -eq 0 ]
  grep -q "^docker builder prune" "$STUB_LOG"
}

@test "cleanup_aarch64.sh: stamp with a leading zero runs weekly cleanup" {
  write_stamp "0$(date +%s)"
  run_cleanup
  [ "$status" -eq 0 ]
  grep -q "^docker builder prune" "$STUB_LOG"
}

@test "cleanup_aarch64.sh: tools run from HOME regardless of the caller's directory" {
  mkdir -p "$BATS_TEST_TMPDIR/project"
  cd "$BATS_TEST_TMPDIR/project"
  run_cleanup
  [ "$status" -eq 0 ]
  [ -s "$STUB_LOG.pwd" ]
  ! grep -qv " @ $TEST_HOME\$" "$STUB_LOG.pwd" || false
}

@test "cleanup_aarch64.sh: every-run failure stops the script" {
  write_stamp "$(($(date +%s) - 8 * 86400))"
  old=$(cat "$STAMP")
  run_cleanup STUB_FAIL="docker image prune"
  [ "$status" -ne 0 ]
  grep -qx "docker image prune --force" "$STUB_LOG"
  ! grep -q "^docker builder prune" "$STUB_LOG" || false
  [ "$(cat "$STAMP")" = "$old" ]
  [[ "$output" != *"Free space after:"* ]]
}

@test "cleanup_aarch64.sh: weekly failure keeps the stamp and stops" {
  write_stamp "$(($(date +%s) - 8 * 86400))"
  old=$(cat "$STAMP")
  run_cleanup STUB_FAIL="docker builder prune"
  [ "$status" -ne 0 ]
  grep -qx "docker builder prune --all --force" "$STUB_LOG"
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  [ -d "$TEST_HOME/.npm/_cacache" ]
  [ "$(cat "$STAMP")" = "$old" ]
}

@test "cleanup_aarch64.sh: uv failure keeps the stamp" {
  run_cleanup STUB_FAIL="uv cache prune"
  [ "$status" -ne 0 ]
  grep -qx "uv cache prune --cache-dir $TEST_HOME/.cache/uv" "$STUB_LOG"
  [ ! -e "$STAMP" ]
}

@test "cleanup_aarch64.sh: busy uv cache skips uv only and still records success" {
  write_stamp "$(($(date +%s) - 8 * 86400))"
  old=$(cat "$STAMP")
  run_cleanup STUB_FLOCK_RC=75
  [ "$status" -eq 0 ]
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  grep -qx "docker builder prune --all --force" "$STUB_LOG"
  [ ! -e "$TEST_HOME/.npm/_cacache" ]
  [ "$(cat "$STAMP")" -gt "$old" ]
  [[ "$stderr" == *"warning: uv cache is in use; skipped uv cache prune"* ]]
  [[ "$output" != *"warning: uv cache is in use"* ]]
}

@test "cleanup_aarch64.sh: flock error other than conflict stops and keeps the stamp" {
  write_stamp "$(($(date +%s) - 8 * 86400))"
  old=$(cat "$STAMP")
  run_cleanup STUB_FLOCK_RC=1
  [ "$status" -ne 0 ]
  grep -qx "flock -n -E 75 $TEST_HOME/.cache/uv/.lock true" "$STUB_LOG"
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  [ "$(cat "$STAMP")" = "$old" ]
}

@test "cleanup_aarch64.sh: missing uv lock file goes straight to prune without creating it" {
  rm "$TEST_HOME/.cache/uv/.lock"
  run_cleanup
  [ "$status" -eq 0 ]
  ! grep -q "^flock" "$STUB_LOG" || false
  grep -q "^uv cache prune" "$STUB_LOG"
  [ ! -e "$TEST_HOME/.cache/uv/.lock" ]
}

@test "cleanup_aarch64.sh: missing targets are skipped and not created" {
  rm -rf "$TEST_HOME/.npm" "$TEST_HOME/.cache/npm" "$TEST_HOME/.cache/uv"
  run_cleanup
  [ "$status" -eq 0 ]
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  ! grep -q "^flock" "$STUB_LOG" || false
  [ ! -e "$TEST_HOME/.npm" ]
  [ ! -e "$TEST_HOME/.cache/npm" ]
  [ ! -e "$TEST_HOME/.cache/uv" ]
  [ -f "$STAMP" ]
}

@test "cleanup_aarch64.sh: missing tools are skipped" {
  rm "$STUB_BIN/docker" "$STUB_BIN/uv"
  run_cleanup
  [ "$status" -eq 0 ]
  ! grep -qE "^(docker|uv) " "$STUB_LOG" || false
  [ ! -e "$TEST_HOME/.npm/_cacache" ]
  [ -f "$STAMP" ]
}

@test "cleanup_aarch64.sh: inherited cache variables do not move targets" {
  mkdir -p "$BATS_TEST_TMPDIR/other/npm/_cacache" "$BATS_TEST_TMPDIR/other/uv"
  run_cleanup XDG_CACHE_HOME="$BATS_TEST_TMPDIR/other" \
    UV_CACHE_DIR="$BATS_TEST_TMPDIR/other/uv" npm_config_cache="$BATS_TEST_TMPDIR/other/npm"
  [ "$status" -eq 0 ]
  grep -qx "uv cache prune --cache-dir $TEST_HOME/.cache/uv" "$STUB_LOG"
  [ -d "$BATS_TEST_TMPDIR/other/npm/_cacache" ]
}

@test "cleanup_aarch64.sh: real flock: a held uv lock skips uv only" {
  command -v flock >/dev/null || skip "flock is not installed"
  rm "$STUB_BIN/flock"
  exec 9>"$TEST_HOME/.cache/uv/.lock"
  flock -x 9
  write_stamp "$(($(date +%s) - 8 * 86400))"
  run_cleanup
  exec 9>&-
  [ "$status" -eq 0 ]
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  [[ "$stderr" == *"warning: uv cache is in use"* ]]
}

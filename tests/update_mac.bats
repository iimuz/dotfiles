#!/usr/bin/env bats

setup() {
  UPDATE_MAC="$BATS_TEST_DIRNAME/../update_mac.sh"
  TEST_HOME="$BATS_TEST_TMPDIR/home"
  STUB_BIN="$BATS_TEST_TMPDIR/bin"
  STUB_LOG="$BATS_TEST_TMPDIR/stub.log"
  STAMP="$TEST_HOME/.local/state/dotfiles/update-mac-weekly-cleanup"
  mkdir -p "$STUB_BIN"
  : >"$STUB_LOG"

  cat >"$STUB_BIN/stub" <<'STUB'
#!/bin/bash
name=$(basename "$0")
echo "$name $* MISE_CACHE_DIR=${MISE_CACHE_DIR:-} GOMODCACHE=${GOMODCACHE:-}" >>"$STUB_LOG"
echo "$name $* @ $PWD" >>"$STUB_LOG.pwd"
case "$name $*" in "${STUB_FAIL:-<none>}"*) exit 1 ;; esac
exit 0
STUB
  chmod +x "$STUB_BIN/stub"
  for c in brew mise uv npm go df; do
    ln -s stub "$STUB_BIN/$c"
  done

  for d in .cache/uv .cache/npm-arm64/_cacache .cache/npm-arm64/_npx \
    .npm/_cacache .npm/_npx .cache/mise Library/Caches/mise go/pkg/mod \
    .local/share/pnpm/store/v11 .local/share/pnpm/store/v10 \
    Library/pnpm/store/v11 .cache/pnpm Library/Caches/pnpm \
    Library/Caches/gopls Library/Caches/goimports Library/Caches/node-gyp \
    Library/Caches/golangci-lint Library/Caches/dprint .cache/pip \
    .cache/qmd .cache/huggingface/hub .cache/gh Library/Caches/com.example.app; do
    mkdir -p "$TEST_HOME/$d"
  done
  : >"$TEST_HOME/.cache/qmd/index.sqlite"
  : >"$TEST_HOME/.cache/huggingface/hub/model"
  : >"$TEST_HOME/.cache/gh/cache"
  : >"$TEST_HOME/Library/Caches/com.example.app/state"
}

run_update() {
  run env -i HOME="$TEST_HOME" PATH="$STUB_BIN:/usr/bin:/bin" \
    STUB_LOG="$STUB_LOG" "$@" /bin/bash "$UPDATE_MAC"
}

write_stamp() {
  mkdir -p "$(dirname "$STAMP")"
  echo "$1" >"$STAMP"
}

line_of() {
  grep -n "^$1" "$STUB_LOG" | head -n 1 | cut -d: -f1
}

@test "update_mac.sh: runs updates and every-run cleanup in order" {
  write_stamp "$(($(date +%s) - 86400))"
  run_update
  [ "$status" -eq 0 ]
  [ "$(sed -n 1p "$STUB_LOG" | cut -d' ' -f1)" = df ]
  [ "$(line_of 'brew update ')" -lt "$(line_of 'brew upgrade ')" ]
  [ "$(line_of 'brew upgrade ')" -lt "$(line_of 'brew bundle cleanup ')" ]
  [ "$(line_of 'brew bundle cleanup ')" -lt "$(line_of 'mise exec -- gh extension upgrade ')" ]
  [ "$(line_of 'mise exec -- gh extension upgrade ')" -lt "$(line_of 'mise prune -y ')" ]
  [ "$(line_of 'mise prune -y ')" -lt "$(line_of 'uv cache prune ')" ]
  [ "$(line_of 'uv cache prune ')" -lt "$(line_of "npm cache verify --cache $TEST_HOME/.cache/npm-arm64 ")" ]
  [ "$(line_of 'uv cache prune ')" -lt "$(line_of "npm cache verify --cache $TEST_HOME/.npm ")" ]
  [ "$(tail -n 1 "$STUB_LOG" | cut -d' ' -f1)" = df ]
  grep -qx "brew update MISE_CACHE_DIR= GOMODCACHE=" "$STUB_LOG"
  grep -qx "brew upgrade MISE_CACHE_DIR= GOMODCACHE=" "$STUB_LOG"
  grep -q "^brew bundle cleanup --force --no-mas --file=.*/.config/homebrew/Brewfile " "$STUB_LOG"
  grep -q "^mise exec -- gh extension upgrade --all " "$STUB_LOG"
  grep -q "^mise prune -y " "$STUB_LOG"
  grep -q "^uv cache prune --cache-dir $TEST_HOME/.cache/uv " "$STUB_LOG"
  grep -q "^npm cache verify --cache $TEST_HOME/.cache/npm-arm64 " "$STUB_LOG"
  grep -q "^npm cache verify --cache $TEST_HOME/.npm " "$STUB_LOG"
  [[ "$output" == *"Free space before:"*"Free space after:"* ]]
  ! grep -q "^mise cache clean" "$STUB_LOG" || false
  ! grep -qE "^mise (self-update|install|upgrade)" "$STUB_LOG" || false
}

@test "update_mac.sh: tools run from HOME regardless of the caller's directory" {
  write_stamp "$(date +%s)"
  mkdir -p "$BATS_TEST_TMPDIR/project"
  cd "$BATS_TEST_TMPDIR/project"
  run_update
  [ "$status" -eq 0 ]
  ! grep -v "^mise exec -- gh " "$STUB_LOG.pwd" | grep -qv " @ $TEST_HOME\$" || false
}

@test "update_mac.sh: gh extension upgrade runs in the repository" {
  write_stamp "$(date +%s)"
  repo="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run_update
  [ "$status" -eq 0 ]
  grep -qx "mise exec -- gh extension upgrade --all @ $repo" "$STUB_LOG.pwd"
}

@test "update_mac.sh: every-run failure stops the script" {
  write_stamp "$(($(date +%s) - 86400))"
  run_update STUB_FAIL="uv cache prune"
  [ "$status" -ne 0 ]
  ! grep -q "^npm cache verify" "$STUB_LOG" || false
  [[ "$output" != *"Free space after:"* ]]
}

@test "update_mac.sh: missing targets are skipped and not created (every-run)" {
  write_stamp "$(($(date +%s) - 86400))"
  rm -rf "$TEST_HOME/.npm" "$TEST_HOME/.cache/uv"
  run_update
  [ "$status" -eq 0 ]
  ! grep -q "cache verify --cache $TEST_HOME/.npm " "$STUB_LOG" || false
  ! grep -q "^uv cache prune" "$STUB_LOG" || false
  [ ! -e "$TEST_HOME/.npm" ]
}

@test "update_mac.sh: brewfile path resolves from script location" {
  write_stamp "$(($(date +%s) - 86400))"
  cd "$BATS_TEST_TMPDIR"
  run_update
  [ "$status" -eq 0 ]
  brewfile=$(sed -n 's/^brew bundle cleanup .*--file=\([^ ]*\) .*/\1/p' "$STUB_LOG")
  [ -f "$brewfile" ]
}

assert_weekly_ran() {
  grep -q "^uv cache clean --cache-dir $TEST_HOME/.cache/uv " "$STUB_LOG"
  grep -q "^go clean -modcache .*GOMODCACHE=$TEST_HOME/go/pkg/mod$" "$STUB_LOG"
  grep -q "^mise cache clear MISE_CACHE_DIR=$TEST_HOME/.cache/mise " "$STUB_LOG"
  grep -q "^mise cache clear MISE_CACHE_DIR=$TEST_HOME/Library/Caches/mise " "$STUB_LOG"
  for p in .local/share/pnpm/store Library/pnpm/store .cache/pnpm Library/Caches/pnpm \
    .cache/npm-arm64/_cacache .cache/npm-arm64/_npx .npm/_cacache .npm/_npx \
    Library/Caches/gopls Library/Caches/goimports Library/Caches/node-gyp \
    Library/Caches/golangci-lint Library/Caches/dprint .cache/pip; do
    [ ! -e "$TEST_HOME/$p" ] || {
      echo "not removed: $p"
      return 1
    }
  done
}

assert_untouched_survive() {
  [ -f "$TEST_HOME/.cache/qmd/index.sqlite" ]
  [ -e "$TEST_HOME/.cache/huggingface/hub/model" ]
  [ -e "$TEST_HOME/.cache/gh/cache" ]
  [ -e "$TEST_HOME/Library/Caches/com.example.app/state" ]
}

@test "update_mac.sh: no stamp runs weekly cleanup and records success" {
  run_update
  [ "$status" -eq 0 ]
  assert_weekly_ran
  assert_untouched_survive
  [[ "$(cat "$STAMP")" =~ ^[0-9]+$ ]]
  [ "$(line_of "npm cache verify --cache $TEST_HOME/.npm ")" -lt "$(line_of 'go clean ')" ]
  [ "$(line_of 'go clean ')" -lt "$(line_of 'uv cache clean ')" ]
}

@test "update_mac.sh: fresh stamp skips weekly cleanup" {
  write_stamp "$(($(date +%s) - 86400))"
  run_update
  [ "$status" -eq 0 ]
  ! grep -q "^uv cache clean" "$STUB_LOG" || false
  ! grep -q "^go clean" "$STUB_LOG" || false
  ! grep -q "^mise cache clear" "$STUB_LOG" || false
  [ -d "$TEST_HOME/.local/share/pnpm/store/v11" ]
  [ -d "$TEST_HOME/.npm/_cacache" ]
  grep -q "^uv cache prune" "$STUB_LOG"
}

@test "update_mac.sh: stamp 7 days old runs weekly cleanup" {
  old=$(($(date +%s) - 7 * 86400))
  write_stamp "$old"
  run_update
  [ "$status" -eq 0 ]
  assert_weekly_ran
  [ "$(cat "$STAMP")" -gt "$old" ]
}

@test "update_mac.sh: weekly failure keeps the stamp and stops" {
  old=$(($(date +%s) - 8 * 86400))
  write_stamp "$old"
  run_update STUB_FAIL="go clean"
  [ "$status" -ne 0 ]
  [ "$(cat "$STAMP")" = "$old" ]
  [[ "$output" != *"Free space after:"* ]]
}

@test "update_mac.sh: weekly failure without stamp leaves no stamp" {
  run_update STUB_FAIL="uv cache clean"
  [ "$status" -ne 0 ]
  [ ! -e "$STAMP" ]
}

@test "update_mac.sh: corrupt stamp runs weekly cleanup" {
  write_stamp "not-a-number"
  run_update
  [ "$status" -eq 0 ]
  assert_weekly_ran
}

@test "update_mac.sh: stamp with a leading zero runs weekly cleanup" {
  write_stamp "0899"
  run_update
  [ "$status" -eq 0 ]
  assert_weekly_ran
}

@test "update_mac.sh: missing targets are skipped and not created (weekly)" {
  rm -rf "$TEST_HOME/go" "$TEST_HOME/Library/Caches/mise" "$TEST_HOME/.npm" "$TEST_HOME/.cache/uv"
  run_update
  [ "$status" -eq 0 ]
  ! grep -q "^go clean" "$STUB_LOG" || false
  ! grep -q "MISE_CACHE_DIR=$TEST_HOME/Library/Caches/mise" "$STUB_LOG" || false
  ! grep -q "^uv cache clean" "$STUB_LOG" || false
  [ ! -e "$TEST_HOME/go" ]
  [ ! -e "$TEST_HOME/.npm" ]
  [ ! -e "$TEST_HOME/.cache/uv" ]
  [ -e "$STAMP" ]
}

@test "update_mac.sh: inherited cache variables do not move targets" {
  other="$BATS_TEST_TMPDIR/other"
  mkdir -p "$other/pnpm" "$other/keep"
  run_update XDG_CACHE_HOME="$other" XDG_DATA_HOME="$other" GOMODCACHE="$other/mod" \
    UV_CACHE_DIR="$other/uv" MISE_CACHE_DIR="$other/mise" GOPATH="$other"
  [ "$status" -eq 0 ]
  assert_weekly_ran
  [ -d "$other/pnpm" ]
  [ -d "$other/keep" ]
  ! grep '^go clean' "$STUB_LOG" | grep -q "GOMODCACHE=$other" || false
  ! grep '^mise cache clear' "$STUB_LOG" | grep -q "MISE_CACHE_DIR=$other" || false
  ! grep -E '^(uv|npm) ' "$STUB_LOG" | grep -qE "(--cache-dir|--cache) $other" || false
}

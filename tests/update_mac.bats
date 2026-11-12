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

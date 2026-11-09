#!/usr/bin/env bats

# Tests for .config/git/credential-gh-helper.

HELPER="$BATS_TEST_DIRNAME/../.config/git/credential-gh-helper"

setup() {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/pass" <<STUB
#!/bin/bash
echo "\$@" >> "$BATS_TEST_TMPDIR/pass.log"
echo pass-token
STUB
  cat >"$stub_bin/gh" <<STUB
#!/bin/bash
echo "ARGS=\$*" > "$BATS_TEST_TMPDIR/gh.log"
echo "GH_TOKEN=\${GH_TOKEN-}" >> "$BATS_TEST_TMPDIR/gh.log"
STUB
  chmod +x "$stub_bin"/*
  PATH="$stub_bin:$PATH"
}

@test "credential-gh-helper: forwards args to gh auth git-credential" {
  run env -u GH_TOKEN "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ "$(sed -n 1p "$BATS_TEST_TMPDIR/gh.log")" = "ARGS=auth git-credential get" ]
}

@test "credential-gh-helper: passes GH_TOKEN through unchanged" {
  run env GH_TOKEN=env-token "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ "$(sed -n 2p "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=env-token" ]
}

@test "credential-gh-helper: never invokes pass" {
  run env -u GH_TOKEN -u GH_CONFIG_DIR "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/pass.log" ]
  [ "$(sed -n 2p "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=" ]
}

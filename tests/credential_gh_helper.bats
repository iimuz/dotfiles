#!/usr/bin/env bats

# Tests for .config/git/credential-gh-helper pass fallback.

HELPER="$BATS_TEST_DIRNAME/../.config/git/credential-gh-helper"

setup() {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/uname" <<'STUB'
#!/bin/bash
echo "${STUB_UNAME:-Linux}"
STUB
  cat >"$stub_bin/pass" <<STUB
#!/bin/bash
echo "\$@" >> "$BATS_TEST_TMPDIR/pass.log"
echo pass-token
STUB
  # `gh auth token` fails as in a gh config dir that holds no token.
  cat >"$stub_bin/gh" <<STUB
#!/bin/bash
if [ "\$1 \$2" = "auth token" ]; then
  exit 1
fi
echo "GH_TOKEN=\${GH_TOKEN-}" > "$BATS_TEST_TMPDIR/gh.log"
STUB
  chmod +x "$stub_bin"/*
  PATH="$stub_bin:$PATH"
}

@test "credential-gh-helper: skips pass in the bot gh config dir without a token" {
  run env -u GH_TOKEN GH_CONFIG_DIR="$HOME/.config/gh-agent" "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/pass.log" ]
  [ "$(cat "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=" ]
}

@test "credential-gh-helper: uses pass without GH_CONFIG_DIR" {
  run env -u GH_TOKEN -u GH_CONFIG_DIR "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ -e "$BATS_TEST_TMPDIR/pass.log" ]
  [ "$(cat "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=pass-token" ]
}

@test "credential-gh-helper: uses pass in another gh config dir" {
  run env -u GH_TOKEN GH_CONFIG_DIR="$BATS_TEST_TMPDIR/gh-human" "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ -e "$BATS_TEST_TMPDIR/pass.log" ]
  [ "$(cat "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=pass-token" ]
}

@test "credential-gh-helper: skips pass when GH_TOKEN is set" {
  run env -u GH_CONFIG_DIR GH_TOKEN=env-token "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/pass.log" ]
  [ "$(cat "$BATS_TEST_TMPDIR/gh.log")" = "GH_TOKEN=env-token" ]
}

@test "credential-gh-helper: skips pass outside Linux" {
  run env -u GH_TOKEN -u GH_CONFIG_DIR STUB_UNAME=Darwin "$HELPER" get </dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/pass.log" ]
}

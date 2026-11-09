#!/usr/bin/env bats

# Tests for the GH_CONFIG_DIR_PERSONAL line in .config/mise/config-mac.toml.

bats_require_minimum_version 1.5.0

setup() {
  local line
  line="$(grep '^GH_CONFIG_DIR_PERSONAL = ' "$BATS_TEST_DIRNAME/../.config/mise/config-mac.toml")"
  [ -n "$line" ]
  PROJ="$BATS_TEST_TMPDIR/proj"
  mkdir -p "$PROJ"
  printf '[env]\n%s\n' "$line" >"$PROJ/mise.toml"
  export MISE_TRUSTED_CONFIG_PATHS="$PROJ"
  cd "$PROJ"
}

personal() {
  run --separate-stderr env "$@" mise exec -- sh -c 'printf "[%s]" "${GH_CONFIG_DIR_PERSONAL-unset}"'
}

@test "config-mac GH_CONFIG_DIR_PERSONAL: defaults to ~/.config/gh-personal" {
  personal -u GH_CONFIG_DIR_PERSONAL
  [ "$status" -eq 0 ]
  [ "$output" = "[$HOME/.config/gh-personal]" ]
}

@test "config-mac GH_CONFIG_DIR_PERSONAL: keeps an inherited value" {
  personal GH_CONFIG_DIR_PERSONAL=/agent
  [ "$status" -eq 0 ]
  [ "$output" = "[/agent]" ]
}

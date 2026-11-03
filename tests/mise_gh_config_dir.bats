#!/usr/bin/env bats

# Tests for the GH_CONFIG_DIR line in mise.toml.

bats_require_minimum_version 1.5.0

setup() {
  local line
  line="$(grep '^GH_CONFIG_DIR = ' "$BATS_TEST_DIRNAME/../mise.toml")"
  [ -n "$line" ]
  PROJ="$BATS_TEST_TMPDIR/proj"
  mkdir -p "$PROJ"
  printf '[env]\n_.file = ".env"\n%s\n' "$line" >"$PROJ/mise.toml"
  export MISE_TRUSTED_CONFIG_PATHS="$PROJ"
  cd "$PROJ"
}

gh_config_dir() {
  run --separate-stderr env "$@" mise exec -- sh -c 'printf "[%s]" "${GH_CONFIG_DIR-unset}"'
}

@test "mise GH_CONFIG_DIR: empty without .env, inherited value, or PERSONAL" {
  gh_config_dir -u GH_CONFIG_DIR -u GH_CONFIG_DIR_PERSONAL
  [ "$status" -eq 0 ]
  [ "$output" = "[]" ]
}

@test "mise GH_CONFIG_DIR: keeps the inherited value without .env or PERSONAL" {
  gh_config_dir -u GH_CONFIG_DIR_PERSONAL GH_CONFIG_DIR=/inherited
  [ "$status" -eq 0 ]
  [ "$output" = "[/inherited]" ]
}

@test "mise GH_CONFIG_DIR: .env wins over the inherited value without PERSONAL" {
  echo "GH_CONFIG_DIR=/dotenv" >"$PROJ/.env"
  gh_config_dir -u GH_CONFIG_DIR_PERSONAL GH_CONFIG_DIR=/inherited
  [ "$status" -eq 0 ]
  [ "$output" = "[/dotenv]" ]
}

@test "mise GH_CONFIG_DIR: PERSONAL wins over .env and the inherited value" {
  echo "GH_CONFIG_DIR=/dotenv" >"$PROJ/.env"
  gh_config_dir GH_CONFIG_DIR=/inherited GH_CONFIG_DIR_PERSONAL=/agent
  [ "$status" -eq 0 ]
  [ "$output" = "[/agent]" ]
}

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

@test "mise GH_CONFIG_DIR: empty without .env, inherited value, or AGENT" {
  gh_config_dir -u GH_CONFIG_DIR -u GH_CONFIG_DIR_AGENT
  [ "$status" -eq 0 ]
  [ "$output" = "[]" ]
}

@test "mise GH_CONFIG_DIR: keeps the inherited value without .env or AGENT" {
  gh_config_dir -u GH_CONFIG_DIR_AGENT GH_CONFIG_DIR=/inherited
  [ "$status" -eq 0 ]
  [ "$output" = "[/inherited]" ]
}

@test "mise GH_CONFIG_DIR: .env wins over the inherited value without AGENT" {
  echo "GH_CONFIG_DIR=/dotenv" >"$PROJ/.env"
  gh_config_dir -u GH_CONFIG_DIR_AGENT GH_CONFIG_DIR=/inherited
  [ "$status" -eq 0 ]
  [ "$output" = "[/dotenv]" ]
}

@test "mise GH_CONFIG_DIR: AGENT wins over .env and the inherited value" {
  echo "GH_CONFIG_DIR=/dotenv" >"$PROJ/.env"
  gh_config_dir GH_CONFIG_DIR=/inherited GH_CONFIG_DIR_AGENT=/agent
  [ "$status" -eq 0 ]
  [ "$output" = "[/agent]" ]
}

@test "mise GH_CONFIG_DIR: ignores GH_CONFIG_DIR_PERSONAL" {
  gh_config_dir -u GH_CONFIG_DIR_AGENT GH_CONFIG_DIR=/inherited GH_CONFIG_DIR_PERSONAL=/personal
  [ "$status" -eq 0 ]
  [ "$output" = "[/inherited]" ]
}

@test "mise GH_CONFIG_DIR: mise.toml reads .env before the GH_CONFIG_DIR line" {
  local toml="$BATS_TEST_DIRNAME/../mise.toml" dotenv line
  dotenv="$(grep -n '^_.file = ".env"' "$toml" | cut -d: -f1)"
  line="$(grep -n '^GH_CONFIG_DIR = ' "$toml" | cut -d: -f1)"
  [ -n "$dotenv" ]
  [ "$dotenv" -lt "$line" ]
}

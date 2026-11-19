#!/usr/bin/env bats

# Tests for .config/codex/rules/dotfiles.rules.

RULES="$BATS_TEST_DIRNAME/../.config/codex/rules/dotfiles.rules"

setup() {
  command -v codex >/dev/null 2>&1 || skip "codex is not installed"
}

assert_forbidden() {
  run codex execpolicy check --rules "$RULES" "$@"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"decision":"forbidden"'* ]]
}

assert_unmatched() {
  run codex execpolicy check --rules "$RULES" "$@"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"matchedRules":[]'* ]]
}

@test "rules: forbid reading credentials" {
  assert_forbidden gh auth token
  assert_forbidden gh auth token --hostname github.com
  assert_forbidden mise exec -- gh auth token
  assert_forbidden security find-generic-password -s x
  assert_forbidden pass
  assert_forbidden pass show x
  assert_forbidden gpg --decrypt x
}

@test "rules: forbid destructive git and gh commands" {
  assert_forbidden git push --force origin x
  assert_forbidden git push -f origin x
  assert_forbidden git rebase main
  assert_forbidden git reset --hard
  assert_forbidden gh pr merge 1
  assert_forbidden mise exec -- gh pr merge 1
}

@test "rules: forbid forced removal and sudo" {
  assert_forbidden rm -f x
  assert_forbidden rm -rf x
  assert_forbidden sudo ls
}

@test "rules: leave similar everyday commands alone" {
  assert_unmatched git push origin main
  assert_unmatched rm x
  assert_unmatched gh auth status
  assert_unmatched gh pr view 1
  assert_unmatched mise exec -- gh pr view 1
}

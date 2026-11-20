#!/usr/bin/env bats

# Tests for .config/codex/rules/dotfiles.rules.

RULES="$BATS_TEST_DIRNAME/../.config/codex/rules/dotfiles.rules"
SETTINGS="$BATS_TEST_DIRNAME/../.config/claude/settings.json"

setup() {
  command -v codex >/dev/null 2>&1 || skip "codex is not installed"
}

assert_forbidden() {
  run codex execpolicy check --rules "$RULES" "$@"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.decision' <<<"$output")" = forbidden ]
}

assert_unmatched() {
  run codex execpolicy check --rules "$RULES" "$@"
  [ "$status" -eq 0 ]
  [ "$(jq '.matchedRules | length' <<<"$output")" -eq 0 ]
}

# settings.json に deny を足して rules に写し忘れたときに、ここで落ちる。
# pipe の形は rules に写さないので除き、末尾の " *" を落とした語の並びで判定させる。
@test "rules: forbid every Bash command the Claude Code settings deny" {
  local -a denies=() words
  local deny
  while IFS= read -r deny; do
    denies+=("$deny")
  done < <(jq -r '.permissions.deny[]
    | select(startswith("Bash(") and (contains("|") | not))
    | ltrimstr("Bash(") | rtrimstr(")") | rtrimstr(" *")' "$SETTINGS")
  [ "${#denies[@]}" -gt 0 ]
  for deny in "${denies[@]}"; do
    echo "checking: $deny"
    read -r -a words <<<"$deny"
    assert_forbidden "${words[@]}"
  done
}

@test "rules: forbid reading credentials" {
  assert_forbidden gh auth token
  assert_forbidden gh auth token --hostname github.com
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
}

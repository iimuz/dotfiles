#!/usr/bin/env bash
# Switches gh and git to the GitHub App bot for sessions in a repository under github.com/iimuz.
#
# gh-identity.sh          Claude Code SessionStart hook. Appends exports to CLAUDE_ENV_FILE.
# gh-identity.sh --print <dir>
#                         Prints the same exports to stdout, judged by the origin of <dir>.
#                         Ignores CLAUDE_ENV_FILE and CLAUDE_KEEP_GH_IDENTITY: the caller
#                         (agent-codex) asks for the bot identity by running this.

set -u

app_slug='iimuz-agent'
bot_name="${app_slug}[bot]"
bot_email="351267992+${bot_name}@users.noreply.github.com"
bot_gh_dir="$HOME/.config/gh-agent"

print_mode=0
if [ "${1:-}" = "--print" ]; then
  print_mode=1
  [ -n "${2:-}" ] || {
    echo "usage: gh-identity.sh --print <dir>" >&2
    exit 2
  }
  target_dir="$2"
else
  [ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0
  [ "${CLAUDE_KEEP_GH_IDENTITY:-}" = "1" ] && exit 0
  target_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
fi
[ -d "$bot_gh_dir" ] || exit 0

# An inherited GIT_CONFIG_COUNT that is non-numeric or lacks its KEY/VALUE pairs makes git abort.
origin="$(env -u GIT_CONFIG_COUNT git -C "$target_dir" remote get-url origin 2>/dev/null)" || exit 0
case "$origin" in
  https://github.com/iimuz/* | git@github.com:iimuz/* | ssh://git@github.com/iimuz/*) ;;
  *) exit 0 ;;
esac

n="${GIT_CONFIG_COUNT:-0}"
case "$n" in
  '' | *[!0-9]*) n=0 ;;
esac

# Pushes over ssh would use the human key; rewriting to https routes them through the bot token.
print_exports() {
  cat <<ENV
export GH_CONFIG_DIR='$bot_gh_dir'
export GH_CONFIG_DIR_AGENT='$bot_gh_dir'
export CLAUDE_GH_APP_SLUG='$app_slug'
export GIT_AUTHOR_NAME='$bot_name'
export GIT_AUTHOR_EMAIL='$bot_email'
export GIT_COMMITTER_NAME='$bot_name'
export GIT_COMMITTER_EMAIL='$bot_email'
export GIT_CONFIG_KEY_$n='url.https://github.com/iimuz/.insteadOf'
export GIT_CONFIG_VALUE_$n='git@github.com:iimuz/'
export GIT_CONFIG_KEY_$((n + 1))='url.https://github.com/iimuz/.insteadOf'
export GIT_CONFIG_VALUE_$((n + 1))='ssh://git@github.com/iimuz/'
export GIT_CONFIG_COUNT=$((n + 2))
unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
ENV
}

if [ "$print_mode" = 1 ]; then
  print_exports
else
  print_exports >>"$CLAUDE_ENV_FILE"
fi

exit 0

#!/usr/bin/env bash
# github.com/iimuz の下のリポジトリで、gh と git を GitHub App の bot の名義に切り替える。
#
# gh-identity.sh                Claude Code の SessionStart hook。export を CLAUDE_ENV_FILE に追記する。
# gh-identity.sh --print <dir>  <dir> の origin で判定し、同じ export を標準出力に出す。agent-codex が呼ぶ。
#                               agent-codex を通すこと自体が bot の名義を選ぶ操作なので、
#                               CLAUDE_ENV_FILE と CLAUDE_KEEP_GH_IDENTITY を読まない。

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
  # 名義を自分で決める launcher は、CLAUDE_KEEP_GH_IDENTITY=1 でこの hook を止める。
  # bot の名義で動く launcher は GH_CONFIG_DIR_AGENT も設定する。mise.toml が GH_CONFIG_DIR を GH_CONFIG_DIR_AGENT から解決するので、無いと mise exec -- gh は .env の GH_CONFIG_DIR を使う
  [ "${CLAUDE_KEEP_GH_IDENTITY:-}" = "1" ] && exit 0
  target_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
fi
[ -d "$bot_gh_dir" ] || exit 0

# 引き継いだ GIT_CONFIG_COUNT が数でないか、KEY と VALUE の組が欠けていると git が止まる。
origin="$(env -u GIT_CONFIG_COUNT git -C "$target_dir" remote get-url origin 2>/dev/null)" || exit 0
case "$origin" in
  https://github.com/iimuz/* | git@github.com:iimuz/* | ssh://git@github.com/iimuz/*) ;;
  *) exit 0 ;;
esac

n="${GIT_CONFIG_COUNT:-0}"
case "$n" in
  '' | *[!0-9]*) n=0 ;;
esac

# ssh の push は人の鍵を使うので、https に書き換えて bot の token を通す。
# CLAUDE_GH_APP_SLUG は、gh-ops が作った PR に App の owner のレビューを頼むときに読む。
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

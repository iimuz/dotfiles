#!/usr/bin/env bash
# エージェントの AWS_CONFIG_FILE を ~/.aws/agent/config (read-only のプロファイルだけ) に向け、
# 起動元のシェルの AWS のキーの環境変数を外す。
#
# aws-config.sh          Claude Code の SessionStart hook。export を CLAUDE_ENV_FILE に追記する。
# aws-config.sh --print  同じ export を標準出力に出す。agent-codex が呼ぶ。CLAUDE_ENV_FILE を読まない。
#
# gh-identity.sh と違って origin で絞らない。仕事のリポジトリで一番要るため。
# ファイルが無い端末でも向ける。無いときに全部入りの config へ黙って戻さないため。
# キーの環境変数を外すのは、キーを export したタブから起動しても developer 権限を渡さないため。

set -u

print_exports() {
  cat <<ENV
export AWS_CONFIG_FILE='$HOME/.aws/agent/config'
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_CREDENTIAL_EXPIRATION
ENV
}

if [ "${1:-}" = "--print" ]; then
  print_exports
else
  [ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0
  print_exports >>"$CLAUDE_ENV_FILE"
fi
exit 0

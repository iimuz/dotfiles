#!/bin/bash
#
# Claude code settings.

if ! type claude >/dev/null 2>&1; then return 0; fi

# Claude code の remote control を起動する
function claude_remote_control() {
  local name="${1:-$(basename "$PWD")}"

  claude remote-control \
    --name "$name" \
    --spawn worktree \
    --permission-mode auto \
    --no-create-session-in-dir
}

# Claude code の remote control で作成された worktree を削除する
#
# 自動で綺麗に消えないため定期的に削除しておく必要がある。
function claude_remote_cleanup() {
  echo "Cleaning up Claude Code session artifacts..."

  # ワークツリーの削除
  git worktree list | grep ".claude/worktrees" | awk '{print $1}' | while read -r wt_path; do
    echo "Removing worktree: $wt_path"
    # ここでは、 git lock も正常に開放されていないため強制的に削除
    git worktree remove -f -f "$wt_path"
  done

  # 残った bridge ブランチの削除
  git branch | grep "bridge-" | sed 's/*//g' | xargs -I {} sh -c "echo Removing branch: {}; git branch -D {}"

  # git の整合性をチェック
  git worktree prune
  echo "Cleanup complete."
}

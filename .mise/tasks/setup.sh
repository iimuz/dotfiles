#!/usr/bin/env bash
set -euo pipefail

# git worktree においては、ルートリポジトリ側で lefthook が設定されていればいいのでスキップ
if [ -d ".git" ]; then
  lefthook install
fi

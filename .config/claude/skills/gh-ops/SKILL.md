---
name: gh-ops
description: >-
  GitHub の Issue の作成、Issue へのコメント、draft PR の作成、PR へのレビューコメントの追加に使う。
---

# gh-ops

## 共通の約束事

- SKILL_DIR は、この SKILL.md があるディレクトリの絶対パスとする。Claude Code がこのファイルを読み込んだ
  パスから決める
- script は `bash "${SKILL_DIR}/scripts/<name>"` の形で、絶対パスで実行する
- script や `gh` が失敗したら、エラーをそのまま見せて止まる
- 本文はクォート付きの heredoc で標準入力に流し、`--body-file -` で渡す。本文に行頭が `EOF` だけの行が
  あるときは、区切り文字を本文に現れない別の語に変える
- タイトルはシングルクォートで囲み、シェルによる展開を避ける。タイトルに `'` を含むときは `'\''` に
  置き換える
- 本文で Issue や PR を参照するときは `#{number}` と書き、URL を使わない。他リポジトリのものは
  `{owner}/{repository}#{number}` と書く
- 本文の図は Mermaid で書く

## 操作ごとの手順

- Issue を作るときは [issue-create-rules.md](references/issue-create-rules.md) を読む
- Issue にコメントするときは [issue-comment-rules.md](references/issue-comment-rules.md) を読む
- PR を作るときは [pr-create-rules.md](references/pr-create-rules.md) を読む
- PR にレビューコメントを付けるときは [pr-review-rules.md](references/pr-review-rules.md) を読む

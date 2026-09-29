---
name: git-commit
description: >-
  コミットを頼まれたとき、plan のタスクを 1 つ終えたとき、まとまったコードの変更を 1 つ終えたときに、
  次の作業に移る前に使う。
---

# git-commit

## 目的

作業ツリーの変更から Conventional Commits 1.0.0 に沿ったメッセージを書き、コミットする。
コマンドはリポジトリのルートで実行する。

## 手順

1. stage する
   - `git diff --staged --name-only` で stage 済みのファイルを確かめる
   - 何も stage されていなければ、`git diff --name-only` で追跡中のファイルの変更を、
     `git ls-files --others --exclude-standard` で未追跡のファイルを挙げる。会話の文脈 (直前に終えたタスク)、
     パス、diff の中身からタスクに関係するファイルを選び、`git add <file>...` でそれだけを stage する
   - それでも何も stage されなければ、見つかった unstaged のファイルを挙げて止まる
2. メッセージを書く
   - `git --no-pager diff --staged` で diff を読む
   - [types.md](references/types.md) から type を 1 つ選ぶ
   - description は英語の命令形で書く。末尾にピリオドもカンマも付けず、ファイルパスだけにしない。
     type を含めて 100 字以内にする
   - 本文は任意で、`-` の箇条書きにする
3. コミットする
   - 下のテンプレートに沿ったメッセージを、クォート付きの heredoc で `git commit -F -` に渡す。
     本文に行頭が `EOF` だけの行があるときは、区切り文字を本文に現れない別の語に変える
   - 失敗したら、エラーをそのまま見せて止まる

## メッセージのテンプレート

`<...>` を中身に置き換える。本文が無ければ、`<body>` とその前の空行を消す。

```text
<type>: <description>

<body>
```

```bash
git commit -F - <<'EOF'
<テンプレートに沿って書いたメッセージ>
EOF
```

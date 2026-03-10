---
status: DONE
---

# TASK: pr-comment-skill

## Prompt

@docs/reports/2026-03-09-pr-review-skill-spec.md の内容に基づき @.config/copilot/skills に PR にドラフト状態のコメントを作成するスキルを新規に作成して。
期待する要求は下記の通り。

- PR へのコメントは Pending 状態で作成すること。
- 実際の投稿はユーザーが実施するためスキルとしては考慮する必要はない。
- コード修正提案がある場合は suggestion としてコメントにつけること。
- script で gh command をラップし、 gh command の細かい使い方は skill に記載しないこと。
  - script で必要な入力を説明し、動作はスクリプト側で調整すること。
- 既存スキルから呼び出す手順は追加不要。

/structured-workflow の手順で進めて。

## Goal

PR にドラフト状態のコメントを作成する draft-review スキルを新規作成する。

## Ref

- `.config/copilot/skills/draft-review/SKILL.md`
- `.config/copilot/skills/draft-review/scripts/create_review.py`
- `.config/copilot/skills/draft-review/scripts/create_review.sh`
- `.github/instructions/skills.instructions.md`

## Spec

### 背景

`code-review` スキルによるレビュー結果を GitHub PR に投稿する際、現在は個別のインラインコメントをそれぞれ独立して投稿している。これにより以下の問題がある。

- コメントが review としてまとまらず、通知がバラバラに飛ぶ
- ユーザーが最終確認・修正する前に投稿されてしまう（ドラフト不可）
- コード修正提案が suggestion ブロックとして表示されず、適用しにくい

### スキル 1: `draft-review`

目的: 複数のインラインコメントを GitHub の Pending（ドラフト）レビューとしてまとめて作成し、ユーザーが Web UI から Submit するまで投稿を保留する。

動作仕様:

1. `gh api repos/{owner}/{repo}/pulls/{number}/reviews` に `POST` する
2. `event` フィールドを省略することで `PENDING` 状態のレビューを作成する
3. `comments` 配列に全インラインコメントをまとめて渡す
4. レビュー全体のサマリーを `body` フィールドに含める
5. 作成された `review_id` を返す（ユーザーが Web で Submit するまで公開されない）

入力インターフェース:

```yaml
inputs:
  owner: string # リポジトリオーナー
  repo: string # リポジトリ名
  pull_number: integer # PR 番号
  summary_body: string # レビュー全体コメント（日本語）
  comments:
    - path: string # ファイルパス
      line: integer # 行番号（diff の絶対行）
      body: string # コメント本文（日本語、prefix 付き）
      suggestion: string # (optional) 提案コード本文
```

出力:

- `review_id`: 作成されたドラフトレビューの ID
- 投稿 URL

### スキル 2: `pr-review-suggestion`（`draft-review` に統合）

目的: コメント本文にコード修正提案を GitHub Suggestion ブロックとして埋め込む。

動作仕様:

- `comments[].suggestion` フィールドが存在する場合、コメント本文に suggestion ブロックを自動付加する
- suggestion は単一ファイル・単一行の変更のみ対応（複数行は `start_line` + `line` で対応）
- suggestion が空の場合はブロックを付加しない

### 既存スキルとの統合方針

`code-review-consolidate` スキルの出力（統合レビューレポート）を受け取り、`draft-review` スキルへ渡すブリッジスキルとして実装することを推奨する。

```text
code-review
  └── code-review-consolidate (統合レポート生成)
        └── draft-review (ドラフト投稿)
              └── [ユーザーが Web で Submit]
```

### 参考: GitHub API 仕様

- ドラフトレビュー作成: `POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews`（`event` 省略で PENDING）
- レビュー Submit: `POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews/{review_id}/events`
- Suggestion 構文: コメント本文内に suggestion フェンスブロックを含める
- 複数行 suggestion: `start_line` + `line` パラメータで範囲指定

### 実装優先度

| スキル          | 優先度 | 理由                                                  |
| --------------- | ------ | ----------------------------------------------------- |
| `draft-review`  | 高     | ドラフト投稿はレビューワークフローの根幹              |
| suggestion 統合 | 中     | `draft-review` に `suggestion` フィールド追加で対応可 |

## Steps

- [x] Step 1: Read spec and instruction files
- [x] Step 2: Create implementation plan via multi-model analysis
- [x] Step 3: Rewrite SKILL.md (frontmatter, Overview, Schema, Constraints, Examples)
- [x] Step 4: Fix Python script (fail-fast, structured output, error handling, suggestion formatting)
- [x] Step 5: Update Bash wrapper (python3/gh/auth checks)
- [x] Step 6: Verify lint, format, permissions, line count
- [x] Step 7: Code review iteration 1 (4 Critical/High found)
- [x] Step 8: Fix Critical/High issues (syntax error, backtick validation, type hints, readonly)
- [x] Step 9: Code review iteration 2 (0 Critical/High - pass)

## Verify

- Verify: `mise run lint` and `mise run format` pass on all modified files.
- Verify: SKILL.md body under 200 lines.
- Verify: Python script compiles without errors.
- Verify: Bash script passes shellcheck.

## Summary

Created the `draft-review` skill (formerly `pr-review-draft`) for creating
pending PR review comments, and renamed `review-comment-workflow` to
`resolve-comments`. The work was completed in two code iterations, and all
Critical/High review findings were resolved.

- Issues with resolutions: Syntax error in Python script (fixed), missing
  triple-backtick validation (added), type hint gaps (resolved), naming
  inconsistency (renamed both skills).
- Final verification result: lint/format pass, SKILL.md under 200 lines, all checks green.

## Scratchpad

- Completed in 2 iterations.
- Commit 1: 1aa389fa (feat: add draft-review skill).
- Commit 2: e2d25c26 (fix: resolve critical and high review findings).
- Remaining low-severity items deferred.

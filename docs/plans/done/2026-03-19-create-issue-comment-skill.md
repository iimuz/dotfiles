---
status: DONE
---

# TASK: issue-comment Skill 新規作成

## Goal

- Goal: GitHub Issue にサマリ + 折りたたみ詳細レポート形式のコメントを投稿する issue-comment スキルを、スクリプトによるフォーマット強制付きで作成する

## Ref

- `docs/reports/2026-03-19-skill-design-issue-comment.md`
- `docs/templates/skill-single-operation/SKILL.md`
- `.config/copilot/skills/commit-staged/` (スクリプトパターン参考)
- `.config/copilot/skills/pr-draft/` (gh コマンド + スクリプトパターン参考)
- GitHub Issue: #151

## Steps

- [x] Step 1: ディレクトリ作成 `.config/copilot/skills/issue-comment/scripts/`
- [x] Step 2: `scripts/post-comment.sh` を作成。
      バリデーション + フォーマット組み立て + `gh issue comment` 投稿を 1 スクリプトで完結。
      `--dry-run` フラグはデバッグ専用
- [x] Step 3: `SKILL.md` を作成。
      Knowledge/Transform テンプレート準拠。ユーザー確認は AI に委ねる指示
- [x] Step 4: `mise run lint` と `mise run format` で検証
- [x] Step 5: 動作確認 -- スクリプトの引数バリデーションをテスト
- [x] Step 6: `post-comment.sh` を stdin JSON 方式で全面書き換え。
      CLI フラグ: `--repo OWNER/REPO`, `--issue NUMBER`, `--dry-run`。
      stdin から JSON を受け取り `jq` でパース。
      JSON schema: `{ summary: string, details: [{label, content}] }`。
      details 0 件 (summary のみ) をサポート。
      `gh issue comment --body-file -` で投稿
- [x] Step 7: `SKILL.md` を stdin JSON 方式に合わせて全面更新。
      Input を JSON schema 形式に。Operations の呼び出し例を更新。
      details_label は SKILL.md には記載しない（デバッグ専用）
- [x] Step 8: `mise run lint` と `mise run format` で検証
- [x] Step 9: 動作確認 -- 複数 details / 0 件 details の dry-run 出力を確認

## Verify

- Verify: `mise run lint && mise run format` が成功し、スクリプトのバリデーションが正しく動作すること

## Summary

issue-comment スキルを新規作成した。初版は CLI フラグ方式で実装し、
Council 検討を経て stdin JSON 方式に全面書き換えた。multi-model code review で
11 件の改善点が見つかり 9 件を適用。main() パターンへのリファクタリング、
examples.md への参照抽出、Post Comment セクションの命令的記述への修正を行った。

主な問題と解決: (1) `readonly VAR="$(cmd)"` が `set -e` 下で exit code を隠す
問題を発見し代入と readonly を分離、(2) `[[ =~ [<>] ]]` の bash パースエラーを
パターン変数化で解決、(3) AI がスクリプトを直接読む問題を
`Run [scripts/post-comment.sh]` 命令パターンで解決。

最終検証: `mise run lint && mise run format` 成功、dry-run テスト合格。

## Scratchpad

- commit-staged パターン: スクリプトがバリデーション + 実行を担当。SKILL.md は AI にスクリプトの呼び方を指示
- pr-draft パターン: check + create の 2 段階。references/ に出力フォーマット定義
- post-comment.sh でフォーマット組み立てをスクリプト側に寄せることで、AI のプロンプト解釈に依存しない強制力を持たせる
- dry-run: スクリプトに `--dry-run` フラグを実装（デバッグ用）。SKILL.md には記載しない
- エッジケース: body にシングルクォート含む場合はヒアドキュメント使用、65536 文字超過は SKILL.md で AI に指示
- 複数 details 方針: Council 検討の結果 stdin JSON 方式を採用。
  CLI フラグはルーティング情報のみ (`--repo`, `--issue`, `--dry-run`)。
  コンテンツは JSON で stdin から渡す。`jq` でスキーマ検証。
  `gh issue comment --body-file -` で投稿。
  JSON エスケープ問題が頻発した場合はタグ区切り方式にフォールバック可能
- 2026-03-19: SKILL.md を stdin JSON インターフェース向けに全面更新。
  single-operation テンプレートに合わせ、Input/Operations/Examples を新仕様へ置換。
  `--dry-run` は SKILL.md から除外した
- 2026-03-19: `mise run lint && mise run format` を実行し、今回の Markdown 更新で
  失敗が出ないことを確認した

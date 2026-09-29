# PR の作成

Conventional Commits 形式のタイトルと、決まった形の本文で draft PR を作る。

## 手順

1. base ブランチを決める。ユーザーの指定がなければ origin の既定ブランチにする。worktree には base の
   ローカルブランチが無いことがあるので、以降は `origin/<base>` と比べる
2. まだコミットしていない変更 (`git status --short`)、`origin/<base>..HEAD` のコミット
   (`git log origin/<base>..HEAD --oneline`)、diff の統計 (`git diff origin/<base>...HEAD --stat`) を確認する。
   base との差分になるコミットが無ければ中止する
3. 変更に合う type を 1 つ、下の「type の一覧」から選ぶ
4. scope を付けるかを決める。リポジトリの規約 (CLAUDE.md、AGENTS.md、CONTRIBUTING、commitlint の設定など) に
   scope の定めがあるときだけ付け、その定めに従う。コミットや PR の履歴からは決めない
5. タイトルを書く。命令形で簡潔に、末尾にピリオドを付けず、ファイルパスを含めない。形は `<type>: <title>`、
   scope を付けるときは `<type>(<scope>): <title>`
6. 現在のブランチが origin に push されていなければ、止まってユーザーに伝える。自分では push しない
7. 下の「本文のテンプレート」に沿って本文を書き、下の「作成」のコマンドで draft PR を作る

## type の一覧

- `build`: ビルドの仕組みや外部依存の変更
- `chore`: 保守作業、script、設定の変更
- `ci`: CI の設定と script の変更
- `docs`: 文書の変更
- `feat`: 新しい機能
- `fix`: 不具合の修正
- `i18n`: 国際化
- `perf`: 性能の改善
- `refactor`: 振る舞いを変えないコードの整理
- `revert`: 以前のコミットの取り消し
- `style`: 書式や空白など、意味を変えないコードの見た目の変更
- `test`: テストの追加や修正

## 本文のテンプレート

`{...}` を中身に置き換える。

- Changes は必須で、`-` の箇条書きにする
- Related URLs と Review Points は、中身が無ければ見出しだけ残す
- Confirmation Results と Limitations は、中身があれば HTML コメントを中身に置き換え、無ければコメントを残す
- `{additional}` はその他の補足で、無ければ行ごと消す

```markdown
## Related URLs

{related_urls}

## Changes

{changes}

## Confirmation Results

<!-- Describe preconditions, steps, and results of confirmation if any -->

## Review Points

{review_points}

## Limitations

<!-- Describe known limitations of this change or items to be addressed in a separate PR if any -->

{additional}
```

## 作成

```bash
gh pr create --draft [--base <base>] --title '<タイトル>' --body-file - <<'EOF'
<テンプレートに沿って書いた本文>
EOF
```

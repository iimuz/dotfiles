# PR へのレビューコメント

PR にレビューを作り、行ごとのコメントを付ける。
セッションの gh が bot に切り替わっているかで、手順が分かれる。

## セッションの見分け方

`GH_CONFIG_DIR` が `$HOME/.config/gh-agent` なら、bot に切り替わったセッションである。

```bash
[ "${GH_CONFIG_DIR:-}" = "$HOME/.config/gh-agent" ] && echo bot || echo human
```

## bot に切り替わったセッション

下書きのレビューは作った本人にしか見えず、ユーザーは bot の下書きを見ることも submit することもできない。
そのため、下書きを作らず、次の順で進める。

1. レビュー全体の要約と、コメントの案を会話で見せる。各コメントには `path`、`line`、本文を示す
2. ユーザーが直しを求めたら、案を直して見せ直す
3. ユーザーが OK と言ったら、`create_review.sh` に `--event` を付けて実行し、bot の名義でレビューを submit する。
   `--event` は、ユーザーが会話で指示した種類 (`COMMENT`、`APPROVE`、`REQUEST_CHANGES`) にし、指示が無ければ `COMMENT` にする

GitHub は、PR の作成者が自分の PR に出す `APPROVE` と `REQUEST_CHANGES` を拒む。
PR の作成者が bot (`gh pr view <number> --json author` の `author.is_bot` が true) で、ユーザーがそれらを指示したときは、`COMMENT` で出してよいかを案と一緒に確かめる。

`append_review.sh` は使わない。

## 切り替わっていないセッション

PR に pending review を作り、submit しない。ユーザーが GitHub の画面から submit する。

- PR に pending review が無ければ `create_review.sh` を `--event` を付けずに実行する
- pending review があれば `append_review.sh` でコメントを追記する

`create_review.sh` が `{"error": "pending_review_exists", "review_id": <id>}` を返したら、再実行せずに
`append_review.sh` に切り替える。`append_review.sh` が `{"error": "no_pending_review"}` を返したら
`create_review.sh` を使う。

## コメントの項目

`--comments-json` には、次の項目を持つオブジェクトを 1 個以上並べた JSON 配列を渡す。2 つの script で同じ形を使う。

- `path` (必須): リポジトリのルートからのファイルパス
- `line` (必須): コメントを付ける行番号
- `body` (必須): コメントの本文
- `suggestion`: 提案するコード。script が GitHub の suggestion ブロックで囲むので、3 連バッククォートを
  含めると script が拒否する
- `start_line`: 複数行にまたがるコメントの開始行
- `side`: diff の側。`LEFT` か `RIGHT`

## create_review.sh

```bash
bash "${SKILL_DIR}/scripts/create_review.sh" \
  --owner "<owner>" \
  --repo "<repo>" \
  --pull-number <number> \
  --summary-body "<review 全体の要約>" \
  --comments-json '<json array>' \
  [--event COMMENT|APPROVE|REQUEST_CHANGES]
```

`--event` を付けると submit 済みのレビューを作り、付けないと pending review を作る。
成功すると標準出力に `{"id": <number>, "html_url": "<url>"}` を出す。

## append_review.sh

```bash
bash "${SKILL_DIR}/scripts/append_review.sh" \
  --owner "<owner>" \
  --repo "<repo>" \
  --pull-number <number> \
  --comments-json '<json array>'
```

`--summary-body` は無い。成功すると標準出力に `{"review_id": "<id>", "added": <count>, "thread_ids": [...]}` を出す。

# PR へのレビューコメント

PR に pending review を作り、行ごとのコメントを付ける。

## script の選び方

- PR に pending review が無ければ `create_review.sh` で作る
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
  --comments-json '<json array>'
```

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

## submit しない

review は pending のまま残し、submit しない。ユーザーが GitHub の画面から submit する。

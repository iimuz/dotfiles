# PR のレビュースレッドへの返信

PR の既存のレビュースレッドに返信する。
返信は submit を待たずに、すぐ PR に出る。
セッションの gh が bot に切り替わっているかで、手順が分かれる。
見分け方は [pr-review-rules.md](pr-review-rules.md) の「セッションの見分け方」にある。

## bot に切り替わったセッション

返信が誰の言葉かで、手順が分かれる。

- ユーザーの指摘、指示、判断を伝える返信は、文面を会話で見せ、ユーザーが OK と言ってから `reply_review.sh` に `--human-checked` を付けて実行する。
  `--human-checked` は、ユーザーが会話で確かめたことを示す署名を本文の最後に足す
- Claude Code が自分の作業を報告する返信 (直した内容、変更しない理由) は、文面を見せずに `reply_review.sh` を `--human-checked` を付けずに実行する。
  ユーザーが返信を頼んだときだけ出す

## 切り替わっていないセッション

返信の文面を会話で見せ、ユーザーが OK と言ってから `reply_review.sh` を `--human-checked` を付けずに実行する。
返信はユーザーのアカウントの名義で出る。

## 返信先のコメントの id

`--comment-id` には、スレッドの最初のコメントの id を渡す。
GitHub は返信への返信を受け付けない。

```bash
gh api "repos/<owner>/<repo>/pulls/<number>/comments" --paginate \
  --jq '.[] | select(.in_reply_to_id == null) | {id, path, line, body}'
```

## reply_review.sh

```bash
bash "${SKILL_DIR}/scripts/reply_review.sh" \
  --owner "<owner>" \
  --repo "<repo>" \
  --pull-number <number> \
  --comment-id <id> \
  [--human-checked] \
  --body-file - <<'EOF'
<返信の本文>
EOF
```

`--human-checked` を付けると、本文の最後に、空行を 1 つ挟んで次の署名の行を足す。

```text
<sub>👤 Checked by a human · drafted by Claude Code</sub>
```

成功すると標準出力に `{"id": <number>, "html_url": "<url>"}` を出す。

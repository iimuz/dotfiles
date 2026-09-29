---
name: qmd
description: >-
  QMD でローカルの Markdown のノート、文書、wiki を検索し、全文を取る。ノートを探す、文書を取り出す、
  wiki の中身を確かめる、index 済みの Markdown から答える、QMD をセットアップするときに使う。
compatibility: Requires qmd CLI or MCP server. Install via `npm install -g @tobilu/qmd`.
allowed-tools: Bash(qmd:*), mcp__qmd__*
---

# qmd

## 流れ

1. 候補の文書を検索する
2. `qmd get` か `qmd multi-get` で全文を取る
3. 取った本文から答え、docid か path と行番号を付ける

スニペットだけで答えない。スニペットは候補を見つける手がかりにとどめる。

## 検索の選び方

- 正確な語 (タイトル、名前、コードの識別子、珍しい言い回し) が分かるときは `qmd search` (BM25) を使う
- 言い換えや概念で探すときは、`intent:`、`lex:`、`vec:`、`hyde:` の欄を自分で書いた `qmd query` を使う。
  素の `qmd query "<文>"` は使わない。内蔵の query expansion はユーザーの目的を知らず、日本語の問いは
  英語に寄せられて精度が落ちる
- `qmd query` が遅いか、モデルや GPU の準備で失敗するときは、語を足した `qmd search` に切り替える

欄の意味は次のとおり。`intent:` と、`lex:` か `vec:` の少なくとも一方を書く。

- `intent:`: 探しているものと、避けたい近くの別の概念
- `lex:`: 本文に現れると見込む正確な語、別名、タイトル、識別子
- `vec:`: 探す考えを、本文に近い言い回しで言い換えた文
- `hyde:`: 求めに合う文書や答えの姿

```bash
qmd search '"weekly review"' -c notes -n 10
qmd query $'intent: 週次レビューの進め方を書いたノート。日次の振り返りは除く\nlex: 週次レビュー weekly review\nvec: 1 週間の作業を振り返り、次の週の計画を立てる手順'
```

## 取得

- 行の範囲は `:from:count` の接尾辞か、`--from` と `-l` で取る。`sed` や `head` に流さない。
  流すと docid の解決、行番号、ヘッダーが失われる
- `--full-path` は、パスを他のツール (`Read`、`Edit` など) に渡すときだけ使う
- `multi-get` には、カンマ区切りの `qmd://` パスを渡す。docid をカンマで並べると解決に失敗する

```bash
qmd get "#abc123:120:40"
qmd get qmd://notes/weekly-review.md --from 200 -l 60
qmd get "#abc123" --full-path
qmd multi-get 'qmd://notes/weekly-review.md,qmd://notes/daily-review.md' --format md
```

## コレクション

`qmd collection list`、`qmd ls`、`qmd status` で、何が index されているかを確かめる。検索が別のコーパスに
ずれるときは `-c <collection>` で絞る。

## index の変更と診断

`qmd collection add`、`qmd update`、`qmd embed` は、ユーザーがセットアップか保守を求めたときだけ実行する。

```bash
npm install -g @tobilu/qmd
qmd collection add ~/notes --name notes
qmd update
qmd embed
```

モデルを使うコマンドが失敗したら、設定を変える前に `qmd doctor` を実行する。

## 日本語のコーパス

- 既定の embedding の embeddinggemma-300M は日本語への対応が限られる。`qmd vsearch` だけの結果を信用しない
- 表記の揺れ (漢字、カタカナ、英語) は、別の問いとして何回かに分けて引く
- パスを取るときは `--files --full-path` を使う

## GPU の判定

この skill の `scripts/check_gpu.sh` を実行する。出力は `gpu` か `cpu` の 1 語になる。`cpu` のときは
`qmd search` だけを使うか、`--no-rerank` を付ける。

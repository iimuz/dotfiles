---
name: web-research
description: >-
  Research a topic using web sources and produce one standalone summary per
  consulted article plus a final summary synthesized only from those
  summaries, so every claim stays traceable to its source. Use when asked to
  research, investigate, look into, or survey a topic on the web.
---

# Web Research

## Overview

2 段階の調査を行う。第 1 段階では参照した記事ごとに、単独で読める要約をファイルとして書く。
第 2 段階ではその要約だけを読んで最終要約を作る。これにより最終要約のどの主張も
記事単位の要約に遡れる。1 回で統合する通常の調査ではこの追跡ができない。

## Output Layout

カレントプロジェクト配下に次の構成で作成する。

```text
docs/reports/YYYY-MM-DD-{topic}/
├── report.md
└── sources/
    ├── 01-{slug}.md
    └── 02-{slug}.md
```

- `YYYY-MM-DD` は今日の日付。`{topic}` は調査主題を kebab-case にしたもの。
- `NN` は 2 桁ゼロ埋めの通し番号。選定順に採番し、`report.md` の引用番号と一致させる。
- `{slug}` は記事タイトルまたはドメイン名を kebab-case にしたもの。

## Process

1. Scope。質問を 3 から 5 個の重複しない調査観点に分解する。検索を始める前に観点をユーザーに示す。
2. Search。観点ごとに WebSearch を実行する。ホスト名とパスを正規化して重複を除き、
   関連度で順位付けして全観点の合計で最大 8 件を選定する。ユーザーが件数を指定した場合はそれに従う。
3. Summarize each article。1 ソースにつき 1 サブエージェントを並列でディスパッチする。
   各サブエージェントは次を行う。

   - context-mode MCP が利用できる場合は `ctx_fetch_and_index` でページを取得する。
     利用できない場合は WebFetch を使う。
   - [references/source-note-template.md](references/source-note-template.md) に従って
     `sources/NN-{slug}.md` を書く。
   - 戻り値はファイルパスのみとする。記事本文を返さない。

4. Synthesize。サブエージェントを 1 つディスパッチし、`sources/` 配下のノートだけを読ませて
   [references/report-template.md](references/report-template.md) に従って `report.md` を書かせる。
   このサブエージェントには Web 取得ツール (WebSearch, WebFetch, ctx_fetch_and_index) を
   使わせない。ノートの記述が薄い場合も、ノートに無いことは書かせない。
5. Trace check。`report.md` のすべての主張に `[NN]` 引用があること、すべての `[NN]` が実在する
   ノートを指すこと、ノートに無い情報が混入していないことを確認する。違反は修正する。
6. Adversarial verification。ユーザーが明示的に要求した場合のみ実行する。主要な主張ごとに
   サブエージェントをディスパッチし、反証となる情報を Web 検索させる。反証が見つかった場合は、
   その出典にも `NN` の連番を継続してノートを書き、`report.md` の該当する主張に `[NN]` 付きで
   注記する。ノートを作らないまま `report.md` に追記しない。

## Rules

- 統合はノートのみを読む。統合の段階で新しいソースを追加しない。記事本文を最終要約に直接使わない。
- `report.md` のすべての主張に、根拠となったノートの引用を付ける。
- 選定したソースには必ずノートを書く。取得に失敗したソースにもノートを書く。
- 取得できなかった内容を推測で埋めない。取得失敗として記録する。
- 出力は日本語で書く。逐語引用は原語のまま残す。
- 生成する Markdown は lint に適合させる。1 行目を H1 にし、本文行は 120 文字以内にし、
  リストの前後に空行を入れる。

## Fetch Failures

Cloudflare や有料記事の壁があるページは HTTP 403 を返す。JavaScript による描画が必須のページは
中身の無い HTML を返す。いずれの場合もノートとレポートのソース一覧に「取得失敗」と記録する。代替ソースの探索は、
並列で走らせた要約サブエージェントが出そろった後にオーケストレーターが行う。選定の重複を
避けるため、取得に失敗したサブエージェント自身には探させない。

WebFetch はページそのものではなく小型モデルによる要約を返すため、`ctx_fetch_and_index` より
忠実度が低い。WebFetch を使った場合はノートの取得方法欄にそれを記録する。

WebSearch が候補を返さない場合は、語を変えて 1 回再検索する。それでも得られない場合は、
何を試して見つからなかったかをユーザーに報告して終了する。推測で調査結果を作らない。

## Scope

Web 上の記事を対象とする。ローカルのファイルやリポジトリを精読する場合は deep-read スキルを使う。
主張単位の敵対的検証を重視する場合は組み込みの deep-research スキルを使う。

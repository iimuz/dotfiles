---
name: context-mode
description: >
  コンテキストウィンドウを守るため、シェル、ファイル読み込み、HTTP、データ解析を context-mode
  MCP ツール (ctx_ 接頭辞) に流す。context-mode が接続されているとき、または "ctx" コマンドの
  ときに適用する。
metadata:
  verified-with: context-mode 1.0.169
---

# context-mode のローカル運用方針

個々の `ctx_*` ツールが何をするか、どんなときに使うかは、MCP ツールの説明文に書かれている。説明文は
インストール済みのサーバーが供給するため古くならない。このファイルには、説明文が触れない内容だけを
書く。すなわち、この環境でツールを使うコストと、この環境固有の事実である。

## コスト構造 — Bash か sandbox かを最初に決める

`ctx_execute` と `ctx_execute_file` は、投入したスクリプトを stdout の前にコードブロックとして
そのまま返す。つまりスクリプトには 2 回分のコストがかかる。1 回目はツール呼び出しを生成するとき、
2 回目はエコーされた結果としてであり、後者はセッションが終わるまでコンテキストに残り続ける。

- 出力が 20 行未満で収まるもの (`git status`、`ls`、`wc -l`、バージョン表示など) は Bash で実行
  する。`ctx_execute` で包むと、節約できる分より余計にかかる。
- 既製の CLI で簡潔な答えが得られる場合 (`gh --jq`、`jq`、`grep -c`、`sort | uniq -c` など) は、
  そのコマンドを実行する。スクリプトとして書き直さない。
- sandbox のスクリプトはまとまった処理に限定する。ディスク上のデータ変換、多数のファイルの解析、
  出力量が事前に読めない集計などである。
- スクリプトは一度で書き切る。`try/catch` と null 処理を入れ、答えだけを出力する。短いスクリプトを
  試行錯誤で何度も投げ直すのが、最も割高な使い方である。

言語は、HTTP と JSON なら `javascript`、CSV と統計なら `python`、ネイティブツールのパイプなら
`shell` を選ぶ。

## この環境の前提

- context-mode の routing hook は導入していない。`curl`、`wget`、`WebFetch`、巨大な Bash 出力は
  何も遮断されない。したがって経路は自分の判断で選ぶ。Web の内容は `ctx_fetch_and_index` と
  `ctx_search` を通し、出力量が読めない処理は sandbox を通す。
- subagent のプロンプトにも何も注入されない。context-mode を経由させたい subagent には、その
  プロンプトの中で明示的に指示する。
- ツールはホストごとに接頭辞の付いた名前で登録される。Claude Code では
  `mcp__context-mode__ctx_execute` になる。upstream の文書では `ctx_execute` と裸の名前で
  書かれている。
- サーバーのバージョンは `.config/mise/config-*.toml` の `npm:context-mode` で固定している。

## ctx コマンド

| コマンド      | 動作                                                                       |
| ------------- | -------------------------------------------------------------------------- |
| `ctx stats`   | `ctx_stats` を呼び、出力をそのまま全文表示する                             |
| `ctx doctor`  | `ctx_doctor` を呼び、返されたシェルコマンドを実行し、チェックリストで示す  |
| `ctx upgrade` | `ctx_upgrade` を呼び、返されたシェルコマンドを実行し、チェックリストで示す |
| `ctx insight` | `ctx_insight` を呼ぶ。ブラウザでホスト側のダッシュボードが開く             |
| `ctx purge`   | `ctx_purge` を confirm: true で呼ぶ。knowledge base を消去する             |

knowledge base とセッション統計は /clear と /compact をまたいで保持される。作り直すときは
`ctx purge` を使う。

## upstream の文書

インストール済みのパッケージには、upstream 自身の routing 規則とパターン集が同梱されている。詳細な
例が必要になったときは、それを読む。このファイルに写し取らない。場所は次の手順で解決する。`find` は
`-maxdepth` を他の条件より前に置く必要がある。

```bash
P=$(find "$(mise where npm:context-mode)" -maxdepth 4 -type l -name context-mode \
  -path '*/node_modules/*' | head -1)
R=$(readlink -f "$P")
```

- `$R/configs/claude-code/CLAUDE.md` — Claude Code 向けの upstream の routing 規則。
- `$R/skills/context-mode/SKILL.md` — upstream のスキル。既定の方針が上記のコスト構造と逆で、
  すべてのコマンドを sandbox 経由にする。このファイルの方針を優先する。
- `$R/skills/context-mode/references/` — アンチパターンと言語別のパターン集。

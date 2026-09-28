# AWS 構成図

## 目的

AWS の構成図を Mermaid の `flowchart LR` で描く。AWS サービスのアイコンは Iconify から取り、
Mermaid v11.3.0 以降の image-node 拡張 (`nodeID@{img,label,pos,w,h,constraint}`) で埋め込む。

`architecture-beta` は使わない。click に対応しておらず、外部のアイコンが Notion や GitHub で描画されない。
`flowchart` は click、`subgraph` の入れ子、辺の書き方のすべてに対応しているので、こちらのほうが広く使える。

## 使わない場面

- draw.io の XML が欲しいとき。`deploy-on-aws:aws-architecture-diagram` に任せる
- ASCII の図で足りるとき

## 手順

1. 描く対象を挙げる (AWS サービス、外部サービス、ブラウザ、オンプレミス)
2. アカウント、リージョン、VPC、外部といった階層を `subgraph` でまとめる
3. 骨組みから書き始める
4. 各ノードにアイコンの URL を当てる
5. 下のレイアウトとラベルの規則を当てる
6. コンソールへの click 行は、ユーザーが求めたときだけ足す
7. 図を ` ```mermaid ` のコードフェンスで囲む

## 既定値

| 項目                          | 既定値                                    |
| ----------------------------- | ----------------------------------------- |
| 向き                          | `flowchart LR` (外部から内部へ、左から右) |
| テーマ                        | `neutral`                                 |
| `nodeSpacing` / `rankSpacing` | 10 / 30                                   |
| アイコンの大きさ              | `w: 60, h: 60`                            |
| ラベルの位置                  | `pos: "b"` (アイコンの下)                 |
| レイアウトの制約              | `constraint: "on"`                        |

## レイアウト

- `subgraph` の入れ子は 2 から 3 段までにする (例: AWS アカウント、リージョン、VPC)。それより深くしない
- 複数リージョンの図では、リージョンごとに subgraph を分ける
  (`subgraph use1["us-east-1"]`、`subgraph apne1["ap-northeast-1"]`)
- 同じ列にノードを揃えるには、ラベルが空の見えない subgraph (`subgraph g-foo[" "]`) で囲み、
  `classDef group fill:none,stroke:none` と `class g-foo group` で枠を消す
- subgraph 同士の縦の並びを決めるには、見えない辺 `~~~` でつなぐ (例: `g-cdn ~~~ vpc ~~~ g-aux`)

## ラベル

- 改行には `<br>` (HTML) を使う。`\n` は効かない
- ラベルにコロン `:` やパイプ `|` を入れない。Mermaid のパーサーが誤動作することがある。
  必要なら全角のコロン (`：`) に置き換えるか、言い換える

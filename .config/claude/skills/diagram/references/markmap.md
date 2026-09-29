# markmap の書き方

markmap は 1 つの Markdown ファイルを、操作できるマインドマップに変える。見た目はふつうの Markdown を書き、
markmap がその見出しとリストの階層を読んで木を描く。

書くだけにする。HTML、SVG、PNG への変換や描画をせず、ビューアや開発サーバーも起動しない。
ファイルのプレビューはユーザーが自分の道具で行う。`.md` ファイルを渡すか、テキストだけが欲しいと言われたら
`markdown` のコードフェンスで渡す。

## Markdown が木になる仕組み

- 見出し (`#` から `######`) が外側の枝になり、見出しの下の入れ子の箇条書きがそれより深い枝と葉になる
- `# Title` を 1 つだけ置いて始める。それが唯一の根のノードになり、マップの中心がすっきりする
- 見出しと箇条書きの項目がそれぞれ 1 つのノードになる。インデントした子がその枝で、子のない項目が葉になる
- 文書の順序は保たれる。兄弟のノードは書いた順に上から下へ並ぶ
- Markdown の見出しは 6 段までしかない。それより深くするには入れ子のリストに切り替える。
  これが、いくらでも深い枝を作るための文書化された方法になる。上の 1 から 3 段を見出しにし、
  その下を入れ子のリストにする形がよく使われる

## frontmatter の設定: markmap ブロック

YAML の frontmatter の `markmap:` キーの下に設定を置く。設定は書いておく。素の箇条書きでも描画はされるが、
設定がないとすべて展開され色も付かない状態で開き、ユーザーが望む形になることはまれ。

```markdown
---
markmap:
  colorFreezeLevel: 2
  initialExpandLevel: 2
---

# Title
```

frontmatter に書けるキー:

| キー                 | 型                                            | 既定値                     | 働き                                                                 |
| -------------------- | --------------------------------------------- | -------------------------- | -------------------------------------------------------------------- |
| `color`              | string または string[]                        | d3 category10              | 枝ごとに順に使う色のパレット                                         |
| `colorFreezeLevel`   | number                                        | 0                          | N 段目で色を固定し、枝とその子孫すべてを同じ色にする。0 は固定しない |
| `initialExpandLevel` | number                                        | -1                         | 開いたときに展開する最も深い段。-1 はすべて展開する                  |
| `maxWidth`           | number                                        | 0                          | ノードの最大幅 (px)。0 は制限なし                                    |
| `duration`           | number                                        | 500                        | 折りたたみと展開のアニメーションの時間 (ms)                          |
| `spacingHorizontal`  | number                                        | 80                         | ノード間の横の間隔                                                   |
| `spacingVertical`    | number                                        | 5                          | ノード間の縦の間隔                                                   |
| `zoom`               | boolean                                       | true                       | ズームを許す                                                         |
| `pan`                | boolean                                       | true                       | パンを許す                                                           |
| `extraCss`           | string[]                                      | —                          | 追加のスタイルシートの URL (`npm:` の URL は CDN 経由で解決される)   |
| `extraJs`            | string[]                                      | —                          | 追加のスクリプトの URL (`npm:` の URL は CDN 経由で解決される)       |
| `activeNode`         | object `{ placement: 'center' \| 'visible' }` | `{ placement: 'visible' }` | フォーカスしたノードの置き方                                         |
| `lineWidth`          | number                                        | 自動で計算                 | 枝をつなぐ線の幅 (markmap 0.18.8 以降)                               |

次のキーは frontmatter に書かない。もっともらしく見えるが、`markmap:` ブロックが読まない低レベルの表示設定で、
書いても黙って何も起きない。

- `autoFit`
- `fitRatio`
- `paddingX`
- `embedGlobalCSS`
- `nodeMinHeight`
- `scrollForPan`
- `toggleRecursively`
- `maxInitialScale`

ユーザーがそれらを必要とするなら、それは書くファイルではなく、ユーザーが動かすビューアや描画側の設定になる。

## 折りたたみのマジックコメント

見出しや箇条書きの行末に HTML コメントを置くと、そのノードの初期の折りたたみ状態を決められる。

- `<!-- markmap: fold -->` はそのノードを折りたたむ
- `<!-- markmap: foldAll -->` はそのノードと子孫すべてを折りたたむ

```markdown
## Details <!-- markmap: fold -->

- hidden until the user expands it
```

マップの大部分を開いたまま、重い部分木だけを畳みたいときは、`initialExpandLevel` を小さくする代わりにこれを使う。

## ノードに書けるもの

markmap はノードの中のふつうの Markdown を描画するので、次のものが使える。

- 太字、斜体、取り消し線、インラインコード
- リンク `[text](url)` と画像 `![alt](url)`
- KaTeX の数式: インラインの `$E = mc^2$` とブロックの `$$ ... $$`
- コードフェンス (シンタックスハイライトされる)
- タスクリスト: `- [ ]` と `- [x]`
- 表、引用、生の HTML

数式とコードハイライトに要るアセットは、それらが現れたときに自動で読み込まれるので、追加の宣言は要らない。

## 書き方の指針

- ノードのラベルは短くする。マインドマップでは完全な文より短い句のほうがずっと読みやすい
- ラベルの言語はユーザーの内容に合わせる (日本語の内容なら日本語のラベル)
- 大きなマップでは `initialExpandLevel` を設定し (まずは 2)、読めない壁のように開かないようにする
- `colorFreezeLevel` (たいてい 1 か 2) を使い、最上位の枝ごとに色の系統を分ける
- `maxWidth` は、長い文がどうしても避けられないノードがあるときだけ使う

## 例

見出しより深い段にリストを使う、小さなマップ:

```markdown
---
markmap:
  colorFreezeLevel: 2
  initialExpandLevel: 2
---

# Project

## Backend

- API
  - Auth
    - OAuth
    - JWT
- Database

## Frontend

- UI
- State
```

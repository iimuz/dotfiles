# ADR の作法

## 書く場面

- 「整理して」と頼まれたエージェントが壊しそうな決定
- 過去の障害や失敗から学んだ決定
- コードコメントだけで理由が伝わるなら書かない

## 作成

1. docs/adr/ の既存 ADR をタイトルと本文で検索し、同じか重なる決定を探す
   - 見つからない: 2 へ進む
   - Proposed が見つかった: それを更新して終える
   - Accepted が見つかった: supersede するかをユーザーに尋ねる。するなら
     「ステータスの更新」の supersede に従い 2 へ進む。しないなら終える
2. docs/adr/ の最大 ID に 1 を足す
3. ファイル名は `NNNN-slug.md` にする
4. [adr-template.md](adr-template.md) を写して埋める。frontmatter のキーは id、status、
   date、supersedes だけにする。id はファイル名と同じ 4 桁ゼロ埋めの文字列にする

## ステータスの更新

ステータスを変えるのはユーザーだけ。

- Proposed から Accepted か Rejected へ
- Accepted から Deprecated か Superseded へ

supersede するときは、旧 ID を supersedes に入れた新しい ADR を作り、旧 ADR を Superseded にする。
deprecate するときは、旧 ADR を Deprecated にする。Accepted の ADR で変えてよいのはステータスだけ。

## 参照

- 同じリポジトリの ADR は `ADR-NNNN` と書く
- 他のリポジトリの ADR は `owner/repo#ADR-NNNN` と書く

## 書き方

- 見出しは英語、タイトルと本文は日本語で書く
- 検討した案とその得失は Context の中に書く。案の節を別に作らない

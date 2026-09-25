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
deprecate するときは、旧 ADR を Deprecated にする。

- Accepted な ADR はステータス以外を編集しない。Consequences も決定時点の予測として凍結し、
  現状と食い違っても直さない
- Superseded な ADR は履歴として扱い、書き方の欠陥があっても触らない
- Accepted な ADR の集合が、現在有効な決定の全体を表す。後の決定が前の決定の一部でも
  変えたら、変わった側を全文書き直して supersede する。Accepted どうしが食い違ったまま
  残る状態を作らない
- 設計文書から ADR へ理由を参照するときは、Accepted か Proposed の ADR に向ける。参照先が
  supersede されたら、supersede した ADR へ張り替える

## 参照

- 同じリポジトリの ADR は `ADR-NNNN` と書く
- 他のリポジトリの ADR は `owner/repo#ADR-NNNN` と書く

## 書き方

ADR は決定時点の記録であり、現在の仕様の参照先ではない。値を知りたい読者は正本へ行く。

- 見出しは英語、タイトルと本文は日本語で書く
- 1 本の ADR は 1 つの決定だけを持つ
- 検討した案とその得失は Context の中に書く。案の節を別に作らない
- Decision と Consequences には、境界の判断とその理由を役割で書く。値、パス、コマンド、
  lint ルール ID は書かない。値を役割に置き換えても決定として言い切れる文にする。Context には
  当時の状況として固有名を一度だけ挙げてよい
- 他の ADR や設計文書が既に決めたことを Decision に写さない。前提として効くなら Context から
  番号で参照する

却下案の有無、1 本 1 決定であること、Decision に値が混ざっていないことは機械的に判定しにくい
ため、レビューで確かめる。

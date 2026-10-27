---
name: superpowers-conventions
description: >-
  superpowers の skill (brainstorming、writing-plans、subagent-driven-development、
  executing-plans) を動かすとき、それらが作る design と plan のファイルを保存する、扱うとき、
  plan に ADR や設計文書を作る task を書くとき、それらを使った作業の PR を作るときに使う。
---

# superpowers-conventions

## 目的

作業の順序は superpowers に従う。
この skill は、superpowers が作る design と plan のファイルの扱いのうち、superpowers の既定に無いものだけを決める。

## 保存先

design と plan の保存先は brainstorming と writing-plans の既定に従う。リポジトリの文書規約が作業途中の
成果物の置き場所を別に定めていても、そこへ移さない。

## design の書き方

design のファイルに書く部分と builder check の手順は brainstorming に従う。
この節は、その上に重ねる書き方だけを決める。

- builder がコードを読めば分かる内容と、builder が決めても作るものが変わらない内容は、書き手が自分から書かない。
  後者は、builder check が細部を仕分ける基準と同じである。
  外れる典型は、今のコードの動きの書き出し、ファイルパスと関数名、手順、文書の修正箇所の一覧、ADR の下書きである
- この規則は、builder check で出た問いの答えには当てない
- 外した内容は、builder 向けの別のファイルにも移さない。
  plan を書く段で builder がコードから作るので、別のファイルに移すと plan と同じ内容を二重に持ち、人がそれも読むことになる
- what's left to the builder には、外した内容のうち builder が気付くべきものの名前だけを書く
- 何を変えるか (1 から 3 文)、決めたこと、goals と non-goals と anti-goals を、冒頭の 1 つの見出しの下に置く。
  冒頭だけを読めば承認できるようにするためである。
  ほかの部分で同じ決定を言い直さない
- 決定のうち本文に節を立てるのは、理由や退けた案の説明が要るものだけにする。
  intent and the why、constraints、what's left to the builder は本文に置く
- 決定の節の見出しは、「決定 2」のような番号ではなく、冒頭に書いた決定そのものの文にする。
  見出しで決定を示すことは言い直しに含めない
- 表は、2 つ以上の案を同じ観点で比べるときだけ使う
- 図は、処理の流れ、状態の移り変わり、構成要素のつながりを変えるときだけ、同じことを書いた文章の代わりに描く。
  冒頭は図に頼らず、素の文字で読んで判断できるようにする
- 承認に要る内容は折りたたまない

## 文書を作る task

plan に ADR や設計文書を作る task があるときは、writing-plans の既定どおり、plan にその文書の完成文を
入れる。承認後に実装する側は plan の文を写すので、文書の内容を規約に照らす場は plan を書く時点になる。
plan を書く側は、完成文を書く前に doc-conventions を読み、ユーザーにレビューを頼む前に完成文を
doc-conventions で照合する。照合の観点は doc-conventions に従い、ここには書かない。

## 作業場所と統合

plan の task、step、全体の制約、合否の基準のどこにも、作業ブランチや worktree を作る、選ぶ、切り替える
指示を書かない。作業する checkout を指定する制約 (「primary checkout で作業する」など) と、この作業の
ブランチの push、PR の作成、merge も書かない。

作業場所は plan を実行する skill が using-git-worktrees で用意し、統合は finishing-a-development-branch が
扱う。plan にも書くと同じ作業を二重に指示することになる。作業場所と統合を自分で決める無人の実行環境に
plan を渡したときは、plan の指示がその契約とぶつかる。

PR の本文に必ず入れる事柄があるときは、task ではない節 (「PR に書くこと」など) に書く。

## コミットしない

`docs/superpowers/` と `.superpowers/` の下のファイルはコミットしない。gitignore されていない
リポジトリでは、`git add -A` のような一括の stage でも含めない。

## GitHub への記録

ユーザーがこの作業の一部として design と plan を GitHub に記録するよう求めたときは、次の時点で
gh-ops を使ってコメントとして投稿する。書き込みに要るユーザーの明示的な指示は CLAUDE.md が定める。
この節は、その指示があるときの投稿の時点と内容だけを決める。

- design、issue から始めた作業: plan の承認後、実装を始める前に issue に投稿する
- design、issue から始めていない作業: PR を作った直後に PR に投稿する
- plan: PR を作った直後に PR に投稿する

投稿する前に次の 2 点を済ませる。

- 本文をファイルの最終状態に合わせる。design と plan は書いた後に変わっていることがある
- 単体で読めるようにする。1 行目に主題を書き、git 管理外のファイル (design と plan のファイル自身、
  作業メモ) への参照は本文に取り込むか削る

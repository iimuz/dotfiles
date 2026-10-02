---
name: superpowers-conventions
description: >-
  superpowers の skill (brainstorming、writing-plans、subagent-driven-development、
  executing-plans) を動かすとき、それらが作る design と plan のファイルを保存する、扱うとき、
  plan に ADR や設計文書を作る task を書くとき、それらを使った作業の PR を作るときに使う。
---

# superpowers-conventions

## 目的

作業の順序は superpowers に従う。この skill は、superpowers が作る design と plan のファイルについて、
保存先、ユーザーの承認を待つ時点、plan に入れる文書の完成文を文書規約に照らす時点、コミットしないこと、
GitHub への記録の仕方を決める。

## 保存先

design と plan の保存先は brainstorming と writing-plans の既定に従う。リポジトリの文書規約が作業途中の
成果物の置き場所を別に定めていても、そこへ移さない。

## 承認

- design のファイルを書いたら止まり、ユーザーにレビューを頼む。承認されるまで writing-plans を始めない
- plan のファイルを書いたら止まり、ユーザーにレビューを頼む。承認されるまで実装を始めない
- 承認はチャットの要約ではなくファイルに対して受ける。パスを示して待つ

## 文書を作る task

plan に ADR や設計文書を作る task があるときは、writing-plans の既定どおり、plan にその文書の完成文を
入れる。承認後に実装する側は plan の文を写すので、文書の内容を規約に照らす場は plan を書く時点になる。
plan を書く側は、完成文を書く前に doc-conventions を読み、ユーザーにレビューを頼む前に完成文を
doc-conventions で照合する。照合の観点は doc-conventions に従い、ここには書かない。

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

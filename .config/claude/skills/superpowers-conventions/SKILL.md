---
name: superpowers-conventions
description: >-
  superpowers の skill (brainstorming、writing-plans、subagent-driven-development、
  executing-plans) を動かすとき、それらが作る design と plan のファイルを保存する、扱うとき、
  それらを使った作業の PR を作るときに使う。
---

# superpowers-conventions

## 目的

作業の順序は superpowers に従う。この skill は、superpowers が作る design と plan のファイルについて、
保存先、ユーザーの承認を待つ時点、コミットしないこと、GitHub への記録の仕方を決める。

## 保存先

| ファイル | 保存先                                                |
| -------- | ----------------------------------------------------- |
| design   | `docs/superpowers/specs/YYYY-MM-DD-{topic}-design.md` |
| plan     | `docs/superpowers/plans/YYYY-MM-DD-{topic}.md`        |

- `YYYY-MM-DD` は今日の日付、`{topic}` は作業の主題を kebab-case にしたもの。両方を必ず入れる
- リポジトリの文書規約が作業途中の成果物の置き場所を別に定めていても、design と plan はそこに移さず
  上の表に従う

## 承認

- design のファイルを書いたら止まり、ユーザーにレビューを頼む。承認されるまで writing-plans を始めない
- plan のファイルを書いたら止まり、ユーザーにレビューを頼む。承認されるまで実装を始めない
- 承認はチャットの要約ではなくファイルに対して受ける。パスを示して待つ

## コミットしない

`docs/superpowers/` と `.superpowers/` の下のファイルはコミットしない。gitignore されていない
リポジトリでは、`git add -A` のような一括の stage でも含めない。

## GitHub への記録

ユーザーがこの作業の一部として design と plan を GitHub に記録するよう求めたときは、次の時点で
gh-ops を使ってコメントとして投稿する。書き込みに要るユーザーの明示的な指示は gh-ops と CLAUDE.md が
定める。この節は、その指示があるときの投稿の時点と内容だけを決める。

- design、issue から始めた作業: plan の承認後、実装を始める前に issue に投稿する
- design、issue から始めていない作業: PR を作った直後に PR に投稿する
- plan: PR を作った直後に PR に投稿する

投稿する前に次の 2 点を済ませる。

- 本文をファイルの最終状態に合わせる。design と plan は書いた後に変わっていることがある
- 単体で読めるようにする。1 行目に主題を書き、git 管理外のファイル (design と plan のファイル自身、
  作業メモ) への参照は本文に取り込むか削る

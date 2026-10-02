---
name: subagent-first
description: >-
  コードの調査や変更 (issue の依頼、機能の追加、バグの修正) と、CLI、プロセス、サービスの実機での挙動を
  調べる作業を始めるとき、自分でコードベースを探る前、subagent を起動するときに、どの workflow から
  頼まれたかに関わらず使う。
---

# subagent-first

## 概要

main agent は orchestrator と検証者を務める。
計画を立て、dispatch し、返答を評価し、決定的な根拠を確かめ、次の一手を決める。

この skill はすべての subagent の dispatch に掛かる契約を定める。役割は割り当てない。
別の process skill が subagent に役割を割り当てるときは、その役割を保ったまま、各 dispatch にこの契約を当てる。

subagent は read-only か edit-allowed のどちらかで、それ以外の区別は無い。

## 直接やるか委譲するか

main agent が直接やる作業。

- 残りの手順を今すべて挙げられて、数が少ない。対象ファイルが特定済みで数回のツール操作で終わる作業は、
  この一例にあたる
- 会話の文脈が要る。案出し、設計の議論、要件の確認
- 入力が計画や設計の文書 (plan、ADR) である

委譲する作業。

- 次の手順が前の手順の結果を見ないと決まらない。コードの調査でも、CLI、プロセス、サービスの実機検証でも
  同じに扱う
- 対象ファイルが未特定で、広く探す必要がある
- 変更が複数のファイルにまたがる
- 独立した作業を並列にできる
- コマンドの出力が main の context を埋める。この場合は read-only の subagent を使う

次の時点で判断する。

- 依頼の中身が分かった時点。Issue を指定された依頼では、Issue 本文を読んだ時点がこれにあたる
- 直接実行した手順の結果が予想と違い、別のやり方を試そうとした時点。ここで止まり、残りを委譲する

途中から委譲するときは、それまでに確かめた事実と否定した仮説を dispatch の evidence に書いて渡す。

## dispatch の契約

subagent への prompt には次をすべて含める。

- goal: 1 つの問いか 1 つの変更。変更のときは目的を書く。defect fix、spec change、refactoring のどれか
- evidence: goal が defect fix のときは必須。再現する失敗、失敗するテスト、コードの直接の参照 (file:line)、
  仕様との明らかな食い違いのどれか
- edits: yes か no
- allowed files/dirs と forbidden files/dirs
- 文書 (skill、rules、ADR、設計文書) を書く、または変える goal では、書く前に doc-conventions を読む指示を
  必ず含める。subagent は skill を自分で呼べるが、plan の文をファイルに写すだけの task は文書を書いていると
  は感じにくく、自分からは呼ばない。そのためこの task でも指示を省かない
- success signal: 作業を完了とみなすために成り立つべきこと
- return format: 下のテンプレートを prompt に貼る

1 つの subagent には 1 つの goal と 1 つの scope を渡す。
edit-allowed の subagent は、自分の変更に絞ったテストを足して実行してよい。
根拠の無い defect fix は dispatch しない。先に read-only の subagent で原因を特定するか、ユーザーに尋ねる。

## 返答形式

subagent はこの skill を読まない。main agent はこのテンプレートをすべての dispatch の prompt に貼る。
形式を固定すると、返る量が抑えられ、自由形式の要約なら落ちる反証が残る。

```yaml
status: success | failure | blocked
summary: # a few lines
evidence: # file:line plus a short excerpt; only what supports the conclusion
confirmed: # verified facts (required for read-only subagents)
hypotheses: # ideas not yet verified (required for read-only subagents)
rejected: # hypotheses ruled out, with the reason (required for read-only subagents)
unverified: # checks that could not be run
files_changed: # edit-allowed subagents only
next_action:
```

別の process skill が報告の項目を足すよう求めるときは、このテンプレートに足す。置き換えない。
生の出力 (grep の結果、コマンドのログ) は返さない。残す必要があるときは、harness が用意する一時ディレクトリに
書き、パスだけを返す。

## dispatch の後の待ち方

dispatch したらターンを終える。subagent が終わると harness がセッションを呼び直すので、待つのに polling も
wakeup も要らない。

dynamic `/loop` (間隔を指定せずに起動したもの) の下ではこれが成り立たない。ターンを終えるたびに
`ScheduleWakeup` が要り、待ちが短い間隔の polling になる。その下では subagent を orchestrate しない。
すでに動いているときは、loop を止めるか、間隔を明示して起動し直すようユーザーに伝える。

## 完了前の確認

作業を完了とする前に、main agent は次を直接読む。

- subagent の返答が示す決定的な根拠の file:line
- 最終の差分

## 返答ごとの次の一手

subagent の返答を受けるたびに、次のどれか 1 つを選ぶ。

- 範囲を絞った次の subagent を dispatch する
- scope を分ける
- ユーザーに尋ねる
- 止めて報告する

## model

- haiku: ファイルの特定、情報の抽出、コマンドの実行と結果の要約
- sonnet: scope が明確な実装、通常の調査、範囲を限ったレビュー
- opus: 原因が曖昧な分析、設計判断を伴う実装、リスクの高い差分のレビュー

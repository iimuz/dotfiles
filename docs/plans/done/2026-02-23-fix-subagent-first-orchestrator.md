---
status: DONE
---

# TASK: Fix subagent-first Orchestrator Behavior

## Goal

- Goal: `subagent-first` スキルが `structured-workflow` などのオーケストレータースキルと
  共存した際に、メインエージェントがパイプラインを正しくフェーズ単位で実行するよう修正する。

## Ref

- `.config/copilot/skills/subagent-first/SKILL.md`
- `.config/copilot/skills/structured-workflow/SKILL.md`

## Steps

- [x] Step 1: 問題を分析する — `DelegationMandated` invariant がワークフロー全体を単一
      サブエージェントに委譲する誤った動作を引き起こしていることを確認
- [x] Step 2: `RequestClass` に `"orchestration"` を追加する
- [x] Step 3: `Invariant #8: OrchestratorPreservation` を追加する（`DelegationMandated`
      より優先、>=2 ops + >=1 delegated invocation でオーケストレーター判定）
- [x] Step 4: `classify` op を更新する — 評価順序を trivial → user-explicit →
      orchestration → fallback とし、オーケストレーション検出を曖昧性フォールバックより前に置く
- [x] Step 5: `orchestrate` op を追加する — パイプラインを単一サブエージェントに委譲しない
- [x] Step 6: Execution フローを `classify -> orchestrate | [delegate -> relay] | direct`
      に更新する
- [x] Step 7: レビューで検出した Critical issue を修正する — classify コメントの評価順序
      記述とルーティングテーブルの op/agent_type 混在を解消

## Verify

- Verify: `mise run lint` が `Summary: 0 error(s)` で終了すること。

## Scratchpad

- コミット 1: `8865f25` — refactor: add OrchestratorPreservation invariant to
  subagent-first skill
- コミット 2: `a378117` — fix: correct classify comment order and remove routing table
  abstraction mismatch
- 根本原因: `subagent-first` の `DelegationMandated` invariant を「ワークフロー全体を1つの
  サブエージェントに渡す」と誤解釈。`structured-workflow` 自体がオーケストレーターであり、
  メインエージェントがフェーズごとにスキルを順次呼び出すべきだった。
- レビューで Critical issue 2 件（コメント不整合、ルーティングテーブル抽象層混在）を検出・修正済み。

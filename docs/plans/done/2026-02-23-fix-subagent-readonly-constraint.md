---
status: DONE
---

# TASK: Fix Subagent Readonly Constraint

## Goal

- Goal: `implementation-plan` および `code-review` のサブエージェントがソースコードを変更する問題を修正する。

## Ref

- `.config/copilot/skills/implementation-plan/references/analysis-prompt.md`
- `.config/copilot/skills/implementation-plan/references/synthesis-prompt.md`
- `.config/copilot/skills/code-review/references/review-prompt.md`
- `.config/copilot/skills/code-review/references/integration-prompt.md`
- `.config/copilot/skills/code-review/references/gap-analysis-prompt.md`
- `.config/copilot/skills/code-review/references/cross-check-prompt.md`

## Steps

- [x] Step 1: `analysis-prompt.md` の `op analyzeRequirements` に `Read_Only` invariant を追加
- [x] Step 2: `synthesis-prompt.md` の `op savePlan` に `Read_Only` invariant を追加
- [x] Step 3: `review-prompt.md` の `op format_output` に `Read_Only` invariant を追加
- [x] Step 4: `integration-prompt.md` の `op write_report` に `Read_Only` invariant を追加
- [x] Step 5: `gap-analysis-prompt.md` の `op write_gap_list` に `Read_Only` invariant を追加
- [x] Step 6: `cross-check-prompt.md` の `op write_output` に `Read_Only` invariant を追加

## Verify

- Verify: `grep -rn "source_code_modification_attempted"` で 6 件ヒットすること。

## Scratchpad

- 根本原因: サブエージェントプロンプトにソースコードを変更しないという制約が存在しなかった。
  フルツールアクセスを持つサブエージェントが意図せず実装・修正を行うことがあった。
- 修正: 各プロンプトの書き込み op に以下の invariant を追加。

```text
invariant: (source_code_modification_attempted) => abort("Read-only: ...");
```

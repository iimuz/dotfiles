---
status: DONE
---

# TASK: Add subagent-first Skill

## GOAL

- Goal: `.config/copilot/skills/subagent-first/` に subagent 優先委譲を強制するメタスキルを Hybrid-3 形式で作成する。

## REF

- `.config/copilot/skills/subagent-first/SKILL.md`
- `.github/instructions/tool-configuration.instructions.md`

## STEPS

- [x] Step 1: skill-creator / transform-legacy-skill / structured-workflow の best practices を読み込む
- [x] Step 2: 3 並列分析エージェント (Claude / Gemini / GPT) でスキル要件・設計を分析する
- [x] Step 3: 分析結果からドラフトプランを 2 並列で作成する
- [x] Step 4: 3 並列クロスレビューでドラフトを相互評価する
- [x] Step 5: コンセンサス集約・コンフリクト解決・インサイト検証を行う
- [x] Step 6: 最終プランを合成して `feature-subagent-first-skill-1.md` に保存する
- [x] Step 7: task-coordinator を通じて SKILL.md を作成する (`8cd31cb`)
- [x] Step 8: コードレビュー (12 並列) を実行し Warning 8 件 / Suggestion 7 件を確認する
- [x] Step 9: W3〜W8 を修正してコミットする (`395713a`)
- [x] Step 10: 最終レビューで PASS を確認する

## VERIFY

- Verify: `mise run lint .config/copilot/skills/subagent-first/SKILL.md` がエラー 0 件で完了すること。

## SCRATCHPAD

### 設計上の主要決定

- **スキル名**: `subagent-first`
- **形式**: Hybrid-3 (TypeScript Interface + TypeSpec Operations)
- **パイプライン**: `classify -> [delegate -> relay] | direct`
- **インバリアント 7 件**: OrchestratorOnly, DelegationMandated, IntentPassthrough,
  EscapeHatch, ExplicitOverride, RecursionPrevention, FailOpenOnUnknownCompatibility

### コンフリクト解決のポイント

- flat types のみ採用 (GPT 案の ActivationContext は不採用 — runtime introspection 不可)
- activate 判定は description-driven (skill 列挙は不要)
- fail-open ポリシーを採用して互換性不明時のブロックを回避

### 残存許容 Warning

- W1: intent passthrough のプロンプトインジェクションリスク — 個人利用のため許容
- W2: RecursionPrevention が自然言語のみ — プラットフォーム制約として許容

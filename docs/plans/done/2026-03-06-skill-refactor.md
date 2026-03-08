---
status: DONE
---

# Skill Refactor

## Goal

34 SKILL.md ファイル（5 ファミリー）を `.github/instructions/skills.instructions.md` の規約に準拠させる。

## Ref

- `.github/instructions/skills.instructions.md`
- `.config/copilot/skills/code-review/` (1 workflow + 8 sub-skills)
- `.config/copilot/skills/council/` (1 workflow + 6 sub-skills)
- `.config/copilot/skills/implementation-plan/` (1 workflow + 7 sub-skills)
- `.config/copilot/skills/task-coordinator/` (1 workflow + 3 sub-skills)
- `.config/copilot/skills/tdd-workflow/` (1 workflow + 5 sub-skills)

## Steps

- [x] Step 1: Core refactoring (34 files)
  - `## Interface` を `## Schema` に改名（TypeScript type/interface のみ）
  - `@fault`/`@invariant` DSL を平文の制約に変換
  - `## Constraints` セクションを追加
  - セクション順序を規約に準拠
- [x] Step 2: Content placement standardization
  - 操作手順を Constraints から Overview に移動（19 files）
  - 出力フォーマットを Overview から Output に移動（3 files）
- [x] Step 3: Workflow stage delegation
  - 全ワークフローのステージを `tool: task` に統一
- [x] Step 4: Sub-skill simplification (29 files)
  - パススルーフィールド削除（session_id, model_name, timestamp）
  - 不要な中間型削除
  - オーケストレーター結合を除去（caller-agnostic に）
  - 過剰な制約を削除
  - 冗長な Execution order 行を削除（22 files、6 files は有用なため保持）
  - Session Files セクションを sub-skill から削除（orchestrator のみ保持）
- [x] Step 5: Orchestrator-to-sub-skill contract alignment
  - session_id を明示的パラメータに置換（全 4 orchestrator）
  - `{session_dir}` 規約を全 orchestrator の Overview に定義
  - ステージプロンプトと sub-skill Input 定義の整合
- [x] Step 6: Documentation improvements (21+ files)
  - 処理ステップを Overview に追加
  - Happy Path 例を input/output 形式に簡素化
  - 出力フォーマットテンプレート・パーシング指示・参照ファイル読込指示を追加（8 files）
- [x] Step 7: Council-specific fixes
  - council-review から冗長な question パラメータ削除
  - council-synthesize の aggregate_ranking_path を Optional に変更
  - council-fallback の rankings_path を aggregate_ranking_path に統一
- [x] Step 8: Task-coordinator simplification
  - run_dir, run_id, keep_runs をユーザー入力から削除（orchestrator 内部で自動生成）
  - Dashboard 機能と履歴管理を完全削除
  - Stage 4 を結果返却のみに簡素化
- [x] Step 9: Reference file modernization (4 files)
  - `declare function`, `@invariant`, `@fault`, TypeSpec を平文に変換
  - 重複セクション（Steps と Execution Instructions）を統合

## Verify

- `mise run lint` passes（pre-existing MD041/MD036 in docs/reports/ のみ）
- `mise run format` passes

## Key Decisions

- Content placement: Overview = 処理ステップ、Constraints = 実行制限のみ、Output = 出力フォーマット、Schema = 型定義のみ
- Sub-skill は caller-agnostic: orchestrator のステージ名やワークフロー名を参照しない
- 全ステージで `tool: task`（subagent delegation）を使用、`tool: skill` は不使用
- `{session_dir}` 規約: `~/.copilot/session-state/{session_id}/files/` に統一
- Execution order 行: Overview の prose で同じ情報を伝えている場合は削除、独自の操作詳細を追加している場合のみ保持
- Session Files セクション: orchestrator のみ（cross-stage データフロー文書化）、sub-skill は Output で十分
- implementation-plan の Analysis/Draft 分離: Cross-pollination（他モデルの分析結果参照）のため維持
- implementation-plan の Aggregate/Resolve 分離: 役割特化（Opus で整理、Codex で決断）のため維持

## Report Analysis

### Adopted

- TypeScript による型定義（Schema）: 入出力を TypeScript の type/interface で制約する方針を採用。セクション名は `## Schema` に統一。
- PM パターン（subagent 委譲）: メインエージェントはメタデータ管理と意思決定に徹し、実データ処理は `tool: task` に委譲。
- Role 記述の廃止: エージェントの人格（Role: Project Manager 等）ではなく、機能や振る舞い（Overview）を記述。
- JSON 通信フォーマット: subagent との通信を入出力スキーマで定義された構造に統一。

### Not Adopted

- DSL 形式の制約記述（@invariant, @fault）: 可読性と保守性を重視し、平文の箇条書きに統一。
- OpaqueFilePath 型エイリアスの強制: 概念（パスだけ渡す）は採用したが、全ファイルで型エイリアスを強制するのは冗長なため見送り。不要な中間型は Step 4 で削除。
- セクション名 `## Interface` / `## Behavior Guidelines`: 規約に基づき `## Schema`, `## Constraints` に統一。

## Summary

34 SKILL.md ファイルと 4 reference ファイルを skills.instructions.md 規約に準拠させた。
主な変更: Schema 改名、DSL 除去、content placement 標準化、sub-skill 簡素化、
orchestrator-to-sub-skill contract 整合、documentation 改善、task-coordinator 簡素化。
全変更は branch fix/skills-refactor 上で約 20 commits にわたり実施。

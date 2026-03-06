---
status: DONE
---

# TASK: Fix structured-workflow skills compliance

## Goal

- Goal: structured-workflow/SKILL.md と structured-workflow-implement/SKILL.md を skills.instructions.md の規約に準拠させ、不足している情報ギャップ項目をルールとして追加または提案する。

## Ref

- `.config/copilot/skills/structured-workflow/SKILL.md`
- `.config/copilot/skills/structured-workflow-implement/SKILL.md`
- `.github/instructions/skills.instructions.md`

## Steps

- [x] Step 1: 第1回レビュー - structured-workflow/SKILL.md の違反項目を修正する
- [x] Step 2: 第1回レビュー - structured-workflow-implement/SKILL.md の違反項目を修正する
- [x] Step 3: 第1回レビュー - skills.instructions.md に情報ギャップ項目を追加する
- [x] Step 4: 第2回レビュー - 違反項目を修正する（NV1 FALSE ALARM; NV2-NV5 対応しない）
- [x] Step 5: 第2回レビュー - 情報ギャップをルール追加する（NG1-NG2 完了; NG3-NG6 対応しない）

## Verify

- Verify: `mise run lint` が正常終了する。

## Scratchpad

### 指摘事項（違反）: structured-workflow/SKILL.md

#### V1: Interface 内の名前付き型サイズルール違反 ✅ 完了

- 対象: `Issue`（2フィールド）、`IterationVerdict`（2フィールド）
- 修正内容:
  - `IterationVerdict` を削除し `FinalSummary.history[].verdict` へインライン化。
  - `Issue` は fixed/unfixed/verdict.issues の3箇所で使われるため named 維持。
    skills.instructions.md に「3箇所以上のフィールド位置参照の場合も named 型を許可」のルールを追加済み。

#### V2: Interface に含まれるステージレベル内部型 `PriorIssue` ✅ 完了

- 対象: `PriorIssue` 型
- 修正内容: Interface から `PriorIssue` 型定義を削除。ステージ説明内で prose として参照継続。

#### V3: ステージテンプレートの6項目不完全（Stage 3/4/5） ✅ FALSE ALARM

- 実ファイルを確認したところ、全ステージが 6項目（Purpose/Inputs/Actions/Outputs/Guards/Faults）を持つ。
- 修正不要。

#### V4: ask_user() の text コードフェンス要件 ✅ COMPLIANT / 保持決定

- 実ファイルを確認したところ、ask_user() は text コードフェンスで正しく記述されており規約違反なし。
- 判断: Execution セクション末尾（Stage 5 後）に配置されており、「final_summary step での ask_user」に相当。
  ワークフロー完了後に継続判断を提供する運用上の価値もあるため保持。

#### V5: @invariant が workflow-wide ポリシーを含む ✅ 完了

- 修正内容: 全 @invariant タグを Interface から削除し、Overview の Operational constraints として prose に移動。
  @fault invalid_task_input のみ Interface に残存。

---

### 指摘事項（違反）: structured-workflow-implement/SKILL.md

#### V6: fault() 宣言の欠落 ✅ FALSE ALARM

- 再評価: NEVER ルール「Interface @fault を stage-level fault() の代替にするな」は
  Workflow スキルの Stage テンプレート（Faults: フィールド）に対するもの。
  Knowledge/Transform スキルには stage がないため、Interface の `// @fault` 注釈が正規の宣言形式。
- 修正不要。

#### V7: PriorIssue 型の不完全な型注釈 ✅ 修正済（コミット前から）

- 確認: 現在のファイルで `severity: "Critical" | "High" | "Medium" | "Low"` は既に正しく定義されている。
- 修正不要。

#### V8: 未使用の ImplementInput 型 ✅ 完了

- 修正内容: `ImplementInput` 型定義を Interface から削除。
  各 `declare function` がそれぞれ必要なフィールドをインラインで定義しており不要。

---

### 情報ギャップ（skills.instructions.md への追加候補）

以下は現行ルールに存在しない暗黙の規約。structured-workflow 系の新規作成・修正時に
skills.instructions.md だけでは判断できない。rules への昇格可否を個別に判断すること。

#### G1: セッションファイルパス規約 ✅ 完了

- 追加内容: Allowed Section Headings に Session Files セクション必須条件とパス規約
  `~/.copilot/session-state/{session_id}/files/` を追加。

#### G2: skill() vs task() 呼び出し分離規約 ✅ 完了

- 追加内容: Workflow Skill Authoring に Invocation Separation ルール追加。
  `skill()` は直接、`task()` は非スキル処理に使用。オーケストレーターを task() 内から呼ぶことを禁止。

#### G3: Interface セクションへの型制約（unused type 禁止） ✅ 完了

- 追加内容: Interface Section Style に「declare function シグネチャに使用されない型を定義してはならない」ルール追加。

#### G4: // Detail: 記法の位置付け ✅ 完了

- 追加内容: Interface Section Style に `// Detail:` プレフィックス規約を追加。

#### G5: references/ ファイルへのリンク記法 ✅ 完了

- 追加内容: Interface Section Style に `// Detail: See references/filename.md` リンク記法規約を追加。

#### G6: 重複型の同期管理方針 — 対応不要

#### G7: H1 タイトル規約 ✅ 完了

- 追加内容: SKILL.md Format に H1 タイトルを frontmatter 直後の1行目に必須とするルール追加。

#### G8: 複数 fault() 宣言の許可 ✅ 完了

- 追加内容: Workflow Skill Authoring の Fault Declaration Requirement に
  「1ステージに複数の fault() 宣言可能」の明文化を追加。

---

## 第2回 Council レビュー結果（2026-03-05）

### 指摘事項（違反）: 第2回レビュー

#### NV1: Stage 2 で task() 経由で skill() を呼び出している ✅ FALSE ALARM + ルール修正済

- 対象: structured-workflow/SKILL.md Stage 2 Actions
- 判断: `structured-workflow-implement` は task-free（内部で task() を呼ばない）ため、`task()` 経由での呼び出しは正当。
  Invocation Separation ルールが invocability ラベルベースで曖昧だったことが原因。
- 対応: `skills.instructions.md` の Invocation Separation を 4 行の task-capable/task-free グラフ到達可能性基準に改訂。
  /council による2回の審議（task-capable/task-free 分類の確立）の末、最適な concise 版を採用。
- 状態: ✅ FALSE ALARM / ルール修正完了

#### NV2: Stage 2 Outputs が曖昧【Low】— 対応しない（過剰対応）

- 対象: structured-workflow/SKILL.md Stage 2 Outputs フィールド
- ルール違反: 6-field template — Outputs は明示的なアーティファクトパスのリストを要求する。
- 現状: "implementation artifacts in working directory"（パスなし）
- 修正案: 例 "modified source files (paths determined by task-coordinator); {session_dir}/sw-implement-request-{n}.md"
- 優先度: 低
- 状態: [ ] 未対応

#### NV3: Happy Path が実行順序と不一致【Low】— 対応しない（過剰対応）

- 対象: structured-workflow-implement/SKILL.md Examples > Happy Path
- ルール違反: Examples は宣言された実行順序を正確に反映すること（実行順序: Overview 行）。
- 現状: "determine_scope → write_checkpoint → write_request all succeed"（最後の write_checkpoint が抜けている）
- 修正案: "determine_scope → write_checkpoint → write_request → write_checkpoint all succeed"
- 優先度: 低
- 状態: [ ] 未対応

#### NV4: 条件ロジックが python ブロック外に存在【Low】— 対応しない（過剰対応）

- 対象: structured-workflow/SKILL.md Execution セクション（python ブロックの後の prose）
- ルール違反: "Workflow skills requiring conditional stage transitions MUST place loop/branch logic
  in the python call-order block. Do not place conditional logic as prose between stage definitions."
- 現状: "Loop exits when !has_critical_or_high || iteration >= 3." が python ブロック外に存在
- 修正案: python ブロック内のコメントに移動し、ブロック外の条件記述を削除
- 優先度: 低
- 状態: [ ] 未対応

#### NV5: // Detail: 複数行での先頭プレフィックス不統一【Low】— 対応しない（過剰対応）

- 対象: structured-workflow-implement/SKILL.md Interface > determine_scope の Detail コメント
- ルール違反: `// Detail:` プレフィックスは補足説明を持つ行に使用するルールで、
  後続行でスペースインデントのみを使用することが許可されているか不明。
- 現状: 1行目のみ `// Detail:` プレフィックス、後続行は空白インデント
- 修正案: 全行 `//` プレフィックスを付ける、または `references/` に抽出する
- 優先度: 低（ルール解釈次第で FALSE ALARM の可能性あり）
- 状態: [ ] 未対応

---

### 情報ギャップ（第2回 Council 推奨追加ルール）

#### NG1: K/T スキルでの @fault が両要件を満たすことを明記【推奨: 高】✅ 完了

- 内容: K/T スキルには Execution セクションがないため、Interface の `@fault` が
  「stage-level fault() も必要」というルールの例外となることを明記すべき。
- 追加先: Knowledge/Transform Skill Authoring
- 対応内容: 「K/T スキルでは Interface の @fault アノテーションが Interface レベルと
  op レベルの両方の fault 宣言要件を満たす」ルールを追加。
  また、line 115-116 の既存ルールに "In Workflow skills," スコープ修飾子を追加（曖昧性解消）。
- コミット: 9bcccb2 (NG1+NG2 ルール追加), 3d56bf0 (スコープ修飾子 + NG2 配置修正)
- 状態: ✅ 完了

#### NG2: Workflow スキルの Session Files "Written by" 列の定義【推奨: 中】✅ 完了

- 内容: Session Files テーブルの "Written by" 列は K/T スキルの "op" を前提にしているが、
  Workflow スキルで sub-agent や sub-skill が書くファイルの場合にどう記述するかが不明。
- 追加先: Allowed Section Headings の Session Files ルール
- 対応内容: 「Workflow スキルでは "Written by" 列に Stage 名、Sub-Skill 名、または Agent タイプを記載する」
  ルールを追加。配置は既存 Session Files ルールの直後（line 134 の後）に移動。
- コミット: 9bcccb2 (NG1+NG2 ルール追加), 3d56bf0 (配置修正)
- 状態: ✅ 完了

#### NG3: python ブロック内ヘルパー関数の許可範囲【推奨: 低】— 対応しない（過剰対応）

- 内容: `map_issues(verdict.issues, iteration)` のような未定義ヘルパー関数が
  call-order ブロックに含まれることが許可されるか否かが不明。
- 追加先: Workflow Skill Authoring の call-order ブロックルール
- 修正案: 「call-order ブロックには stage 関数呼び出しと制御フロー構文のみを含めること。
  データ変換は簡単なインライン代入として含めてよいが、未定義のヘルパー関数は使わないこと」
- 状態: [ ] 未対応

#### NG4: Execution セクション初期化 prose の配置【推奨: 低】— 対応しない（過剰対応）

- 内容: python ブロックと Stage 1 の間に "Resolve session_id...", "Set iteration = 1..."
  のような初期化 prose を置くことが許可されるか不明。
- 追加先: Workflow Skill Authoring の Execution セクションルール
- 修正案: 「初期化説明（変数セットアップ、セッション解決）は python ブロック内のコメントか
  最初のステージの Inputs に含めること。Execution セクション本文の独立 prose に置かないこと」
- 状態: [ ] 未対応

#### NG5: sub-agent から非オーケストレータースキルを skill() で呼ぶ可否【推奨: 低】— 対応しない（過剰対応）

- 内容: Sub-Agent Nesting Prohibition は task() の禁止のみ規定。
  sub-agent が非オーケストレータースキルを skill() で呼ぶことへの可否が未定義。
- 追加先: Workflow Skill Authoring（Sub-Agent Nesting Prohibition の隣）
- 修正案: 「Sub-agents は非オーケストレータースキルを skill() で呼び出してよい。
  ただしオーケストレータースキルを task() 内から呼ぶことは Invocation Separation 違反である」
- 状態: [ ] 未対応

#### NG6: 実行順序記法で同一 op が複数回登場する表記の許可【推奨: 低】— 対応しない（過剰対応）

- 内容: `Execution order: op_a -> op_b -> op_c` の例では各 op が1回。
  `write_checkpoint` が2回登場する表記が許可されるか不明。
- 追加先: Knowledge/Transform Skill Authoring（実行順序記述ルール）
- 修正案: 「フロー内で複数回呼ばれる op は実行順序行に複数回記載してよい」
- 状態: [ ] 未対応

---
status: DONE
---

# TASK: Revise Skill Style to Prose-Based Approach

## Goal

- Goal: SKILL.md の記述スタイルをテンプレート型から散文型に変更し、skills.instructions.md も同じ方針に改訂する

## Ref

- `.github/instructions/skills.instructions.md`
- `.config/copilot/skills/code-review/SKILL.md` (orchestrator, new style)
- `.config/copilot/skills/code-review-security/SKILL.md` (sub-skill, new style example)

## Steps

- [x] Step 1: code-review2/SKILL.md に改善点を反映する（frontmatter 修正、Overview 追加、出力型注釈、セッションファイル注記）
- [x] Step 2: skills.instructions.md を散文ベーススタイルに改訂する
- [x] Step 3: code-review2 の内容を code-review に統合し、全 8 sub-skill を新スタイルで書き直す
- [x] Step 4: aws-cli skill と aws-cli-log-retrieval sub-skill を新スタイル + 自律 subagent 設計で書き直す
- [x] Step 5: commit-staged skill と references/types.md を書き直す
- [x] Step 6: council orchestrator と 6 sub-skill を書き直す（output-format.md 抽出含む）
- [x] Step 7: draft-review skill を書き直す
- [x] Step 8: implementation-plan orchestrator と 7 sub-skill を書き直す（output-format.md 抽出含む）
- [x] Step 9: pr-draft skill を書き直す（type-reference.md, output-format.md 抽出含む）
- [x] Step 10: resolve-comments skill を書き直す
- [x] Step 11: structured-workflow orchestrator と implement sub-skill を書き直す
- [x] Step 12: mise run lint && mise run format で検証する
- [x] Step 13: task-coordinator シリーズ（orchestrator + 3 sub-skills）を書き直す
- [x] Step 14: tdd-workflow シリーズ（orchestrator + 5 sub-skills）を書き直す
- [x] Step 15: skills.instructions.md に確立した規約を追加する（References, Placeholder, Autonomous Subagent 等 9 項目）
- [x] Step 16: skills.instructions.md から冗長・重複・自明なルールを削除する（8 削除 + 3 統合、225 -> 166 行）
- [x] Step 17: `docs/templates/skill-workflow/` ディレクトリを作成する（SKILL.md + references/output-format.md）
- [x] Step 18: `docs/templates/skill-single-operation/` ディレクトリを作成する（SKILL.md + references/output-format.md）
- [x] Step 19: skills.instructions.md にテンプレートへの参照を追加し、applyTo にテンプレートパスを追加する
- [x] Step 20: mise run lint && mise run format で最終検証する

## Verify

- Verify: `mise run lint` AND `mise run format` が 0 errors で完了すること

## Summary

### 変更の全体像

skills.instructions.md の改訂と、10 スキルファミリー (39 ファイル) の散文スタイルへの書き換え。

### 変更ファイル一覧

#### instructions

- `.github/instructions/skills.instructions.md`: 254 -> 196 lines
  - 削除: Contract Layers, 6-field stage template, Python call-order, TypeScript Schema 要件
  - 追加: Body Structure, Stage Format, prompt-as-template ルール

#### code-review シリーズ (9 files)

- `code-review/SKILL.md`: 245 -> 115 lines (orchestrator)
- `code-review-security/SKILL.md`: 54 -> 42 lines
- `code-review-quality/SKILL.md`: 55 -> 42 lines
- `code-review-performance/SKILL.md`: 54 -> 42 lines
- `code-review-best-practices/SKILL.md`: 54 -> 42 lines
- `code-review-design-compliance/SKILL.md`: 55 -> 42 lines
- `code-review-gap-analysis/SKILL.md`: 58 -> 44 lines
- `code-review-cross-check/SKILL.md`: 55 -> 41 lines
- `code-review-consolidate/SKILL.md`: 53 -> 39 lines

#### aws-cli シリーズ (2 files)

- `aws-cli/SKILL.md`: 300 -> 108 lines (autonomous subagent design)
- `aws-cli-log-retrieval/SKILL.md`: 153 -> 88 lines

#### commit-staged (2 files)

- `commit-staged/SKILL.md`: 75 -> 47 lines
- `commit-staged/references/types.md`: 42 -> 27 lines

#### council シリーズ (7 files + 5 new references)

- `council/SKILL.md`: 253 -> 148 lines (orchestrator)
- `council-respond/SKILL.md`: 46 -> 33 lines
- `council-anonymize/SKILL.md`: 88 -> 46 lines
- `council-review/SKILL.md`: 63 -> 40 lines
- `council-synthesize/SKILL.md`: 103 -> 49 lines
- `council-aggregate/SKILL.md`: 67 -> 45 lines
- `council-fallback/SKILL.md`: 79 -> 47 lines
- 新規: 5 sub-skill に `references/output-format.md` を作成

#### draft-review (1 file)

- `draft-review/SKILL.md`: 102 -> 47 lines

#### implementation-plan シリーズ (8 files + 1 new reference)

- `implementation-plan/SKILL.md`: 272 -> 152 lines (orchestrator)
- `implementation-plan-analyze/SKILL.md`: 50 -> 33 lines
- `implementation-plan-aggregate/SKILL.md`: 46 -> 29 lines
- `implementation-plan-draft/SKILL.md`: 46 -> 35 lines
- `implementation-plan-resolve/SKILL.md`: 47 -> 33 lines
- `implementation-plan-review/SKILL.md`: 46 -> 31 lines
- `implementation-plan-synthesize/SKILL.md`: 52 -> 38 lines
- `implementation-plan-validate/SKILL.md`: 47 -> 34 lines
- 新規: `implementation-plan-synthesize/references/output-format.md`
- 修正: `implementation-plan-draft/references/plan-template.md` (code block 削除, YAML frontmatter 追加)

#### pr-draft (1 file + 2 new references)

- `pr-draft/SKILL.md`: 274 -> 55 lines
- 新規: `pr-draft/references/type-reference.md`, `pr-draft/references/output-format.md`

#### resolve-comments (1 file)

- `resolve-comments/SKILL.md`: 241 -> 131 lines

#### structured-workflow シリーズ (2 files)

- `structured-workflow/SKILL.md`: 240 -> 134 lines (orchestrator)
- `structured-workflow-implement/SKILL.md`: 67 -> 39 lines

#### その他 references 修正

- `jira-to-issue/references/issue_template.md`: 不要コードブロック削除
- `structured-workflow-implement/references/request-template.md`: 不要コードブロック削除

### Why This Is Better

- Token efficiency: orchestrator は平均 50% 以上の行数削減。LLM のコンテキストウィンドウを節約
- Reduced duplication: 同じ情報を Schema, Input table, Stage Inputs に3回書く必要がなくなった
- Alignment with reality: 既存 51 SKILL.md のうち旧形式は少数派 (TypeScript Schema 35%, 6-field 22%)
- Readability: 散文は自然に読め、YAML/TypeScript の入れ子構造よりスキャンしやすい

### Degradation Risks

- Less machine-parseable: 旧形式の予測可能な構造がなくなり、task()/skill() ラベル等の慣例に依存
- No forced completeness: 旧 6-field template は全項目記入を強制したが、散文では漏れが起きやすい
- Complex workflows: 多段階の条件分岐がある場合、散文は旧テンプレートより追いにくくなる可能性

### How to Apply to Other Skills

1. Frontmatter は変更しない
2. `## Overview` を最初のセクションにする
3. `## Constraints` は Overview の散文に統合する
4. Input/Output は bullet list + `field: type` 形式にする
5. Workflow skill の stage は `### Stage N: Name` + 散文 + task()/skill() ラベル + blockquote + Output/Fault bullets
6. Sub-skill の examples は `- Happy:` / `- Failure:` の1行形式
7. TypeScript schema, Python call-order, Session Files table, YAML Actions は削除
8. `mise run lint` && `mise run format` で検証

### Autonomous Subagent Design Principle

- Subagent は自律的な問題解決者。orchestrator は問題とインフラ制約を渡すだけ
- プロンプトテンプレートに具体的な操作手順を書かない。ユーザー指定があれば hint として渡す
- Sub-skill の指示は best practice として書く。安全制約のみ必須にする
- 不要な orchestrator ステージ（例: "Propose Next Methods"）は削除

## Scratchpad

- 51 SKILL.md のうち TypeScript Schema 使用は 18 (35%), 6-field template は 11 (22%)
- 大多数のスキルは既に散文ベースで書かれており、instructions が実態と乖離している
- 方針: 散文ベースを推奨スタイルとし、旧形式の構文は禁止しないが要求もしない

## Log

### 2026-03-14 Finding: 書き換え時の注意点と確立した規約

今回の書き換え作業を通じて確立した規約と、次回以降の修正で参照すべきポイント。

#### Overview の構成

1. 散文で目的を1-2文で述べる
2. run_dir/final_output の定義をバレットリストで記載（workflow skill の場合）
3. session_dir の解決先を1行で記載
4. ステージ固有の制約は各ステージに書く。Overview にはワークフロー全体の目的のみ

#### Stage の構成

1. 散文段落で何をするか、何のツールを使うか、何のアーティファクトを書くかを記述
2. `task(agent_type, model=name):` または `skill(name):` ラベル
3. blockquote (`>`) でサブエージェント向けプロンプトテンプレート
4. `- Output:` バレットでアーティファクトパスと読み手ステージ
5. `- Fault:` バレットで障害対応

#### References ファイルの規約

- H1 タイトルを付ける（`markdownlint-disable-file MD041` は使わない）
- コードブロックで囲まない（AI がそのまま読むため不要）
- 動作指示は SKILL.md 側に残す。references にはフォーマット/テンプレートのみ
- HTML タグ（`<details>` 等）は CLI 環境では機能しないため使わない

#### Placeholder 規約

- `{placeholder}` を使う。`<placeholder>` は HTML と衝突するため禁止
- 例外: CLI コマンドの引数表記 `<arg>` は慣例通り許可

#### Examples の規約

- Knowledge/Transform skill: `- Happy:` / `- Failure:` の1行バレット
- Workflow skill: 同上、または複数パターンの場合は3-4行のシナリオバレット
- スクリプト実行型 skill: bash コードブロックで実行例を記載

#### サブエージェントへの委任時の注意点

- gpt-5.4 は `{placeholder}` をリテラルで例に使う傾向あり。具体値に修正が必要
- 長時間実行のサブエージェント(30分超)は他のサブエージェントの変更を上書きする場合あり
- サブエージェント完了後は必ずファイル内容をスポットチェックする
- references ファイルの H1 有無、コードブロック有無、プレースホルダー記法を確認する

#### 未変換のスキル

- jira-to-issue（単体 skill）
- design-doc-summarizer（単体 skill）
- aws-cdk-development（単体 skill）
- debug-application（単体 skill）
- review-comment-workflow（単体 skill、resolve-comments とは別）

### 2026-03-15 Decision: skills.instructions.md 整理

#### Step 15: 規約追加（9 項目）

- References File Conventions、Placeholder Convention、Autonomous Subagent Design 等を追加
- Examples を 1-3 行制限 + 具体値必須に更新
- TypeScript schema guidance を "avoid" に更新
- K/T 構造を簡素化
- 225 行

#### Step 16: 冗長ルール削除 + 統合

削除 8 件: `## Role` 禁止、Content Scope Constraint、Overview 重複、見出し自由、JSDoc/TypeSpec 禁止、
Fault Handling 重複、K/T 定義重複、K/T 制限記述。
統合 3 件: Frontmatter テンプレート -> Fields、task()/skill() 構文統合、Fault chaining 統合。
doc-standards 準拠: `- Rule:` プレフィックス 34 件を全削除。
Prettier 例外削除、`output_policy` 削除、参照 H1 linter 規約削除。
225 -> 166 行。

#### Step 17-19: テンプレート作成計画

構造:

```text
docs/templates/
├── skill-workflow/
│   ├── SKILL.md
│   └── references/
│       └── output-format.md
└── skill-single-operation/
    ├── SKILL.md
    └── references/
        └── output-format.md
```

- skill-workflow: Execution Flow + Stage 委譲パターン。run_dir/final_output 定義、task()/skill() ラベル + blockquote、output/fault bullet
- skill-single-operation: 委譲なしパターン。Overview + Input/Output + Examples。sub-skill/standalone 共通
- 各テンプレートに references/output-format.md のサンプルを含める
- skills.instructions.md にテンプレートへの参照リンクを追加
- `applyTo` にテンプレートパスを追加して skills instructions が適用されるようにする
- See also: 既存の好例へのリンクを SKILL.md テンプレート内に記載

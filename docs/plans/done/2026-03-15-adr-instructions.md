---
status: DONE
---

# TASK: ADR を管理する instructions を追加

## Prompt

ADR を管理するため @.github/instructions/plan.instructions.md のように adr に関するベストプラクティスや書き方について instructions として管理できるようにしたい。
また、 adr を抽出するときや、更新するときに必要な知識については skills として管理したい。
まずは Ref の資料を確認して ADR 管理のための方法を整理して、どのように管理するかの方針についてまとめて。

## Goal

ADR を管理するための instructions が追加できていること。
必要な skill について整理できていること。

## Ref

- skill の例: `https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/architecture-decision-records/SKILL.md`
- ADR の利用方法の検討資料: `docs/reports/2026-03-15-adr.md`
- 既存テンプレート: `docs/templates/adr.md`
- Plan instructions (参考): `.github/instructions/plan.instructions.md`
- Doc standards (ADR Registry): `.github/instructions/doc-standards.instructions.md`
- Core beliefs: `docs/design/core-beliefs.md`

## Steps

- [x] Step 1: Ref の資料を全て確認し、ADR 管理方針を整理する
- [x] Step 2: ADR テンプレート (`docs/templates/adr.md`) を更新する
- [x] Step 3: ADR instructions (`.github/instructions/adr.instructions.md`) を作成する
- [x] Step 4: ADR 抽出 skill (`adr-extract`) を作成する
- [x] Step 5: `mise run lint` と `mise run format` で検証する

## Verify

- `mise run lint` と `mise run format` が成功すること

## Analysis

### 現状の整理

- `docs/templates/adr.md` が存在するが最小限の構造のみ (DECISION_RECORD, PROBLEM, SOLUTION, IMPACT)
- `docs/adr/` ディレクトリは未作成
- `doc-standards.instructions.md` に ADR の File Registry が定義済み: `[000-Index]-[slug].md`
- ADR 関連の instructions や skills は未作成

### Ref 資料からの知見

#### docs/reports/2026-03-15-adr.md の要点

1. リポジトリに残すべき真実は「実行可能なアーティファクト」と「不変の決定履歴 (ADR)」の 2 つ
2. ADR は Why (なぜその決定をしたか) を記録する不変の履歴
3. ADR に残すかの判断基準 (3 つのテスト):
   - AI の無邪気な最適化テスト: AI が構造を壊してバグを招くか
   - 血の教訓テスト: 過去の痛みを伴って学んだ回避策か
   - 代替表現の可否テスト: インラインコメントで十分か (Yes なら ADR 不要)
4. Deprecated/Superseded な ADR も書き換えずに残す (AI の先祖返り防止)
5. AI Guardrails セクションの推奨

#### 外部 skill 参照からの知見

1. ADR ライフサイクル: Proposed -> Accepted -> Deprecated -> Superseded (+ Rejected)
2. テンプレートは複数パターンあるが、このリポジトリでは Lightweight 寄りが適切
3. ADR 管理のベストプラクティス:
   - 実装前に書く
   - 1-2 ページ以内に収める
   - トレードオフを正直に書く
   - 関連する ADR をリンクする
   - Accepted な ADR は書き換えない (新しい ADR で Supersede する)

### 方針決定

前提: dotfiles で先行開発するが、商用リポジトリへの展開を想定した汎用設計とする。
原則: 必要最小限の構造で始め、運用で不足が判明してから拡張する。

#### 1. ADR テンプレート更新方針

現在のテンプレートを以下に置き換える:

```markdown
---
id: "0000"
status: Proposed
date: YYYY-MM-DD
supersedes: []
---

# ADR-0000: [Short Title]

## Context

Why we needed to make this decision. Background, constraints, and alternatives considered.

## Decision

What we decided and the rationale.

## Consequences

What happens as a result. Include positive, negative, and risks.
```

設計判断:

- Frontmatter: id, status, date, supersedes のみ (tags は運用で不要と判明するまで入れない)
- superseded-by は持たない: 新 ADR の supersedes から逆引きすれば十分
  (Copilot は grep や view で全 ADR を探索可能)
- supersedes の YAML 表記は自由: インライン、複数行、ブロック形式いずれも許容
- Sections は 3 つのみ: Context, Decision, Consequences
- Considered Options は Context に含める (別セクションにしない)
- Risks は Consequences に含める (別サブセクションにしない)

#### 2. Instructions 作成方針

`.github/instructions/adr.instructions.md` を作成:

- `applyTo: "docs/adr/**"` で ADR ファイルに適用
- 構成: Template Compliance, Lifecycle, Naming, Content Rules
- 核となるルール:
  - 不変性: Accepted な ADR は内容を書き換えない (新 ADR で Supersede)
  - ステータス遷移: Proposed -> Accepted/Rejected, Accepted -> Deprecated/Superseded
  - ADR に残すかの判断基準 (3 つのテスト)

#### 3. Skill 作成方針

**A. ADR 抽出 skill (adr-extract)** -- 作成する

- 用途: Plan 完了時や設計議論から ADR を抽出する
- トリガー: ユーザーが「ADR を作成して」「この決定を ADR に残して」と言ったとき
- 動作: コンテキスト (Plan, 会話, コード変更) から ADR テンプレートに沿った文書を生成
- タイプ: Single-operation skill

**B. ADR 更新 skill (adr-update)** -- 不要

- 検討結果: Supersede は新 ADR の supersedes に旧 ID を記載し、旧 ADR の status を変更するだけ
  instructions のルールに従えば手動で十分

結論: **adr-extract** skill のみを作成する。

## Scratchpad

- 既存の doc-standards.instructions.md の File Registry に ADR エントリが既にある
  (`[000-Index]-[slug].md`, template: `docs/templates/adr.md`)
- docs/adr/ ディレクトリは ADR 作成時に自然に作られるため、空ディレクトリは作らない
- copilot-instructions.md の Evolution Discipline と連携:
  設計決定を ADR に残すフローを instructions に組み込む

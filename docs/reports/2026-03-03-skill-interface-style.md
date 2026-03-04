# SKILL.md Interface 記述スタイル方針

## Status

- Draft（未確定）

## 背景

`review-comment-workflow/SKILL.md`（スタイルA: Markdown箇条書き）と
`structured-workflow/SKILL.md`（スタイルB: TypeScript + TypeSpec）で
Interface・手順の記述スタイルが混在している。
3モデルによる Council 審議（2026-03-03）の結果をもとに、
今後の統一方針候補を記録する。

## 現状スタイルの比較

- Style A - Markdown箇条書き
  - Input/Output 型を箇条書きで記述
  - Invariants をバッククォート囲みの擬似コードでインライン記述
  - fault 宣言を各ステップのテキストに直接埋め込み
  - 長所: トークン効率が高い、記述コスト低
  - 短所: 複雑な型構造の表現に曖昧さが残る、構文が書き手に依存する

- Style B - TypeScript + TypeSpec
  - `typescript` ブロックで JSDoc 付き型定義
  - `typespec` ブロックでオペレーション定義
  - `text` ブロックで fault 宣言を各フェーズに分離
  - 長所: 型安全性が高い、構造が明確
  - 短所: TypeSpec は LLM 学習データが少なく認知負荷が高い、JSDoc 記述が冗長

## 推奨候補スタイル: Compact TypeScript + Structured Sections

Council の合意事項:

- TypeSpec ブロックは排除する（LLM 学習データ密度が低く認知負荷が高い）
- 型定義には TypeScript を使用する（Markdown 箇条書きより厳密、TypeSpec より親和性が高い）
- Style A・Style B どちらもそのままでは最適ではない

### Interface セクション

```typescript
// -- Types --
type Input = { session_id: string; question: string };
type Output = { summary: string };

// -- Ops --
declare function gather(input: Input): Facts;
// @fault(empty_result) => fallback: retry_with_broader_scope; continue

declare function evaluate(facts: Facts): EvalResult;
// @fault(conflicting_facts) => fallback: flag_conflict; continue
// @invariant(facts_contain_judgment) => abort("facts-only")

declare function synthesize(eval: EvalResult): Output;
// @fault(low_confidence) => fallback: request_human_review; abort
// @invariant(word_count < 300 || word_count > 600) => revise_length
```

### Execution セクション（Workflow スキルのみ必須）

```text
gather -> evaluate -> synthesize
```

依存関係テーブルは Markdown テーブル形式で記述する（既存規約どおり）。

### 利点

- 単一の `typescript` ブロックで完結し、LLM のパーサ切り替えコストがない
- `declare function` は TypeScript の正式構文であり、入出力型契約が明確
- `@fault` / `@invariant` タグにより制約の局所的対応と機械的検出を両立
- TypeSpec と JSDoc を排除し、Style A 並みのトークン効率を達成

### fault/invariant 記述位置に関する対立と解決

- 操作の直下コメント案（局所対応に優れるが自動検証ツールから不可視のリスク）
- 専用 constraints セクション案（差分監査に優れるが DSL が LLM に不親和）

採用: `@fault` / `@invariant` タグ付きコメントを `declare function` 直下に配置。
タグにより機械的検出可能性を確保しつつ、操作との対応関係を維持する。

## 適用指針

- Knowledge/Transform スキル（単一操作チェーン）
  - 型定義と操作定義のみで十分
  - Execution セクションは省略可能
- Workflow スキル（複数ステージの委譲）
  - Execution セクションと依存関係テーブルを必須とする
- 複合型が 3 フィールドを超える場合は型定義を分離する
- プリミティブ中心の場合はインライン記述を許容する

## 未解決事項

- 既存 SKILL.md（review-comment-workflow、structured-workflow、council など）への
  適用タイミングと優先度は未定
- `@fault` / `@invariant` タグ構文の正式仕様（値の記法、セミコロン区切りなど）は
  実際に適用しながら確定させる

## 参考

- Council 審議アーティファクト:
  `~/.copilot/session-state/38ae5342-987d-4031-9ebf-b6eb684b1a60/files/council-stage5-synthesis-20260303144721.md`
- 対象スキル:
  `.config/copilot/skills/review-comment-workflow/SKILL.md`
  `.config/copilot/skills/structured-workflow/SKILL.md`

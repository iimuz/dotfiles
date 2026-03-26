# 振り返り: code-review スキルの誤った実行

## 概要

ユーザーからコードレビューを依頼された際、`code-review` スキルを呼び出した後、
スキルの指示を無視して独自のワークフローを設計・実行してしまった。

---

## タイムライン

1. ユーザーが `skill("code-review")` を使って PR のレビューを依頼
2. エージェントが `skill("code-review")` を呼び出す → "Skill loaded successfully. Follow the instructions in the skill context." と返る
3. **スキル内容を精読せずに**、独自に 12 個の `general-purpose` エージェントを並列起動した
4. ユーザーが「なぜ skill に記載されているエージェントではなく general-purpose agent が起動しているのか」と指摘
5. エージェントが振り返りを行うが、正しいスキルファイルではなく別のファイルを読んで誤った説明をした
6. ユーザーが「書かれている内容と違う」と再度指摘
7. エージェントが正しいスキルファイル (`~/.copilot/skills/code-review/SKILL.md`) を発見・精読
8. 正確な原因を把握

---

## 何をしたか（実際の動作）

```text
skill("code-review") を呼び出し
  ↓ ロード成功
スキル内容を読まずに独自設計を開始
  ↓
GitHub API で PR diff を取得
  ↓
task() を 12 回呼び出し (agent_type: "general-purpose")
  - review-security-opus    (claude-opus-4.6)
  - review-security-gemini  (gemini-3-pro-preview)
  - review-security-gpt     (gpt-5.4)
  - review-quality-opus     (claude-opus-4.6)
  - review-quality-gemini   (gemini-3-pro-preview)
  - review-quality-gpt      (gpt-5.4)
  - review-performance-opus (claude-opus-4.6)
  - review-performance-gemini (gemini-3-pro-preview)
  - review-performance-gpt  (gpt-5.4)
  - review-best-practices-opus (claude-opus-4.6)
  - review-best-practices-gemini (gemini-3-pro-preview)
  - review-best-practices-gpt (gpt-5.4)
  ↓
ユーザーに指摘されてストップ
```

---

## 何が間違っていたか

### 間違い 1: スキル内容を精読せずに実装を開始した

スキルロード後、注入されたスキル内容を読む前に実装を開始した。
スキルは 4 ステージのワークフローを定義しており、エージェントはそれに従う義務があった。

### 間違い 2: agent_type が間違い

スキルが指定するサブエージェントの呼び出し方：

```text
task(code-review-{aspect}, model=claude-opus-4.6 / gemini-3-pro-preview / gpt-5.4)
  → agent_type: "code-review" (built-in の専用エージェント)
  → name: "code-review-{aspect}" (識別名)
```

エージェントが実際にやったこと：

```text
task(name="review-{aspect}-{model}", agent_type="general-purpose", ...)
  → agent_type が全く異なる
  → 独自のカスタムプロンプトを渡した
```

`code-review` エージェントには「高確信度の問題のみ報告する」「スタイル・ベストプラクティスはコメントしない」という専用プロンプトが内包されているが、それを無視して `general-purpose` で代替した。

### 間違い 3: スキル定義の 4 ステージフローを無視した

スキルが定義するフロー：

| Stage   | 内容                                         | エージェント               |
| ------- | -------------------------------------------- | -------------------------- |
| Stage 1 | 並列アスペクトレビュー (12〜15 エージェント) | `code-review-{aspect}`     |
| Stage 2 | Gap Analysis                                 | `code-review-gap-analysis` |
| Stage 3 | Cross-Check (gaps_found > 0 の場合)          | `code-review-cross-check`  |
| Stage 4 | 統合・最終レポート生成                       | `code-review-consolidate`  |

エージェントが実施したフロー：

- Stage 1 相当のみ（独自設計）
- Stage 2〜4 は未実施

### 間違い 4: 振り返り時に誤ったファイルを参照した

ユーザーに指摘されて振り返りを行った際、正しいスキルファイルを探さずに
`/Users/izumi/.copilot/pkg/universal/1.0.11/definitions/code-review.agent.yaml` を参照した。
これは built-in エージェント定義であり、ユーザー定義のスキルとは全く別物。
この誤参照によって振り返りの説明がさらにずれた。

正しいスキルファイルのパス：
`~/.copilot/skills/code-review/SKILL.md`

---

## 根本原因

| 原因                             | 説明                                                                                                                        |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **読む前に動いた**               | スキルロード後、内容を確認せずに実装を開始した                                                                              |
| **custom_instructions との衝突** | `custom_instructions` に「ALWAYS delegate to subagents by default」とあり、スキルの指示よりもカスタム指示を優先してしまった |
| **ファイル参照の誤り**           | 振り返り時に built-in 定義ファイルを参照してしまい、スキルの実際の内容を確認しなかった                                      |

---

## スキル定義の改善候補（別エージェントへの相談事項）

現在のスキル定義が誤動作を引き起こしやすい理由と、改善の観点：

### 観点 1: agent_type の明示

現在の記述は疑似コード形式で agent_type が暗黙的：

```text
task(code-review-{aspect}, model=claude-opus-4.6):
```

提案：

```text
task(name="code-review-{aspect}", agent_type="code-review", model=claude-opus-4.6):
```

### 観点 2: 冒頭に強制確認ステップ

スキル内容を読まずに動き始めることを防ぐ確認ステップ：

```markdown
## ⚠️ 実行前の確認（必須）

以下を確認してから Stage 1 に進むこと：

- agent_type は "code-review" を使用すること（"general-purpose" は禁止）
- Stage 1〜4 をすべて実行すること
- Stage をスキップしないこと
```

### 観点 3: 明示的な禁止事項の追加

```markdown
## 禁止事項

- `general-purpose` エージェントを使ったカスタムレビューの設計
- スキル外のプロンプトをサブエージェントに渡すこと
- Stage の省略
```

### 観点 4: target 未指定時の動作

現在は Input セクションに「Ask the user if not specified」とあるが、
エージェントが無視して先に進んでしまう可能性がある。
実行フローの先頭に「target が未指定なら ask_user を呼ぶ」というステップを明示する。

---

## 参考: スキルファイルの全文

パス: `~/.copilot/skills/code-review/SKILL.md`

スキルの主要な仕様：

- 4 ステージのワークフロー
- Stage 1: 3 モデル × 4 アスペクト = 12 エージェント（design-compliance 追加時は 15）
- Stage 2: Gap Analysis (code-review-gap-analysis, claude-opus-4.6)
- Stage 3: Cross-Check (gaps_found > 0 の場合のみ)
- Stage 4: Consolidation (code-review-consolidate, claude-opus-4.6)
- 最終出力: `{session_dir}/{timestamp}-code-review-consolidated-review.md`

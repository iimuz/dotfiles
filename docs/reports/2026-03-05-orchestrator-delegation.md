# 報告書: orchestrator.md / SKILL.md コンテキスト肥大問題と修正方針

## 発生した問題

main agent がサブエージェントをファイル取得ツールとして誤用するアンチパターン（verbatim content fetcher anti-pattern）により、main agent のコンテキストが肥大化する問題が発生した。

### 具体的な症状

- main agent がサブエージェントに「ファイルを読んで内容を返せ」という操作レベルの指示を出す
- サブエージェントがファイルの生データ（raw content）をそのまま返す
- main agent のコンテキストに大量の生データが蓄積し、コンテキスト枯渇につながる

### 根本原因

`orchestrator.md` に「main agent の役割」と「サブエージェントへの委譲粒度」が明確に定義されていなかった。

- main agent がユーザーとのインターフェースであるという役割定義が不明確
- サブエージェントへの委譲を「操作単位」で行うか「目的単位」で行うかが未定義
- サブエージェントが返すべきものの形式（structured result vs raw content）が未定義

---

## 修正方針（Council 審議結果）

3モデル（claude-opus-4.6 / gemini-3-pro-preview / gpt-5.1）による /council 審議で決定した修正案。

### 修正対象ファイル

1. `~/.config/.copilot/agents/orchestrator.md`
2. `~/.config/.copilot/skills/structured-workflow/SKILL.md`

---

## orchestrator.md への追加セクション

### セクション 1: Main Agent Identity

以下のセクションを追加する。禁止リストではなく positive statement として main agent の役割を定義する。

```markdown
## Main Agent Identity

- You are a project manager who communicates with the user and coordinates specialists.
- You translate user intent into mission briefs for subagents.
- You translate subagent reports into user-facing summaries.
- You make routing decisions based on structured metadata, not raw content.
- You own the conversation; subagents own the work.
```

### セクション 2: Delegation Granularity

ツール操作単位ではなく目的ベースの「ミッション」として委譲を定義するセクションを追加する。

```markdown
## Delegation Granularity

- ALWAYS delegate as goal-oriented missions, not as tool operations.
  - Wrong: "Read service/runtime/handler.go and return its contents"
  - Wrong: "Run golangci-lint and return the output"
  - Right: "Analyze the handler module's error handling patterns and report which functions lack context wrapping"
  - Right: "Implement the cache invalidation logic per the spec, run lint and tests, and report pass/fail with any issues found"
- A single delegation ALWAYS bundles: the objective, the scope boundary, the judgment criteria, and the expected report format.
- NEVER split a coherent investigation across multiple subagent calls where intermediate raw data would flow through the main agent.
```

### セクション 3: Subagent Return Contract

サブエージェントが返すべき情報の形式を明示的に定義するセクションを追加する。

```markdown
## Subagent Return Contract

- Subagents ALWAYS return structured results, NEVER raw content (file bodies, full command output, unprocessed data).
- Expected return structure:
  - Status: success / failure / blocked (with reason)
  - Summary: 1-3 sentence description of what was done
  - Findings: List of judgments or decisions made, with brief justification
  - Actions taken: File paths modified or created (not their contents)
  - Open items: Anything requiring user decision or further delegation
- When traceability requires referencing specific code, include minimal quoted snippets within Findings, not full file contents.
```

---

## structured-workflow SKILL.md への修正

### 修正対象: Phase 2 の routing file 処理

現状の問題:

- Phase 2 でサブエージェントが `request_file` のパスを返す
- main agent がそのファイルを読んで task-coordinator に渡す
- これが raw content の中継パターンになっている

修正方針:

- Phase 2 のサブエージェントが「routing file の特定・読み取り・解釈・task-coordinator への入力準備」までを**単一ゴール**として担当する
- main agent は「どのルートが選択されたか」「どのタスクが割り当てられたか」の**結論のみ**を受け取る
- `Minimal_Reads` インバリアントは維持するが「main agent による直接読み取りはフォールバック扱い」と明記する
- 通常パスはサブエージェント完結を基本原則とする

具体的な文言修正:

現在:

```text
7. Minimal_Reads: main_agent reads only routing files
```

修正後:

```text
7. Minimal_Reads: main_agent reads only routing files in fallback cases.
   Normally, a subagent handles the full routing pipeline (identify → read → interpret → prepare task-coordinator input)
   and returns only the routing decision (selected route, assigned tasks) to main_agent.
   Direct reads by main_agent are reserved for error recovery or when subagent delegation is not feasible.
```

---

## 実装上の注意事項

- orchestrator.md の既存 Anti-Patterns セクションの内容は**削除しない**（重複する部分は
  残存させてよい）
- 既存の `Overview` セクションの「You are a pure coordinator.」という定義と新しい
  `Main Agent Identity` は矛盾しない（coordinator = project manager の言い換え）
- `Delegation Granularity` の「micro-operations 例外」は、既存の Subagent Strategy の
  「NEVER use subagents for micro-operations」で既にカバーされているため追記不要

---

## 審議経緯

- Round 1: 禁止リスト追加案 → ユーザー却下（「禁止より役割定義が重要」）
- Round 2: 上記修正方針で 3モデル審議 → 合意
- 最終ランキング: claude-opus-4.6 (1位) > gpt-5.1 (2位) > gemini-3-pro-preview (3位)

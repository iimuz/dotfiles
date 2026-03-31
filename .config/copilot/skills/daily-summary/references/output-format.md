# Output Format

The daily summary follows a fixed markdown structure.

## Header

Single date: `# YYYY-MM-DD 作業サマリー`
Date range: `# YYYY-MM-DD - YYYY-MM-DD 作業サマリー`

## Sections

### 完了事項

Synthesize completed work items from session summaries and user messages.
Group items by repository. Use the repository name as a prefix for each item.
Focus on outcomes and deliverables, not on individual tool calls or commands.

Deduplication: When multiple sessions correspond to the same logical task
(retries, continuations, or iterations), merge them into a single entry.
Use the session with the most concrete outcome (most files modified or most
specific summary) as the representative.

Cross-repository grouping: When the same logical task was applied across
multiple repositories (e.g., configuration rollout, dependency update),
group them into a single entry instead of listing each repository separately.
Use a collective description such as "mspf 系 4 リポジトリ: DB deletion
protection の横展開".

Format: `- repo-name: One-line description of the completed work`

### 重要な意思決定

Document significant decisions made during the work.
Include the decision topic and a brief rationale.
Only include decisions that have lasting impact on the codebase or workflow.
If no significant decisions were identified, omit this section entirely.

## Guidelines

- Write in Japanese.
- Do not use emoji in section headers or body text.
- Keep each item to one line.
- Focus on what was accomplished, not how it was done.
- When a session has no summary, infer the purpose from user messages and modified files.
- Omit sessions that produced no meaningful output (empty summaries, no user messages, no file changes).

## Example Output

```md
# 2026-03-31 作業サマリー

## 完了事項

- iimuz/dotfiles: daily-summary skill を作成し、セッションログから日報を自動生成する機能を実装
- iimuz/dotfiles: Copilot skill の設定ファイル整理、モデル利用状況の監査
- iimuz/app-backend: 認証 API のレスポンス形式を統一し、エラーハンドリングを改善

## 重要な意思決定

- daily-summary の出力フォーマット: 定量メトリクスを含めず定性的なサマリーのみとした。日報の可読性を優先するため。
```

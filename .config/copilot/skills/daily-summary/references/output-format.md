# Output Format

The daily summary follows a fixed markdown structure. It consolidates
Copilot session activity, GitHub activity (issues, PRs), and Atlassian
activity (Jira issues, Confluence pages) into a unified report.

## Header

Single date: `# YYYY-MM-DD 作業サマリー`
Date range: `# YYYY-MM-DD - YYYY-MM-DD 作業サマリー`

## Sections

### 完了事項

Synthesize completed work items from session summaries, activity summaries,
and user messages. Group items by repository or Jira project. Use the
repository name or project name as a prefix for each item. Focus on
outcomes and deliverables, not on individual tool calls or commands.

Deduplication: When multiple sessions or activities correspond to the same
logical task (retries, continuations, or iterations), merge them into a
single entry. Use the source with the most concrete outcome (most files
modified, most specific summary, or merged PR) as the representative.

Cross-source merging: When a Copilot session and a GitHub activity (issue
or PR) refer to the same work, merge them into a single entry. Indicators
of overlap include: same repository and branch name, PR/issue number
referenced in session events, similar task descriptions. Prefer the
description that best captures the outcome.

Jira integration: Include Jira issues alongside GitHub items. Use the Jira
project name as the grouping key (equivalent to repository name for GitHub).
When a Jira issue and a GitHub activity or Copilot session refer to the
same work (e.g., Jira issue key referenced in a PR or session), merge them
into a single entry.

Confluence integration: Standalone documentation work (page creation,
significant updates) appears as its own item. Meeting notes and planning
pages that provide context for other work items should be merged into those
items rather than listed separately.

Cross-repository grouping: When the same logical task was applied across
multiple repositories (e.g., configuration rollout, dependency update),
group them into a single entry instead of listing each repository separately.
Use a collective description such as "mspf 系 4 リポジトリ: DB deletion
protection の横展開".

Format:

- GitHub: `- repo-name: One-line description of the completed work`
- Jira: `- project-name (ISSUE-KEY): One-line description`
- Confluence: `- [Confluence] page-title: One-line description`

### 進行中の事項

List issues and PRs that remain open at the end of the period and had
meaningful activity during the period. Include the current status and
next expected action.

Only include this section if there are open items with activity. Omit
if all work items were completed or if open items had no meaningful
activity during the period.

Format:

- GitHub: `- repo-name: One-line description (status)`
- Jira: `- project-name (ISSUE-KEY): One-line description (status)`

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
- Omit activities where the user had no direct involvement during the period (only mentioned or subscribed).
- When merging Copilot session and GitHub activity into one entry, use the
  combined context to write a richer description than either source alone
  would provide.
- When merging Jira and GitHub/session activities, prefer the description
  that combines the most context from all sources.
- Confluence meeting notes should enrich related work items rather than
  appearing as separate entries, unless the page itself represents
  standalone documentation work.

## Example Output

```md
# 2026-03-31 作業サマリー

## 完了事項

- iimuz/dotfiles: daily-summary skill を作成し、セッションログから日報を自動生成する機能を実装
- iimuz/dotfiles: Copilot skill の設定ファイル整理、モデル利用状況の監査
- iimuz/app-backend: 認証 API のレスポンス形式を統一し、エラーハンドリングを改善 (PR#42 をマージ)
- iimuz/infra: Terraform state のバックエンド移行 PR を作成しレビュー対応中 (PR#15)
- Team A (Team-15): repository-a の Feature Freeze のタスク整理
- [Confluence] meetng-a: 議事録作成、PoC 要件とスプリント計画を整理

## 進行中の事項

- iimuz/app-backend: パフォーマンス改善の調査 Issue (#55、次回ベンチマーク実施予定)
- Team A (Team-16): repository-b の Feature Freeze のタスク整理

## 重要な意思決定

- daily-summary の出力フォーマット: 定量メトリクスを含めず定性的なサマリーのみとした。日報の可読性を優先するため。
- PoC: 運用機能の開発を一時停止し、デモ向け開発に舵を切る方針を決定
```

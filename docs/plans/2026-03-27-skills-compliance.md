---
issue:
---

# TASK: Skills Instructions Compliance

## Goal

Fix skill violations against skills.instructions.md and resolve rule gaps.

## Ref

- `.github/instructions/skills.instructions.md`
- `.config/copilot/skills/`

## Steps

### A. Rule Review (instructions 側の見直し)

- [x] Step A1: Rule 2 (References) — protocol 系を許容する。実需優先、リスク低い
- [x] Step A2: Rule 3 (Workflow nesting) — meta-orchestrator パターンを許容する
- [x] Step A3: Rule 1 (Description) — description を修正する方針
- [ ] Step A4: skills.instructions.md を A1/A2 の決定に基づいて改定

### B. Frontmatter 修正

- [ ] Step B1: `gh-pr-create` — `user-invocable`, `disable-model-invocation` 追加
- [ ] Step B2: `jira-to-issue` — `user-invocable`, `disable-model-invocation` 追加
- [ ] Step B3: `qmd` — `allowed-tools` をスペース区切りに修正

### C. Description 修正 (Rule 1)

A3 の判断結果に基づいて実施。

- [ ] Step C1: `adr-extract` — trigger phrase 追加、語数調整
- [ ] Step C2: `beads` — trigger phrase 追加、語数調整
- [ ] Step C3: `code-review` — trigger phrase 追加、語数調整
- [ ] Step C4: `commit-staged` — trigger phrase 追加、語数調整
- [ ] Step C5: `council` — trigger phrase 追加、caller metadata 削除、語数調整
- [ ] Step C6: `gh-issue-comment` — trigger phrase 追加
- [ ] Step C7: `gh-pr-resolve` — trigger phrase 追加
- [ ] Step C8: `gh-pr-review` — trigger phrase 追加、語数調整
- [ ] Step C9: `implementation-plan` — trigger phrase 追加、語数調整
- [ ] Step C10: `qmd` — trigger phrase 追加、語数大幅削減
- [ ] Step C11: `structured-workflow` — trigger phrase 追加、caller metadata 削除、語数調整
- [ ] Step C12: `task-coordinator` — trigger phrase 追加、語数調整
- [ ] Step C13: `tdd-workflow` — trigger phrase 追加、語数調整

### D. ~~References 修正 (Rule 2)~~ — A1 で protocol 許容のため不要

### E. ~~Workflow Nesting 修正 (Rule 3)~~ — A2 で nesting 許容のため不要

## Verify

`mise run lint && mise run format`

## Log

Append-only record of decisions and findings during execution.

## Scratchpad

Agent workspace for investigation notes.

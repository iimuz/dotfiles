---
name: work-sessions
description: Read-only access to markdown work-session files to list, view, and search session records.
---

# Work Sessions

## Contract

- Read-only skill (editing is done directly)
- Use only the scripts shipped with this skill
- All commands require --root <path> to locate <root>/.agent/work-sessions
- <filename> inputs MUST be provided without .md extension
- Avoid network calls

## Workflow

### セッション一覧の取得

List all sessions in the work-sessions directory:

```bash
python3 scripts/list.py --root <root>
```

### セッション内容の取得

Read a specific session file:

```bash
# セッション内容の全体を確認する場合
python3 scripts/read.py --root <root> 20260109_implement_auth

# セッション内容の概要（description）のみを確認する場合
python3 scripts/read.py --root <root> 20260109_implement_auth --description
```

### セッション横断検索

Search for a keyword across all sessions:

```bash
python3 scripts/search.py --root <root> "JWT"
```

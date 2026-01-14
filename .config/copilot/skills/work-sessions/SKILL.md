---
name: work-sessions
description: Manage markdown work-session files in .agent/work-sessions to save, resume, search, and update progress across Copilot or LLM sessions.
---

# Work Sessions

## Contract

- Use only the scripts shipped with this skill (do not read and edit memory file)
- All commands require --root <path> to locate <root>/.agent/work-sessions
- <filename> / <task_slug> inputs MUST be provided without .md extension
- Avoid network calls.

## Workflow

### 既存のセッションの確認

1. List sessions: `python3 scripts/list.py --root <root>`
2. Read a session.

   ```bash
   # セッション内容の全体を確認する場合
   python3 scripts/read.py --root <root> 20260109_implement_auth

   # セッション内容の概要を確認する場合
   python3 scripts/read.py --root <root> 20260109_implement_auth --description
   ```

### Create a new session

Store each session as `{task_slug}` where `task_slug` is snake_case ASCII.

```bash
python3 scripts/create.py --root <root> implement_auth --title "implement auth" --description "Implement JWT auth"
```

### Update a session

Update front matter values:

```bash
python3 scripts/update.py --root <root> 20260109_implement_auth --description "Implement JWT auth (token issuance done)"
```

Replace a section (keep its heading):

```bash
python3 scripts/replace.py --root <root> 20260109_implement_auth --section "Summary" --content "Did X\nDid Y"
```

Insert a new section:

```bash
# 特定のセクションの前に追加する場合
python3 scripts/insert.py --root <root> 20260109_implement_auth --new-section "Progress" --level 2 --content "- Done A\n- Done B" --before "Summary"

# 特定のセクションの後に追加する場合
python3 scripts/insert.py --root <root> 20260109_implement_auth --new-section "Progress" --level 2 --content "- Done A\n- Done B" --after "Summary"

# 末尾にセクションを追加する場合
python3 scripts/insert.py --root <root> 20260109_implement_auth --new-section "Progress" --level 2 --content "- Done A\n- Done B"
```

Delete a section:

```bash
python3 scripts/delete.py --root <root> 20260109_implement_auth --section "Progress"
```

### Search across sessions

```bash
python3 scripts/search.py --root <root> "JWT"
```

### Delete a session

```bash
python3 scripts/delete.py --root <root> 20260109_implement_auth
```

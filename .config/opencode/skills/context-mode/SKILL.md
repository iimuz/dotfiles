---
name: context-mode
description: >
  Route shell, file reads, HTTP, and data analysis through context-mode MCP tools (ctx_ prefix)
  to protect the context window. Activate when context-mode is connected or on "ctx" commands.
metadata:
  verified-with: context-mode 1.0.169
---

# context-mode — local routing policy

The `ctx_*` MCP tool descriptions already state what each tool does and when to reach for it.
They are supplied by the installed server, so they never go stale. This file holds only what
they leave out: what using them costs here, and the facts of this setup.

## Cost model — decide Bash vs sandbox first

`ctx_execute` and `ctx_execute_file` echo the submitted script back as a fenced code block ahead
of stdout. A script is therefore paid for twice: once as the generated tool call, and again as
the echoed result, which stays in context for the rest of the session.

- Short output (under ~20 lines: `git status`, `ls`, `wc -l`, a version flag) belongs in plain
  Bash. Wrapping it in `ctx_execute` costs more than it saves.
- When an existing CLI already yields a compact answer (`gh --jq`, `jq`, `grep -c`,
  `sort | uniq -c`), run that command. Do not re-implement it as a script.
- Reserve sandbox scripts for substantial work: transforming data on disk, analyzing many files,
  aggregating output whose size cannot be predicted.
- Write the script once, with `try/catch` and null handling, and print only the answer. A short
  script resent in trial and error is the most expensive pattern available.

Language choice: `javascript` for HTTP and JSON, `python` for CSV and statistics, `shell` for
pipes over native tools.

## This setup

- No context-mode routing hooks are installed. Nothing intercepts `curl`, `wget`, `WebFetch`, or
  oversized Bash output, so route them by choice: web content through `ctx_fetch_and_index` then
  `ctx_search`, unpredictable output through the sandbox.
- Nothing is injected into subagent prompts either. A subagent that should route through
  context-mode has to be told so in its prompt.
- Tools are registered as `mcp__context-mode__ctx_execute` and so on. Upstream documents write
  them bare as `ctx_execute`.
- The server version is pinned as `npm:context-mode` in `.config/mise/config-*.toml`.

## ctx commands

| Command       | Action                                                                     |
| ------------- | -------------------------------------------------------------------------- |
| `ctx stats`   | Call `ctx_stats`, display full output verbatim                             |
| `ctx doctor`  | Call `ctx_doctor`, run the returned shell command, display as a checklist  |
| `ctx upgrade` | Call `ctx_upgrade`, run the returned shell command, display as a checklist |
| `ctx insight` | Call `ctx_insight`, which opens the hosted dashboard in the browser        |
| `ctx purge`   | Call `ctx_purge` with confirm: true. It wipes the knowledge base           |

The knowledge base and session stats survive /clear and /compact. Use `ctx purge` to start fresh.

## Upstream documents

The installed package ships its own routing rules and pattern references. Read them when a
detailed example is needed, rather than copying them into this file. Resolve the location as
follows; `-maxdepth` must come before the other `find` predicates.

```bash
P=$(find "$(mise where npm:context-mode)" -maxdepth 4 -type l -name context-mode \
  -path '*/node_modules/*' | head -1)
R=$(readlink -f "$P")
```

- `$R/configs/claude-code/CLAUDE.md` — upstream routing rules for Claude Code.
- `$R/skills/context-mode/SKILL.md` — upstream skill. Its default is the opposite of the cost
  model above: it routes every command through the sandbox. Prefer this file's policy.
- `$R/skills/context-mode/references/` — anti-patterns and per-language patterns.

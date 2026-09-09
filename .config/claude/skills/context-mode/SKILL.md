---
name: context-mode
description: >-
  Use when running any shell command, reading a file for analysis, searching the
  codebase, fetching a URL, or analyzing or transforming data, while the context-mode
  MCP server (ctx_ tools) is connected. Also use on "ctx" commands such as ctx stats
  or ctx doctor.
metadata:
  upstream: context-mode 1.0.169
  notes: >-
    Derived from configs/claude-code/CLAUDE.md and skills/context-mode/SKILL.md shipped in
    the context-mode npm package (https://github.com/mksglu/context-mode). Re-review this
    file when the mise-pinned context-mode version changes.
---

# context-mode — routing rules

context-mode MCP tools (`ctx_*`) are available. These rules protect the context window from
flooding: one unrouted command can dump 56 KB into context. Tool names below are the bare MCP
names (`ctx_execute`); the harness registers them as `mcp__context-mode__ctx_execute` and so on.

## Cost model — decide Bash vs sandbox first

- `ctx_execute` and `ctx_execute_file` echo the submitted script back as a fenced code block
  before stdout. The script is paid for twice: once when generated as the tool call, and again
  as the echoed result that stays in context for the rest of the session.
- The most expensive pattern is a short script sent repeatedly in trial and error.
  Write the script once, with `try/catch` and null handling, and print only the answer.
- Short output (under ~20 lines: `git status`, `ls`, `wc -l`, `node --version`) → plain Bash.
  Wrapping it in `ctx_execute` costs more than it saves.
- An existing CLI already yields a compact answer (`gh --jq`, `jq`, `grep -c`, `sort | uniq -c`)
  → run that command. Do not re-implement it as a script.
- Reserve `ctx_execute` scripts for substantial work: transforming data on disk, analyzing many
  files, aggregating outputs whose size cannot be predicted.

## Think in Code

Analyze/count/filter/compare/search/parse/transform data: **write code** via
`ctx_execute(language, code)` and print only the answer. Do NOT read raw data into context.
PROGRAM the analysis, not COMPUTE it.

Language selection:

| Situation                 | Language     | Why                                   |
| ------------------------- | ------------ | ------------------------------------- |
| HTTP/API calls, JSON      | `javascript` | native fetch, JSON.parse, async/await |
| Data analysis, CSV, stats | `python`     | csv, statistics, collections, re      |
| Pipes over native tools   | `shell`      | grep, awk, jq, find, sort, uniq       |

Pass `intent` when output may be large: outputs over ~5 KB are indexed and only section
previews come back; retrieve with `ctx_search`.

## Do not use — route through context-mode instead

Whether these are intercepted depends on the installed hooks; follow the rule regardless.

- Shell `curl` / `wget` and `WebFetch` → `ctx_fetch_and_index(url, source)` then
  `ctx_search(queries)`. Raw HTML never enters context.
- Inline HTTP in the main context (`fetch('http`, `requests.get(`, `http.get(`) →
  `ctx_execute(language: "javascript", code: "const r = await fetch(...)")`.

## Redirected — use the sandbox

- **Shell with more than ~20 lines of output**: Bash is for `git`, file mutations
  (`mkdir`, `rm`, `mv`), navigation, package install, and short observational commands.
  Otherwise use `ctx_batch_execute(commands, queries)` or `ctx_execute`.
- **File reading**: reading to **edit** → normal Read. Reading to **analyze/explore/summarize**
  → `ctx_execute_file(path, language, code)`.
- **grep / search with large results**: run it inside `ctx_execute` and print counts or the
  matching lines you need.

## Tool selection

1. **GATHER**: `ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns
   matching sections. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — all questions as an array, ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` —
   sandbox, only stdout (plus the script echo) enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)`.
5. **INDEX**: `ctx_index(path, source)` — store a file in FTS5 for later search. Use the
   `content` parameter only for small text you compose yourself; large content would pass
   through context as a parameter.

## Parallel I/O batches

For 3+ network commands (`gh`, cloud APIs, multi-repo git reads) pass `concurrency: 4-8` to
`ctx_batch_execute`. Keep `concurrency: 1` for CPU-bound or stateful commands (tests, builds,
lint, port binding, lock files). Cap at 4 for `gh` to respect the GitHub API rate limit.

## ctx commands

| Command       | Action                                                                            |
| ------------- | --------------------------------------------------------------------------------- |
| `ctx stats`   | Call `ctx_stats` MCP tool, display full output verbatim                           |
| `ctx doctor`  | Call `ctx_doctor` MCP tool, run returned shell command, display as checklist      |
| `ctx upgrade` | Call `ctx_upgrade` MCP tool, run returned shell command, display as checklist     |
| `ctx insight` | Call `ctx_insight` MCP tool; it opens the hosted Insight dashboard in the browser |
| `ctx purge`   | Call `ctx_purge` MCP tool with confirm: true. Warns before wiping knowledge base. |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

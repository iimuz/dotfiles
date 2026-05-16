---
name: qmd
description: Search markdown knowledge bases, notes, and documentation using QMD. Use when users ask to search notes, find documents, or look up information.
license: MIT
allowed-tools: Bash(qmd:*), mcp__qmd__*
compatibility: Requires qmd CLI or MCP server.
metadata:
  author: tobi
  version: "2.0.0"
  notes: |
    `qmd skill show` で表示される文言で CLI に関するものと、 `qmd -h` で出力される内容を元に修正している。
---

# QMD - Quick Markdown Search

Local search engine for markdown content.

## Status

`qmd status`

If no GPU is available (running on CPU), use only the `qmd search` command.
Avoid `qmd query` and `qmd vsearch` — they will be very slow without GPU acceleration.

## Query

QMD queries are either a single expand query (no prefix) or a multi-line
document where every line is typed with lex:, vec:, or hyde:. This grammar
matches the docs in docs/SYNTAX.md and is enforced in the CLI.

### Grammar

- query: `expand_query | query_document ;`
- expand_query: `text | explicit_expand ;`
- explicit_expand: `"expand:" text ;`
- query_document: `[ intent_line ] { typed_line } ;`
- intent_line: `"intent:" text newline ;`
- typed_line: `type ":" text newline ;`
- type: `"lex" | "vec" | "hyde" ;`
- text: `quoted_phrase | plain_text ;`
- quoted_phrase: `'"' { character } '"' ;`
- plain_text: `{ character } ;`
- newline: `"\n" ;`

#### Query Types

| Type   | Method | Input                                       |
| ------ | ------ | ------------------------------------------- |
| `lex`  | BM25   | Keywords — exact terms, names, code         |
| `vec`  | Vector | Question — natural language                 |
| `hyde` | Vector | Answer — hypothetical result (50-100 words) |

### Examples

```sh
qmd query "how does auth work"                      # single-line → implicit expand
qmd query $'lex: CAP theorem\nvec: consistency'     # typed query document
qmd query $'lex: "exact matches" sports -baseball'  # phrase + negation lex search
qmd query $'hyde: Hypothetical answer text'         # hyde-only document
qmd query $'expand: question'     # Explicit expand
qmd query --json --explain "q"    # Show score traces (RRF + rerank blend)
qmd search "keywords"             # BM25 only (no LLM)
qmd get "#abc123"                 # By docid
qmd multi-get "journals/2026-*.md" -l 40  # Batch pull snippets by glob
qmd multi-get notes/foo.md,notes/bar.md   # Comma-separated list, preserves order
```

### Constraints

- Standalone expand queries cannot mix with typed lines.
- Query documents allow only lex:, vec:, or hyde: prefixes.
- Each typed line must be single-line text with balanced quotes.

### Search options

```sh
-n <num>                   - Max results (default 5, or 20 for --files/--json)
--all                      - Return all matches (pair with --min-score)
--min-score <num>          - Minimum similarity score
--full                     - Output full document instead of snippet
-C, --candidate-limit <n>  - Max candidates to rerank (default 40, lower = faster)
--no-rerank                - Skip LLM reranking (use RRF scores only, much faster on CPU)
--line-numbers             - Include line numbers in output
--explain                  - Include retrieval score traces (query --json/CLI)
--files | --json | --csv | --md | --xml  - Output format
-c, --collection <name>    - Filter by one or more collections
```

### Embed/query options

```sh
--chunk-strategy <auto|regex> - Chunking mode (default: regex; auto uses AST for code files)
```

### Multi-get options

```sh
-l <num>                   - Maximum lines per file
--max-bytes <num>          - Skip files larger than N bytes (default 10240)
--json/--csv/--md/--xml/--files - Same formats as search
```

## Writing Good Queries

### lex (keyword)

- 2-5 terms, no filler words
- Exact phrase: `"connection pool"` (quoted)
- Exclude terms: `performance -sports` (minus prefix)
- Code identifiers work: `handleError async`

### vec (semantic)

- Full natural language question
- Be specific: `"how does the rate limiter handle burst traffic"`
- Include context: `"in the payment service, how are refunds processed"`

### hyde (hypothetical document)

- Write 50-100 words of what the _answer_ looks like
- Use the vocabulary you expect in the result

### expand (auto-expand)

- Use a single-line query (implicit) or `expand: question` on its own line
- Lets the local LLM generate lex/vec/hyde variations
- Do not mix `expand:` with other typed lines — it's either a standalone expand query or a full query document

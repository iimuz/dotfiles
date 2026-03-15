---
id: "0001"
status: Accepted
date: 2026-03-15
supersedes: []
---

# ADR-0001: ADR に superseded-by フィールドを持たない

## Context

ADR のライフサイクル管理では、ある ADR が別の ADR に置き換えられたとき、
双方向リンク (supersedes / superseded-by) を持つ方式と、
片方向リンク (supersedes のみ) で逆引きする方式がある。

双方向リンクは整合性が明確だが、Supersede 時に 2 ファイルの内容を同期する
保守コストが発生する。片方向リンクでは新 ADR の supersedes フィールドのみ
記載し、逆引きは `grep` や `view` で実行する。

Copilot を含む AI エージェントは grep や view でリポジトリ全体を探索可能なため、
明示的な逆リンクがなくても関連 ADR を特定できる。

## Decision

ADR の frontmatter に superseded-by フィールドを持たない。
新 ADR の supersedes フィールドのみで親子関係を管理し、
逆引きは `grep` 等のツールで行う。

## Consequences

旧 ADR を Supersede する際の編集が status 変更のみに限定され、
不変性ルールとの整合性が高まる。双方向リンクの同期ミスが発生しない。
一方、特定の ADR を Supersede した ADR を探すには grep が必要になるが、
AI エージェントにとっては実質的な制約にならない。
YAML の記法 (インライン、ブロック等) に依存せず、
ファイル全文検索で確実に逆引きできる。

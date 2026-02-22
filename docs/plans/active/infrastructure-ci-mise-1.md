---
title: GitHub Actions CI での mise グローバル設定除外
plan_id: PLAN-001
version: 1.0
status: Planned
status_color: blue
created: 2026-02-22
updated: 2026-02-22
author: Multi-Agent Synthesis
reviewers: [claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex]
related_plans: []
tags: [infrastructure, ci, mise, github-actions]
---

# GitHub Actions CI での mise グローバル設定除外

![Planned](https://img.shields.io/badge/Status-Planned-blue)

## Context

このリポジトリは dotfiles と CI 対象プロジェクトを同居させており、ルートの `mise.toml`（CI 用ツール）と `.config/mise/config.toml`（開発者ローカル用ツール）が同時に存在します。GitHub Actions の `jdx/mise-action` は `mise install` を実行し、mise の設定探索ロジックに従ってワークスペース配下の候補設定を解決するため、CI 実行時にも `.config/mise/config.toml` が読み込まれます。

その結果、CI は lint に不要な `aws-vault` や `lua` など開発者向けツールの導入を試行し、ジョブ失敗を引き起こします。問題は「グローバル設定ファイル」そのものではなく、チェックアウト済みワークスペース内の設定がプロジェクト文脈で発見される点にあり、CI では対象パスを明示的に除外する必要があります。

## Objectives

- OBJ-001: CI で `.config/mise/config.toml` を読み込ませない。
- OBJ-002: CI で root `mise.toml` のみを有効にして `mise run lint` を安定実行する。

## Scope

**In Scope:**
- `.github/workflows/ci.yml` の `lint` ジョブへの環境変数追加。
- `MISE_IGNORED_CONFIG_PATHS` による除外パス指定。

**Out of Scope:**
- `mise.toml` および `.config/mise/config.toml` の内容変更。
- 開発者ローカルセットアップスクリプトの変更。
- CI 以外のワークフロー改修。

## Success Criteria

- CRIT-001: CI が `.config/mise/config.toml` 由来ツールのインストールを試行しない。
- CRIT-002: `mise run lint` が root `mise.toml` のツールだけで成功する。

## Requirements

| Req ID | Type | Description | Priority | Status |
|--------|------|-------------|----------|--------|
| REQ-001 | Functional | CI で `.config/mise/config.toml` を mise 設定探索対象から除外する | Critical | Defined |
| REQ-002 | Functional | CI で root `mise.toml` に定義された lint ツールのみを利用する | Critical | Defined |
| REQ-003 | Non-Functional | 変更範囲を `.github/workflows/ci.yml` の最小差分に限定する | High | Defined |

## Architecture Overview

GitHub Actions では `actions/checkout` 後に `jdx/mise-action` が実行され、内部で mise を用いたツール解決・インストールが行われます。mise は実行ディレクトリ文脈で設定候補を評価するため、リポジトリ内の `.config/mise/config.toml` も候補に入り、root `mise.toml` と併用される構成になります。

このため、`MISE_GLOBAL_CONFIG_FILE` のような「グローバル設定先だけを変える」方法では不十分です。`MISE_IGNORED_CONFIG_PATHS` でワークスペース内の対象ファイルを絶対パスで除外し、`jdx/mise-action` と後続の `mise run lint` が同じ除外条件を共有することで、CI だけを安全に分離します。

## Design Decisions

| Decision ID | Description | Rationale | Alternatives Considered |
|-------------|-------------|-----------|------------------------|
| DEC-001 | `MISE_IGNORED_CONFIG_PATHS` に `${{ github.workspace }}/.config/mise/config.toml` の絶対パスを設定する | ローカル検証で相対パス指定は不一致になり得る一方、絶対パスは確実に一致し、ワークスペース内の当該ファイルのみを精密に除外できるため | `MISE_GLOBAL_CONFIG_FILE=/dev/null`（プロジェクト文脈の検出を止められない）、相対パス `.config/mise/config.toml`（一致不確実）、CI でファイル削除（ワークスペース改変が増える） |

## Technical Stack

- **Tools**: mise, jdx/mise-action, GitHub Actions
- **Files**: `.github/workflows/ci.yml`

## Implementation Phases

### PHASE-1: CI Workflow Fix

**Completion Criteria:**
- `lint` ジョブに `MISE_IGNORED_CONFIG_PATHS` が追加され、値が `${{ github.workspace }}/.config/mise/config.toml` になっている。
- 追加後も既存ステップ（checkout, mise-action, run lint）の順序と内容が維持されている。

**Tasks:**

| Task ID | Description | Files Modified | Dependencies | Owner | Status |
|---------|-------------|----------------|--------------|-------|--------|
| TASK-001 | `lint` ジョブに `env` ブロックを追加し、`MISE_IGNORED_CONFIG_PATHS: ${{ github.workspace }}/.config/mise/config.toml` を設定する（以下の before/after の完全一致で変更） | `.github/workflows/ci.yml` | None | Dev | Not Started |

**TASK-001 Exact YAML Change (`.github/workflows/ci.yml`):**

```yaml
# Before
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - uses: jdx/mise-action@c37c93293d6b742fc901e1406b8f764f6fb19dac # v2.4.4

      - name: Run Lint
        run: mise run lint

# After
jobs:
  lint:
    runs-on: ubuntu-latest
    env:
      MISE_IGNORED_CONFIG_PATHS: ${{ github.workspace }}/.config/mise/config.toml
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - uses: jdx/mise-action@c37c93293d6b742fc901e1406b8f764f6fb19dac # v2.4.4

      - name: Run Lint
        run: mise run lint
```

**Validation:**

- VAL-001: CI ログで `.config/mise/config.toml` 由来ツール（aws-vault, lua, tree-sitter-cli など）の導入試行が消えることを確認する。
- VAL-002: `mise run lint` が成功し、ジョブ全体が green になることを確認する。

## Dependencies

### External Dependencies

| Dep ID | Description | Type | Status | Impact if Unavailable |
|--------|-------------|------|--------|-----------------------|
| DEP-001 | mise `MISE_IGNORED_CONFIG_PATHS` support | External | Available | Must use alternative approach |

### Internal Dependencies

| Dep ID | From Task | To Task | Type | Status |
|--------|-----------|---------|------|--------|

(None)

## Risks & Mitigation

| Risk ID | Description | Probability | Impact | Mitigation Strategy | Owner |
|---------|-------------|-------------|--------|---------------------|-------|
| RISK-001 | 将来の mise バージョンで環境変数名 `MISE_IGNORED_CONFIG_PATHS` が変更・廃止される | Low | High | mise リリースノート監視を運用に追加し、失効時は CI で `rm -f .config/mise/config.toml` の前処理を一時適用して復旧する | Dev |

## Testing Strategy

### Integration Tests

| Test ID | Components | Scenario | Status |
|---------|------------|----------|--------|
| INT-001 | CI workflow | PR 実行で `lint` ジョブが `.config/mise/config.toml` を無視して成功することを確認する | Not Started |

## Rollout Plan

### Deployment Phases

| Phase | Environment | Percentage | Duration | Rollback Trigger |
|-------|-------------|------------|----------|------------------|
| 1 | GitHub Actions | 100% | Immediate | CI failure |

### Rollback Procedure

1. Remove the `env:` block added to the lint job
2. Revert `.github/workflows/ci.yml` to previous state

## Documentation Updates

| Doc ID | Document | Changes Required | Owner | Status |
|--------|----------|------------------|-------|--------|
| DOC-001 | None | No documentation changes needed | Dev | Not Started |

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| mise | Polyglot tool manager |
| jdx/mise-action | GitHub Action for setting up mise |
| MISE_IGNORED_CONFIG_PATHS | mise env var to exclude specific config files |
| XDG_CONFIG_HOME | XDG Base Directory for user config files |

## Appendix B: References

- mise documentation: https://mise.jdx.dev/
- jdx/mise-action: https://github.com/jdx/mise-action
- GitHub Actions context: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs

## Appendix C: Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-22 | Multi-Agent Synthesis | Initial version |

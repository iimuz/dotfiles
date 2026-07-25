---
id: "0003"
status: Accepted
date: 2026-07-25
supersedes: []
---

# ADR-0003: CI 通過を条件とした自動マージ

## Context

Issue #282 に基づき、依存更新(Renovate)を CI(lint/test)の通過をもって自動マージ
したい。各環境で動作させないと結果が分からないため、major 以外の更新は自動マージし、
major 更新のみユーザーの確認後に手動でマージする方針とする。

CI は `.github/workflows/ci.yml` の `lint` / `test` の2ジョブで、`pull_request` 時に
実行される。自動マージを CI 通過でゲートするには、リポジトリの auto-merge 有効化と、
master のブランチ保護(必須ステータスチェック)が必要になる。これらはファイル管理
できないリポジトリ設定である。

## Decision

- Renovate の `platformAutomerge` を用いて GitHub ネイティブ auto-merge を使用する。
  週次スケジュールに依存せず、CI 通過時点で GitHub 側が即マージする。
- `renovate.json` で非メジャー(patch/minor)を automerge 対象とし、major は手動マージ
  とする。Node.js major・Python minor(=major 相当)は従来通り手動とする。
- master にブランチ保護を設定し、必須ステータスチェック `lint` / `test` を要求する。
  PR を必須(承認数 0)とし、管理者もバイパス不可とする。

## Consequences

- 非メジャー更新は CI 通過で自動マージされ、手作業が減る。
- major 更新は CI 通過を前提にユーザーが手動でマージする。
- master への直接 push は不可となり、全変更が PR + CI を経由する。
- ブランチ保護の有効化後は、本方針を導入する PR を含む全 PR で `lint` / `test` の
  通過が必須になる。
- GitHub 設定はファイル管理外のため、以下の手順で適用する。

適用手順:

    # 1. リポジトリの auto-merge を有効化
    gh api repos/iimuz/dotfiles -X PATCH -F allow_auto_merge=true

    # 2. master のブランチ保護
    #    (必須チェック lint/test, PR 必須・承認0, 管理者も対象, strict 無効)
    gh api -X PUT repos/iimuz/dotfiles/branches/master/protection --input - <<'JSON'
    {
      "required_status_checks": { "strict": false, "contexts": ["lint", "test"] },
      "enforce_admins": true,
      "required_pull_request_reviews": { "required_approving_review_count": 0 },
      "restrictions": null
    }
    JSON

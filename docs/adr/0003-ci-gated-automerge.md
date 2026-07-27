---
id: "0003"
status: Accepted
date: 2026-07-25
supersedes: []
---

# ADR-0003: CI 通過を条件とした自動マージ

## Context

Issue #282 に基づき、依存更新(Renovate)を CI の通過をもって自動マージ
したい。各環境で動作させないと結果が分からないため、major 以外の更新は自動マージし、
major 更新のみユーザーの確認後に手動でマージする方針とする。

CI は `.github/workflows/ci.yml` の `lint` / `test` / `format` の3ジョブを
`pull_request` 時に実行する。自動マージを CI 通過でゲートするには、リポジトリの
auto-merge 有効化と、master のブランチ保護(必須ステータスチェック)が必要になる。
必須チェックをジョブ名で個別指定するとジョブの追加・改名で保護が漏れるため、全ジョブ
の成否を集約する単一ジョブ `status-check` を追加し、それを必須チェックとする。
auto-merge 有効化とブランチ保護はファイル管理できないリポジトリ設定だが、集約ジョブ
自体は ci.yml で管理する。

## Decision

- Renovate の `platformAutomerge` を用いて GitHub ネイティブ auto-merge を使用する。
  週次スケジュールに依存せず、CI 通過時点で GitHub 側が即マージする。
- `renovate.json` で非メジャー(patch/minor)を automerge 対象とし、major は手動マージ
  とする。Node.js major・Python minor(=major 相当)は従来通り手動とする。
- CI に集約ジョブ `status-check` を追加し、`lint` / `test` / `format` が全て成功した
  ときのみ成功する(`if: !cancelled()` と `needs` の結果検査で判定)。master のブランチ保護
  では、この `status-check` のみを必須ステータスチェックとして要求する。PR を必須
  (承認数 0)とし、管理者もバイパス不可とする。

## Consequences

- 非メジャー更新は CI 通過で自動マージされ、手作業が減る。
- major 更新は CI 通過を前提にユーザーが手動でマージする。
- master への直接 push は不可となり、全変更が PR + CI を経由する。
- ブランチ保護の有効化後は、本方針を導入する PR を含む全 PR で `status-check`
  (= `lint` / `test` / `format` の全通過)が必須になる。
- CI ジョブを追加・改名しても、必須チェックは集約ジョブ `status-check` のままでよく、
  ブランチ保護の再設定は不要(集約ジョブの `needs` を更新すればよい)。
- GitHub 設定はファイル管理外のため、以下の手順で適用する。

適用手順:

    # 1. リポジトリの auto-merge を有効化
    gh api repos/iimuz/dotfiles -X PATCH -F allow_auto_merge=true

    # 2. master のブランチ保護
    #    (必須チェック status-check, PR 必須・承認0, 管理者も対象, strict 無効)
    gh api -X PUT repos/iimuz/dotfiles/branches/master/protection --input - <<'JSON'
    {
      "required_status_checks": { "strict": false, "contexts": ["status-check"] },
      "enforce_admins": true,
      "required_pull_request_reviews": { "required_approving_review_count": 0 },
      "restrictions": null
    }
    JSON

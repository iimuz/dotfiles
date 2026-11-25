# dotfiles

各種設定ファイルを保存しています。

## 環境構築

各環境での構築はインストールスクリプトを利用して下記のように実行します。
Mac と aarch64 では、構築した環境の更新に `update_*.sh` を使います。
aarch64 では、再取得や再生成ができるキャッシュを `cleanup_aarch64.sh` で sudo なしに掃除します。

- Mac: `bash setup_mac.sh`, `bash update_mac.sh`
- Linux
  - aarch64: `bash setup_aarch64.sh`, `bash update_aarch64.sh`, `bash cleanup_aarch64.sh`
    - Orca のクライアントは、service を止めずに `orca-ide pair` でペアリングします。
      Android は `orca-ide pair --mobile --address "$(tailscale ip -4)"`、
      Mac は ssh で LocalForward を張ってから `orca-ide pair --address 127.0.0.1` です。
- Android/Termux: `bash setup_termux.sh`

### Claude Code 用 playwright-cli

Claude Code の同梱スキル `playwright-cli` は `setup_*.sh` 実行時に
`playwright-cli install --skills --global` で生成し、リポジトリには置きません。
CLI は同梱スキルが古くなっても警告しません。renovate が `@playwright/cli` の
minor 更新を自動マージするため、0.x 系のバージョンアップは気づかないうちに適用されます。
バージョンが上がったら `setup_mac.sh` (Linux は `setup_aarch64.sh` または
`update_aarch64.sh`) を再実行して同梱スキルを追従させてください。

Linux の setup では playwright 管理の chromium を新規に導入するため、
数百 MB のダウンロードが発生します。

## Development

このリポジトリを修正するコントリビューター向けの情報です。

### Setup

mise が必要です。

```bash
mise run setup
```

内部で `mise install` と `lefthook install` を実行します。

### Linting and Formatting

各コミット時に lefthook を通じて以下のツールが自動実行されます。

- shfmt: Shell script formatter (`*.sh`)
- shellcheck: Shell script linter (`*.sh`)
- taplo: TOML formatter (`*.toml`)
- prettier: Markdown formatter (`*.md`)
- markdownlint-cli2: Markdown linter (`*.md`)

> Note: Formatters apply changes automatically and re-stage the corrected files.
> Linters will block the commit if issues are found.

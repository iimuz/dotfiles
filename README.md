# dotfiles

各種設定ファイルを保存しています。

## 環境構築

各環境での構築はインストールスクリプトを利用して下記のように実行します。

- Mac: `bash setup_mac.sh`, `bash update_mac.sh`
- Linux
  - aarch64: `bash setup_aarch64.sh`, `bash update_aarch64.sh`
- Android/Termux: `bash setup_termux.sh`

### Mac の更新とキャッシュの掃除

`update_mac.sh` は、再起動の後、ほかのアプリを開く前にターミナルから実行します。
brew の sudo に答える必要があり、掃除と同じキャッシュを使うプロセスがまだ動いていないためです。

brew、gh の拡張を更新し、mise の古いバージョンと、uv と npm のキャッシュの使っていない分を毎回消します。
前回の週 1 回の掃除が成功してから 7 日以上経っていれば、pnpm のストアとキャッシュ、Go のモジュールキャッシュ、uv、npm、mise のキャッシュと、名指しした個別のキャッシュを全部消します。
週 1 回の掃除の成功は `~/.local/state/dotfiles/update-mac-weekly-cleanup` に記録しています。
すぐに週 1 回の掃除を行いたいときは、このファイルを消してから実行します。

### Claude Code 用 playwright-cli

Claude Code の同梱スキル `playwright-cli` は `setup_*.sh` 実行時に
`playwright-cli install --skills --global` で生成しており、リポジトリでは追跡しません。
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

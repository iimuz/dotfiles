# dotfiles

- Description: 各種設定ファイルを保存しています。

## 環境構築

- Description: 各環境での構築はインストールスクリプトを利用して下記のように実行します。

- Mac: `bash setup_mac.sh`
- Linux
  - aarch64: `bash setup_aarch64.sh`, `bash update_aarch64.sh`
- Codespaces: `bash setup_codespaces.sh`
- Android/Termux:
  - termux: `bash setup_termux.sh`
  - termux + proot: `bash setup_proot_arm64.sh`
- WSL: `bash setup_wsl_ubuntu.sh`

- Description: 各環境におけるパッケージ管理について下記に記載します。

### Windows

- Package_Manager: [scoop](https://scoop.sh/)
- Install:

```ps1
# scoopのインストール(詳細は公式ドキュメントを参照)
irm get.scoop.sh | iex
# scoopを利用したソフトウェアの一括インストール
scoop import .config/scoop/scoopfile.json
```

- Export:

```ps1
scoop export > .config/scoop/scoopfile.json
```

## Development

- Description: For contributors who modify this repository.

### Setup

- Requirement: [mise](https://mise.jdx.dev/)
- Install:

```bash
mise install
lefthook install
```

### Linting and Formatting

- Description: On each commit, the following tools run automatically via lefthook.
- shfmt: Shell script formatter (`*.sh`)
- shellcheck: Shell script linter (`*.sh`)
- taplo: TOML formatter (`*.toml`)
- prettier: Markdown formatter (`*.md`)
- markdownlint-cli2: Markdown linter (`*.md`)
- Note: Formatters apply changes automatically and re-stage the corrected files.
  Linters will block the commit if issues are found.

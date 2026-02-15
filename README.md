# dotfiles

各種設定ファイルを保存しています。

## 環境構築

各環境での構築はインストールスクリプトを利用して下記のように実行します。

- Mac: `bash setup_mac.sh`
- Linux
  - aarch64: `bash setup_aarch64.sh`, `bash update_aarch64.sh`
- Codespaces: `bash setup_codespaces.sh`
- Android/Termux:
  - termux: `bash setup_termux.sh`
  - termux + proot: `bash setup_proot_arm64.sh`
- WSL: `bash setup_wsl_ubuntu.sh`

各環境におけるパッケージ管理について下記に記載します。

### Windows

[scoop](https://scoop.sh/)を利用してソフトウェアのインストールを行います。
scoopを利用した環境構築方法を下記に記載します。

```ps1
# scoopのインストール(詳細は公式ドキュメントを参照)
irm get.scoop.sh | iex
# scoopを利用したソフトウェアの一括インストール
scoop import .config/scoop/scoopfile.json
```

ソフトウェアを追加した場合は下記のコマンドでscoopfileを更新します。

```ps1
scoop export > .config/scoop/scoopfile.json
```

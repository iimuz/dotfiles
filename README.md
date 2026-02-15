# dotfiles

各種設定ファイルを保存しています。

## 環境構築

各環境での構築はインストールスクリプトを利用して下記のように実行します。

- Linux/Mac: `bash setup.sh`
- Windows: TBD

各環境におけるパッケージ管理について下記に記載します。

### Mac (Apple Silicon)

[homebrew](https://brew.sh/)を利用してソフトウェアのインストールを行います。
また、インストールしたソフトウェアの一覧などの管理は [homebrew-bundle](https://github.com/Homebrew/homebrew-bundle) を利用します。
homebrew + homebrew bundleを利用した環境構築方法を下記に記載します。

```sh
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# homebrew buundleを利用してソフトウェアを一括でインストール
# homebrew bundleは関連コマンドを実行した初回に自動でインストールされるので明示的に実施しない
brew bundle
```

インストールするソフトウェアおよび各ソフトウェアのTipsは下記になります。

- [bat](https://github.com/sharkdp/bat)
- [bitwarden-cli](https://github.com/bitwarden/clients)
- [exa](https://github.com/ogham/exa)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [git](https://github.com/git/git): [tips](https://iimuz.github.io/scrapbook/zettelkasten/scrapbook-20221127091453/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [tmux](https://github.com/tmux/tmux)

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

インストールするソフトウェアおよび各ソフトウェアに対するTipsは下記になります。

- [git](https://github.com/git/git): [tips](https://iimuz.github.io/scrapbook/zettelkasten/scrapbook-20221127091453/)
- [neovim](https://github.com/neovim/neovim)
- [scoop](https://scoop.sh/): [tips](https://iimuz.github.io/scrapbook/zettelkasten/scrapbook-20221217120338/)
- [vscode](https://github.com/microsoft/vscode)
- [windows terminal](https://github.com/microsoft/terminal)

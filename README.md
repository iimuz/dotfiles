# dotfiles

各種設定ファイルを保存しています。

インストールの実行は、 scripts フォルダの下にあるファイルを利用してください。
インストールおよび設定ファイルのリンクを実行します。

例えば、下記のように実行すると gcloud のインストールと設定ファイルを追加します。

```sh
sh scripts/gcloud.sh
. ~/.bashrc
```

## 環境構築

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

# dotfiles

## Usage

### setup wsl

debianを選択した場合に、wslの環境を構築するためのスクリプトです。
初期状態からは下記のようにして初期化します。

```bash
$ sudo apt update && sudo apt upgrade && sudo apt install -y --no-install-recommends ca-certificates curl
$ curl https://github.com/iimuz/dotfiles/blob/master/setup-wsl_debian.sh | sh
```

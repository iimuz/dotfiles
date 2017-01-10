# OSを特定します
OS_MAC="Mac"
if [ "$(uname)" == 'Darwin' ]; then
  OS=$OS_MAC
fi

# homebrewのための設定
if [ $OS == $OS_MAC ]; then
  export PATH=/usr/local/bin/:/usr/local/sbin/:$PATH
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi

# bashrcを読みに行く
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi


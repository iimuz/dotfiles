# homebrewのための設定
export PATH=/usr/local/bin/:/usr/local/sbin/:$PATH
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# bashrcを読みに行く
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi


# OSを特定します
OS_MAC="Mac"
OS_WIN="Win"
if [ "$(uname)" == 'Darwin' ]; then
  OS=$OS_MAC
elif [ "$expr substr $(uname -s) 1 7)" == "MSYS_NT" ]; then
  OS=$OS_WIN
fi

# etcのbashrcを読み込む
# Mac & Linux
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi
# MSYS2
if [ $OS == $OS_WIN ]; then
  if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
  fi
fi


# Macの場合にhomebrewで自動的にbrew-fileをアップデートするようにする
if [ $OS == $OS_MAC ]; then
  if [ -f $(brew --prefix)/etc/brew-wrap ]; then
    . $(brew --prefix)/etc/brew-wrap
  fi
fi


# プロンプトの表示形式を設定
if [ $OS == $OS_MAC ]; then
  PS1="[\u@\h \W]\$"
fi


# alias
if [ $OS == $OS_MAC ]; then
  alias ls='ls -G'  # lsを色付きにする
fi



# homebrewのための設定
export PATH=/usr/local/bin/:/usr/local/sbin/:$PATH
export HOMEBREW_CASK_OPTS="--appdir=/Applications"


# rbenv settings
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"


# pyenv-virtualenv settings
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
  export PATH=${PYENV_ROOT}/bin:$PATH
  eval "$(pyenv init -)"
fi


# bashrcを読みに行く
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

#!/bin/bash
#
# Copy settings files from https://github.com/junegunn/fzf

FZF_CONFIG=$HOME/.config/fzf
FZF_COMPLETION=$FZF_CONFIG/completion.bash
FZF_KEYBINDINGS=$FZF_CONFIG/key-bindings.bash

# tmux がインストールされていれば、 fzf の選択ウィンドウに tmux を利用する。
if type tmux > /dev/null 2>&1; then
  export FZF_TMUX=1
fi

# fzf でコマンドの補完を行う
if [ -f $FZF_COMPLETION ]; then . $FZF_COMPLETION 2> /dev/null; fi

# fzf のキーバインドを利用する
if [ -f $FZF_KEYBINDINGS ]; then . $FZF_KEYBINDINGS; fi



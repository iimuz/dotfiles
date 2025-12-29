#!/bin/bash
#
# Copy settings files from https://github.com/junegunn/fzf

# Gurad if command does not exist.
if ! type fzf >/dev/null 2>&1; then return 0; fi

if type brew >/dev/null 2>&1; then
  FZF_CONFIG=${HOMEBREW_PREFIX}/opt/fzf/shell
else
  FZF_CONFIG=${FZF_CONFIG:-$HOME/.config/fzf}
fi
if [[ "$SHELL" == *zsh* ]]; then
  FZF_COMPLETION="$FZF_CONFIG/completion.zsh"
  FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.zsh"
else
  FZF_COMPLETION="$FZF_CONFIG/completion.bash"
  FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.bash"
fi
# proot環境ではkey-bindingsの位置が異なるので修正
if [[ "$(uname -r)" == *proot* ]]; then
  FZF_CONFIG="/usr/share/doc/fzf/examples"
  FZF_COMPLETION="/usr/share/bash-completion/completions/fzf"
  FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.bash"
fi
# termux環境ではkey-bindingsの位置が異なるので修正
if [[ "$(uname -r)" == *android* ]]; then
  FZF_CONFIG="/data/data/com.termux/files/usr/share/fzf"
  FZF_COMPLETION="$FZF_CONFIG/completion.bash"
  FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.bash"
fi
# oracle(ubuntu24.04)でのkeybindings
if [[ "$(uname -r)" == *oracle* ]]; then
  if [[ "$SHELL" == *zsh* ]]; then
    FZF_CONFIG="/usr/share/doc/fzf/examples"
    FZF_KEYBINDINGS="$FZF_CONFIG/completion.zsh"
    FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.zsh"
  else
    # bash
    FZF_CONFIG="/usr/share/doc/fzf/examples"
    FZF_KEYBINDINGS="/usr/share/bash-completion/completions/fzf"
    FZF_KEYBINDINGS="$FZF_CONFIG/key-bindings.bash"
  fi
fi

# Use tmux for selecting window if tmux exists..
# tmuxがない場合は明示的に無効化する。macなどでarm64, amd64の切り替えをするときに環境がないのに有効化される。
# if type tmux > /dev/null 2>&1; then
#   export FZF_TMUX=1
# else
#   export FZF_TMUX=0
# fi
# tmuxを有効化するとfzfでCtrl+Rでコマンド選択した場合にtmuxウィンドウが停止する場合があったため、無効化する。
export FZF_TMUX=0

# Use fzf completion.
if [ -f $FZF_COMPLETION ]; then . $FZF_COMPLETION 2>/dev/null; fi
# Use fzf keybindings.
if [ -f $FZF_KEYBINDINGS ]; then . $FZF_KEYBINDINGS; fi

# Aliases.
# Find repositories under golang directory structure
alias ffghq='cd $(find ${SOURCE_ROOT:-$HOME/src} -follow  -maxdepth 3 -mindepth 3 -type d | fzf)'

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
# Ref: https://github.com/junegunn/fzf/wiki/examples#searching-file-contents
fif() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi
  rg --files-with-matches -i --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# find in file with hidden files.
# find-in-file-with-hidden-file - usage: fifh <searchTerm>
fifh() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi
  rg --hidden --files-with-matches -i --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Open the selected file with the default editor
fo() {
  local file
  file=$(fif "")
  if [ -n "$file" ]; then ${EDITOR:-vim} $file; fi
}

# Find file with hidden, and open the selected file with the default editor
foh() {
  local file
  file=$(fifh "")
  if [ -n "$file" ]; then ${EDITOR:-vim} $file; fi
}

# combine find in file and file open.
# find-in-file-and-open-it - usage: fog <searchTerm>
fog() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi

  local file
  file=$(fif $@)
  if [ -n "$file" ]; then ${EDITOR:-vim} $file; fi
}

# combine find in file and file open.
# find-in-file-with-hidden-file-and-open-it - usage: fog <searchTerm>
fogh() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi

  local file
  file=$(fifh $@)
  if [ -n "$file" ]; then ${EDITOR:-vim} $file; fi
}

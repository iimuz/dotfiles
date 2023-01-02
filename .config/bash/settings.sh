#!/bin/bash
#
# Common settings for bash.

# Get script path.
script_path="${BASH_SOURCE:-$0}"
if [ -L "$script_path" ]; then script_path=$(readlink -f "$script_path"); fi
script_dir=$(cd $(dirname "$script_path"); pwd)
dotconfig_dir=$(readlink -f "$script_dir/..")

# Set prompt color.
color_prompt=yes
force_color_prompt=yes

# Set bash_history setting.
export HISTCONTROL=ignoreboth:erasedups
shopt -u histappend
save_history="history -n; history -w; history -c; history -r"
if [[ ";$PROMPT_COMMAND;" != *";$save_history;"* ]]; then
  export PROMPT_COMMAND="$save_history; $PROMPT_COMMAND"
fi

# Load other setting files.
aliases_path="$script_dir/aliases.sh"
if [ -f "$aliases_path" ]; then source "$aliases_path"; fi

xdg_path="$script_dir/xdg-base.sh"
if [ -f "$xdg_path" ]; then source "$xdg_path"; fi

x11_path="$script_dir/x11.sh"
if [ -f "$x11_path" ]; then source "$x11_path"; fi

bw_path="$dotconfig_dir/bitwarden/settings.sh"
if [ -f "$bw_path" ]; then source "$bw_path"; fi

fzf_path="$dotconfig_dir/fzf/fzf.bash"
if [ -f "$fzf_path" ]; then source "$fzf_path"; fi

git_path="$dotconfig_dir/git/settings.sh"
if [ -f "$git_path" ]; then source "$git_path"; fi

homebrew_path="$dotconfig_dir/homebrew/homebrew-bundle.sh"
if [ -f "$homebrew_path" ]; then source "$homebrew_path"; fi

node_path="$dotconfig_dir/npm/npm.sh"
if [ -f "$node_path" ]; then source "$node_path"; fi

vscode_path="$dotconfig_dir/vscode/vscode.sh"
if [ -f "$vscode_path" ]; then source "$vscode_path"; fi

# Setup script.

set -eu

# Create symlink if link does not exist.
function create_symlink() {
  local readonly src=$1
  local readonly dst=$2

  if [ -e $2 ]; then
    echo "already exist $2"
    return 0
  fi

  echo "symlink $1 to $2"
  mkdir -p $(dirname "$dst")
  ln -s $src $dst
}

# Add loading file in .bashrc or .zshrc.
function set_bashrc() {
  local readonly filename="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local readonly rcfile="$HOME/.zshrc"
  else
    # bashを想定している
    local readonly rcfile="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep $filename -l $rcfile >/dev/null 2>&1; then
    echo "already setting in $rcfile: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in $rcfile: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >>$rcfile
}

# === 共通パスの設定
readonly SCRIPT_DIR=$(
  cd $(dirname ${BASH_SOURCE:-0})
  pwd
)
readonly CONFIG_PATH=$SCRIPT_DIR/.config

# === Install [homebrew](https://brew.sh/index_ja)
if ! type brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# === Install softwaare
# homebrewを利用するための設定を追記して再読み込み
# set_bashrc $CONFIG_PATH/homebrew/homebrew-bundle.sh
# if [[ "$SHELL" == *zsh* ]]; then
#   # zshを利用しているので設定ファイルが異なる
#   echo "Use zsh"
#   source ~/.zshrc
# else
#   echo "Use bash"
#   # bashを想定している
#   source ~/.bashrc
# fi
# # homebrewを利用して各種ソフトウェアをインストール
# brew bundle

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc $CONFIG_PATH/rc-settings.sh
# === git
if type alacritty >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
fi
# === bash
if type bash >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.inputrc $HOME/.inputrc
fi
# === claude
# claudeはaliasで登録されているため直接指定する必要がある
if type $HOME/.claude/local/claude >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/claude/agents $HOME/.claude/agents
  create_symlink $SCRIPT_DIR/.config/claude/commands $HOME/.claude/commands
  create_symlink $SCRIPT_DIR/.config/claude/settings.json $HOME/.claude/settings.json
  create_symlink $SCRIPT_DIR/.config/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
fi
# === gemini cli
if type $HOME/.claude/local/claude >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/gemini/settings.json $HOME/.gemini/settings.json
  create_symlink $SCRIPT_DIR/.config/gemini/GEMINI.md $HOME/.gemini/GEMINI.md
fi
# === git
if type gh >/dev/null 2>&1; then
  gh extension install dlvhdr/gh-dash
  create_symlink $SCRIPT_DIR/.config/gh-dash/config.yml $HOME/.config/gh-dash/config.yml

  gh extension install kmtym1998/gh-prowl
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
  create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/lazygit/config.yml $HOME/.config/lazygit/config.yml
fi
# === mise
if type mise >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/mise/config.toml $HOME/.config/mise/config.toml
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/nvim $HOME/.config/nvim
  create_symlink $SCRIPT_DIR/.config/nvim/mcphub $HOME/.config/mcphub
fi
# === tmux
if type tmux >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vifm/vifmrc $HOME/.config/vifm/vifmrc
fi
# === vim
if type vim >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vim/init.vim $HOME/.vimrc
  create_symlink $SCRIPT_DIR/.config/vim $HOME/.config/vim
fi
# === vscode
if type code >/dev/null 2>&1; then
  # Copilot
  create_symlink $SCRIPT_DIR/.config/vscode/instructions $HOME/.vscode/instructions
  create_symlink $SCRIPT_DIR/.config/vscode/prompts $HOME/.vscode/prompts
  # Cline
  create_symlink $SCRIPT_DIR/.config/cline/Rules $HOME/Documents/Cline/Rules
fi

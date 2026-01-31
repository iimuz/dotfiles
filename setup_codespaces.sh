# Setup script.

set -eu
set -o pipefail

# Create symlink if link does not exist.
function create_symlink() {
  local -r SRC=$1
  local -r DST=$2

  if [ -e "$DST" ]; then
    echo "already exist $DST"
    return 0
  fi

  echo "symlink $SRC to $DST"
  mkdir -p "$(dirname "$DST")"
  ln -s "$SRC" "$DST"
}

# Add loading file in .bashrc or .zshrc.
function set_bashrc() {
  local -r FILENAME="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local -r RCFILE="$HOME/.zshrc"
  else
    # bashを想定している
    local -r RCFILE="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep "$FILENAME" -l "$RCFILE" >/dev/null 2>&1; then
    echo "already setting in $RCFILE: $FILENAME"
    return 0
  fi

  # Add file path.
  echo "set load setting in $RCFILE: $FILENAME"
  echo -e "if [ -f \"${FILENAME}\" ]; then . \"${FILENAME}\"; fi\n" >>"$RCFILE"
}

# === 共通パスの設定
SCRIPT_DIR=
SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE:-0}")"
  pwd
)
readonly SCRIPT_DIR
readonly CONFIG_PATH=$SCRIPT_DIR/.config

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc $CONFIG_PATH/rc-settings.sh
# === gh
if type gh >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/gh-dash/config.yml $HOME/.config/gh-dash/config.yml
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
  create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
  create_symlink $SCRIPT_DIR/.config/git/credential-gh-helper $HOME/.local/bin/credential-gh-helper
fi
# === github copilot cli
if type copilot >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/copilot/agents $HOME/.config/.copilot/agents
  create_symlink $SCRIPT_DIR/.config/copilot/skills $HOME/.config/.copilot/skills
  create_symlink $SCRIPT_DIR/.config/copilot/mcp-config.json $HOME/.config/.copilot/mcp-config.json
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/lazygit/config.yml $HOME/.config/lazygit/config.yml
fi
# === [mise](https://github.com/jdx/mise)
if type mise >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/mise/config-codespaces.toml $HOME/.config/mise/config.toml
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/nvim $HOME/.config/nvim
fi
# === starship
if ! type starship >/dev/null 2>&1; then curl -sS https://starship.rs/install.sh | sudo sh; fi
# === tmux
if type tmux >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vifm/vifmrc $HOME/.config/vifm/vifmrc
fi

#!/usr/bin/env bash
# Setup script.

set -eu
set -o pipefail

# === 共通パスの設定
SCRIPT_DIR=
SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE:-0}")"
  pwd
)
readonly SCRIPT_DIR
readonly CONFIG_PATH=$SCRIPT_DIR/.config

# Load shared helper functions
. "$SCRIPT_DIR/lib/setup-common.sh"

# === Require homebrew
if [ ! -x /opt/homebrew/bin/brew ]; then
  echo "Homebrew is required. Install it first: https://brew.sh/" >&2
  exit 1
fi

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"

# === bash
if type bash >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.inputrc" "$HOME/.inputrc"
fi

# === claude
if type claude >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  create_symlink "$SCRIPT_DIR/.config/claude/skills" "$HOME/.claude/skills"
  # settings.json は sandbox を on にした場合に symlink だと bubblewrap が起動できなくなるので hard link
  create_hardlink "$SCRIPT_DIR/.config/claude/settings.json" "$HOME/.claude/settings.json"
  create_symlink "$SCRIPT_DIR/.config/claude/hooks" "$HOME/.claude/hooks"
  create_symlink "$SCRIPT_DIR/.config/claude/statusline.py" "$HOME/.claude/statusline.py"
  create_symlink "$SCRIPT_DIR/.config/sandbox-runtime/.srt-settings.json" "$HOME/.srt-settings.json"

  # Setup MCP
  # qmd の rerank を使う検索は HTTP の MCP の既定の 60 秒を超えるので timeout を延ばす
  add_claude_mcp qmd '{"type":"http","url":"http://localhost:8181/mcp","timeout":180000}'

  # Setup Plugins
  claude plugins install --scope user gopls-lsp
  claude plugins install --scope user lua-lsp
  claude plugins install --scope user pyright-lsp
  claude plugins install --scope user rust-analyzer-lsp
  claude plugins install --scope user typescript-lsp
  claude plugins install --scope user superpowers@claude-plugins-official

  claude plugin marketplace add "awslabs/agent-plugins"
  claude plugin install "deploy-on-aws@agent-plugins-for-aws"
  claude plugin disable "deploy-on-aws@agent-plugins-for-aws"

  # Setup playwright-cli skills
  # 同梱スキルは CLI のバージョンに連動するため、リポジトリで管理せず毎回生成する
  if type playwright-cli >/dev/null 2>&1; then
    playwright-cli install --skills --global
  fi
fi
# === gh
if type gh >/dev/null 2>&1; then
  gh extension install kmtym1998/gh-prowl
  gh extension install github/gh-stack
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
  create_symlink "$SCRIPT_DIR/.config/git/credential-gh-helper" "$HOME/.local/bin/credential-gh-helper"
fi
# === ghostty
create_symlink "$SCRIPT_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
# === herdr
if type herdr >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === mise
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-common.toml" "$HOME/.config/mise/config.toml"
  create_symlink "$SCRIPT_DIR/.config/mise/config-mac.toml" "$HOME/.config/mise/config.local.toml"
  # create_symlink は既存のリンクを張り替えないので、リンクが共通のファイル以外を指していると共通のツールが読み込まれない
  if [ "$(readlink "$HOME/.config/mise/config.toml")" != "$SCRIPT_DIR/.config/mise/config-common.toml" ]; then
    echo "WARNING: ~/.config/mise/config.toml does not link to config-common.toml; remove it and rerun" >&2
  fi
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
  # create_symlink "$SCRIPT_DIR/.config/nvim/mcphub" "$HOME/.config/mcphub"
fi
# === orca
# Brewfile の cask が入れる CLI の名前は、Linux の deb と違って orca である
if type orca >/dev/null 2>&1; then
  # ~/.claude/skills は claude の節で symlink にするので、この節はその後に置く。
  # symlink でないと Orca の link がこのリポジトリの外に置かれ、普通のディレクトリを作ると後で symlink を張れないので入れない。
  # mac には skill の update 手順を置かない。Orca アプリが自身の更新の後とウィンドウを開いたときに、手を入れていない copy を同梱版に置き換える
  if [ -L "$HOME/.claude/skills" ]; then
    orca skills install --skill orca-cli --skill orchestration
  fi
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vifm/vifmrc" "$HOME/.config/vifm/vifmrc"
fi
# === vim
if type vim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vim/init.vim" "$HOME/.vimrc"
  create_symlink "$SCRIPT_DIR/.config/vim" "$HOME/.config/vim"
fi
# === vivify
if type vivify-server >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vivify" "$HOME/.config/vivify"
fi

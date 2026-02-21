# ARCHITECTURE

## DEPLOYMENT_STRATEGY

- Method: Symlink-based deployment
- Entry: `create_symlink src dst` - creates symlink only if destination does not exist
- Directory: `mkdir -p $(dirname dst)` before symlinking
- Condition: Deploy only when target tool is detected

## SHELL_INTEGRATION

- Entry: `set_bashrc` filename - adds conditional sourcing to `~/.bashrc` or `~/.zshrc`
- Guard: grep check prevents duplicate entries
- Pattern: `if [ -f "filename" ]; then . "filename"; fi`

## CONFIGURATION_LOADING

- Bootstrap: `.config/rc-settings.sh` loads all tool configurations
- Order: shell basics - homebrew - mise - applications - language environments - path post-processing
- Detection: `${BASH_SOURCE[0]}` for bash, `$0` for zsh

## PLATFORM_SUPPORT

- MacosArm64: `setup_mac.sh`, Homebrew with brew bundle
- LinuxArm64: `setup_aarch64.sh`, apt with manual tool installs
- Codespaces: `setup_codespaces.sh`, Homebrew-based
- ProotArm64: `setup_proot_arm64.sh`, apt with custom install functions
- Termux: `setup_termux.sh`, pkg install
- WslUbuntu: `setup_wsl_ubuntu.sh`, apt-based without Homebrew

## TOOL_CONFIGURATION_PATTERN

- Location: `.config/{tool}/` directory per tool
- Settings: `{tool}-settings.sh` for environment variables and shell integration
- Config: Tool-specific config files (config.toml, config.yml)

## PACKAGE_MANAGEMENT

- Homebrew: `HOMEBREW_BUNDLE_FILE` set by `.config/homebrew/homebrew-bundle.sh`
- Brewfile: macOS ARM64 only
- Scoop: `.config/scoop/scoopfile.json` for Windows

## KEY_CONFIGURATION_AREAS

- Neovim: Lua configuration with plugins and keymaps in `.config/nvim/`
- Shell: Separate bash/zsh configs with shared aliases and commands
- Languages: Isolated settings for Python, Node, Go, Ruby
- DevTools: Git, mise for version management

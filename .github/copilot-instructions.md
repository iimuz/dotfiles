## Environment Setup Commands

**Initial Setup:**

- `bash setup_mac.sh` - Main setup for Mac environments
- `bash setup_aarch64.sh` - ARM64 Linux setup with custom package installations
- `bash setup_codespaces.sh` - GitHub Codespaces environment-specific setup
- `bash setup_proot_arm64.sh` - PRoot ARM64 environment setup with custom installations
- `bash setup_termux.sh` - Android Termux environment setup
- `bash setup_wsl_ubuntu.sh` - WSL Ubuntu-specific setup with x86_64 optimizations

**Maintenance:**

- `bash update_aarch64.sh` - Update packages on ARM64 systems (apt, gh extensions, mise)

**Package Management:**

- `brew bundle` - Install packages using platform-specific Brewfile
- `brew bundle dump` - Export currently installed packages to Brewfile
- `scoop import .config/scoop/scoopfile.json` - Install Windows packages via Scoop
- `scoop export > .config/scoop/scoopfile.json` - Export Windows packages

## Architecture Overview

This is a cross-platform dotfiles repository using a symlink-based deployment strategy with conditional tool-specific configurations.

### Core Setup Architecture

**Setup Scripts Pattern:**

- All setup scripts use identical `create_symlink()` and `set_bashrc()` helper functions
- Tool detection via `type command > /dev/null 2>&1` before creating configurations
- Shell detection (`$SHELL == *zsh*`) for conditional .zshrc vs .bashrc modifications
- Platform-specific package installation (Homebrew, apt, pkg, manual installs)

**Configuration Loading:**

- Central bootstrap via `.config/rc-settings.sh` which loads all tool configurations
- Ordered loading: shell → homebrew → applications → language environments → path finalization
- Shell compatibility layer using `${(%):-%N}` (zsh) vs `$BASH_SOURCE` (bash) detection

### Platform-Specific Package Management

**Homebrew Bundle System:**

- Environment detection in `.config/homebrew/homebrew-bundle.sh` sets `HOMEBREW_BUNDLE_FILE`
- Platform-specific Brewfile: `Brewfile` (macOS ARM64 only)
- Only macOS Apple Silicon (ARM64) environment is supported for Homebrew

**Package Installation Patterns:**

- **setup_mac.sh**: Homebrew-based with `brew bundle` automation
- **setup_aarch64.sh**: apt-based with custom installations (lazygit, neovim, yq via curl/wget)
- **setup_codespaces.sh**: Homebrew-based for GitHub Codespaces environment
- **setup_proot_arm64.sh**: Mixed apt + manual installations with custom functions
- **setup_termux.sh**: `pkg install` for Android/Termux packages
- **setup_wsl_ubuntu.sh**: apt-based with custom installations (lazygit, neovim, yq); does NOT use Homebrew

### Configuration Structure

**Tool Configuration Pattern:**
Each tool has its own directory in `.config/` with:

- `{tool}-settings.sh` - Environment variables and shell integration
- Configuration files (e.g., `config.toml`, `config.yml`)
- Tool-specific setup logic

**Key Configuration Areas:**

- **Neovim**: Extensive Lua configuration with custom plugins and keymaps in `.config/nvim/`
- **Shell Environments**: Separate bash/zsh configurations with shared aliases and commands
- **Language Environments**: Isolated settings for Python (pyenv, poetry), Node (nvm), Go, Ruby, etc.
- **Development Tools**: Git, Docker (Colima), mise/asdf for version management

### Symlink Deployment Strategy

**Symlink Creation Rules:**

- `create_symlink src dst` - Only creates if destination doesn't exist
- Directory creation via `mkdir -p $(dirname "$dst")` before symlinking
- Conditional deployment based on tool availability detection

**Shell Integration:**

- `set_bashrc filename` - Adds conditional sourcing to ~/.bashrc or ~/.zshrc
- Prevents duplicate entries via `grep` check before appending
- Pattern: `if [ -f "filename" ]; then . "filename"; fi`

## File Modification Guidelines

**When modifying setup scripts:**

- Maintain the `create_symlink()` and `set_bashrc()` function signatures across all scripts
- Always check tool availability with `type command > /dev/null 2>&1` before configuration
- Follow the conditional installation pattern for missing tools

**When adding new tools:**

1. Create `.config/{tool}/` directory with settings file
2. Add tool detection and symlink creation to appropriate setup script
3. Add settings loading to `.config/rc-settings.sh` in correct order
4. Update relevant Brewfile/package lists

**Configuration loading order matters:**

- Shell basics → Homebrew → Applications → Language environments → Path post-processing


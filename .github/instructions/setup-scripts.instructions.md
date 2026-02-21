---
applyTo: "setup_*.sh,update_*.sh"
---

# Setup and Update Scripts

## Shared Functions

- Description: All setup scripts define identical `create_symlink()` and `set_bashrc()` helper functions.
  Do not change their signatures.
- `create_symlink src dst` - Creates symlink only if destination does not exist. Creates parent directories.
- `set_bashrc filename` - Appends conditional source line to ~/.bashrc or ~/.zshrc. Skips if already present.

## Tool Detection

- Pattern: Check tool availability before creating configuration.

```bash
type command > /dev/null 2>&1
```

## Shell Detection

- Pattern: Detect shell for rc file selection.

```bash
if [[ "$SHELL" == *zsh* ]]; then
  # zsh path
else
  # bash path
fi
```

## Adding a New Tool

- Create `.config/{tool}/` directory with a settings file
- Add tool detection and symlink creation to the appropriate setup script
- Add settings loading to `.config/rc-settings.sh` in the correct loading order
- Update relevant Brewfile or package lists

## Platform-Specific Patterns

- setup_mac.sh: Homebrew with `brew bundle`
- setup_aarch64.sh, setup_wsl_ubuntu.sh: apt with manual installs via curl/wget
- setup_codespaces.sh: Homebrew for Codespaces
- setup_proot_arm64.sh: apt with custom install functions
- setup_termux.sh: `pkg install`

## Script Conventions

- Use `set -eu` at the top
- Use `readonly` for constants
- Use `local -r` for function-scoped constants
- Run `mise run lint` (shellcheck) after changes
- Run `mise run format` (shfmt -i 2 -ci) after changes

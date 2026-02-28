---
applyTo: "setup_*.sh,update_*.sh"
---

# Setup and Update Scripts

## Shared Functions

- Constraint: All setup scripts define identical `create_symlink()` and `set_bashrc()` helper functions.
  Do not change their signatures.
- Function: `create_symlink src dst` - Creates symlink only if destination does not exist. Creates parent directories.
- Function: `set_bashrc filename` - Appends conditional source line to ~/.bashrc or ~/.zshrc. Skips if already present.

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

## New Tool Workflow

- Step 1: Create `.config/{tool}/` directory with a settings file.
- Step 2: Add tool detection and symlink creation to the appropriate setup script.
- Step 3: Add settings loading to `.config/rc-settings.sh` in the correct loading order.
- Step 4: Update relevant Brewfile or package lists.

## Platform Patterns

- macOS: Homebrew with `brew bundle` (setup_mac.sh).
- Linux ARM64: apt with manual installs via curl/wget (setup_aarch64.sh).
- WSL Ubuntu: apt with manual installs via curl/wget (setup_wsl_ubuntu.sh).
- Codespaces: Homebrew for Codespaces (setup_codespaces.sh).
- Proot ARM64: apt with custom install functions (setup_proot_arm64.sh).
- Termux: `pkg install` (setup_termux.sh).

## Script Conventions

- Rule: Use `set -eu` at the top
- Rule: Use `readonly` for constants
- Rule: Use `local -r` for function-scoped constants
- Rule: Run `mise run lint` (shellcheck) after changes
- Rule: Run `mise run format` (shfmt -i 2 -ci) after changes

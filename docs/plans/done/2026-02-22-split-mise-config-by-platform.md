---
status: DONE
---

# TASK: Split mise config.toml into platform-specific files

## Goal

- Goal: Rename `.config/mise/config.toml` to `.config/mise/config-mac.toml` and add
  `.config/mise/config-linux.toml` so the generic config is no longer applied in non-Mac environments.

## Ref

- `.config/mise/config.toml`
- `.config/mise/config-mac.toml`
- `.config/mise/config-linux.toml`
- `.config/mise/config-codespaces.toml`
- `setup_mac.sh`
- `setup_aarch64.sh`
- `setup_wsl_ubuntu.sh`
- `setup_proot_arm64.sh`
- `.github/workflows/ci.yml`

## Steps

- [x] Step 1: Git-remove `.config/mise/config.toml` and stage the existing untracked
      `config-mac.toml` and `config-linux.toml` (identical content).
- [x] Step 2: Update `setup_mac.sh` to symlink `config-mac.toml` instead of `config.toml`.
- [x] Step 3: Update `setup_aarch64.sh`, `setup_wsl_ubuntu.sh`, `setup_proot_arm64.sh`
      to symlink `config-linux.toml` instead of `config.toml`.
- [x] Step 4: Update `.github/workflows/ci.yml` `MISE_IGNORED_CONFIG_PATHS`
      to exclude both `config-mac.toml` and `config-linux.toml`.

## Verify

- Verify: `mise run lint` passes and no references to `.config/mise/config.toml` remain in setup scripts or CI.

## Scratchpad

- Motivation: `config.toml` was loaded by mise in all environments (Linux, Codespaces, etc.)
  even though it contained Mac-specific tools, causing unnecessary install attempts.
- Pattern: Follows the existing `config-codespaces.toml` convention — one file per environment,
  symlinked to `$HOME/.config/mise/config.toml` by the relevant setup script.
- `config-mac.toml` and `config-linux.toml` share identical content at the time of the split;
  they are expected to diverge as platform-specific needs arise.
- CI: `MISE_IGNORED_CONFIG_PATHS` updated from the single `config.toml` path to a
  colon-separated list of both platform configs.

---
status: DONE
---

# TASK: Fix CI mise config loading

## Goal

- Goal: Prevent `.config/mise/config.toml` from being loaded during CI, so `mise run lint` uses only root `mise.toml` tools.

## Ref

- `.github/workflows/ci.yml`
- `mise.toml`
- `.config/mise/config.toml`

## Steps

- [x] Step 1: Add `env.MISE_IGNORED_CONFIG_PATHS: ${{ github.workspace }}/.config/mise/config.toml`
      to the `lint` job in `.github/workflows/ci.yml`.

## Verify

- Verify: CI lint job completes without attempting to install developer-only tools (aws-vault, lua, etc.).

## Scratchpad

- Root cause: `jdx/mise-action` runs `mise install` and resolves all config files in the workspace, including `.config/mise/config.toml`.
- Fix: `MISE_IGNORED_CONFIG_PATHS` excludes a specific config file by absolute path.
- Rejected alternatives: `MISE_GLOBAL_CONFIG_FILE=/dev/null` does not stop project-context
  discovery; relative paths are unreliable.

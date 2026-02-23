# Debt: create_symlink Broken Symlink Detection

## Summary

- Description: `create_symlink` does not treat broken symlinks as existing destinations, which breaks idempotent re-runs.

## Location

- Path: `setup_mac.sh`
- Path: `setup_aarch64.sh`
- Path: `setup_codespaces.sh`
- Path: `setup_proot_arm64.sh`
- Path: `setup_termux.sh`
- Path: `setup_wsl_ubuntu.sh`

## Issue

- Detail: The helper checks only `[ -e "$dst" ]`. For dangling symlinks this returns false,
  so `ln -s` is attempted on an already-linked path and exits with error under `set -eu`.

## FIX_CONDITION

- Condition: Destination checks treat both existing files and existing symlinks as occupied,
  and repeated setup runs do not fail on broken symlink paths.

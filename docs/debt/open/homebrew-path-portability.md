# Debt: Homebrew Path Portability

## Summary

- Description: Homebrew bundle integration relies on a hardcoded Apple Silicon path and skips valid
  brew installations on other environments.

## Location

- Path: `.config/homebrew/homebrew-bundle.sh`

## Issue

- Detail: The script checks `/opt/homebrew/bin/brew` directly, which excludes Linuxbrew and
  non-default Homebrew locations. This prevents brew bundle behavior in supported
  non-Apple-Silicon environments.

## FIX_CONDITION

- Condition: Brew detection is path-agnostic and the bundle flow works when `brew` is available
  regardless of installation prefix.

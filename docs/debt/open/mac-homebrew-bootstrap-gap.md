# Debt: Mac Homebrew Bootstrap Gap

## Summary

- Description: Documented Homebrew bootstrap flow is not fully implemented in macOS and Codespaces setup paths.

## Location

- Path: `setup_mac.sh`
- Path: `setup_codespaces.sh`
- Path: `docs/design/architecture.md`

## Issue

- Detail: The documented Homebrew-first provisioning model does not match script behavior where
  brew bundle execution is incomplete or absent.

## Fix Condition

- Condition: Setup scripts execute the documented Homebrew bootstrap flow or design documentation
  is updated to match intended behavior.

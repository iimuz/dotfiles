# Debt: nvim Guard Typo

## Summary

- Description: nvim settings guard checks for `go` instead of `nvim`, which can skip Neovim alias
  setup on systems without Go.

## Location

- Path: `.config/nvim/nvim-settings.sh`

## Issue

- Detail: The guard condition uses `type go` even though the script configures Neovim behavior.
  This creates an unrelated dependency and prevents expected Neovim setup when `nvim` exists but
  Go is not installed.

## Fix Condition

- Condition: The guard checks `nvim` availability directly and Neovim setup runs whenever `nvim` is installed.

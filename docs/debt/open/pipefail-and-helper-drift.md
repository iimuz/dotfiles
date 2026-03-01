# Debt: pipefail and Helper Drift

## Summary

- Description: Setup scripts diverge from shared safety and helper implementation conventions.

## Location

- Path: `setup_mac.sh`
- Path: `setup_aarch64.sh`
- Path: `setup_codespaces.sh`
- Path: `setup_proot_arm64.sh`
- Path: `setup_termux.sh`
- Path: `setup_wsl_ubuntu.sh`

## Issue

- Detail: Some setup scripts omit `set -o pipefail`, and helper implementations differ in
  structure and naming despite project guidance that shared helper behavior should remain aligned.

## Fix Condition

- Condition: All setup scripts use consistent safety flags and aligned helper logic so shared
  behavior is maintained across platforms.

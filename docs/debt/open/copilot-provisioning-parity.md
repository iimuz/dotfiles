# Debt: Copilot Provisioning Parity

## Summary

- Description: Copilot configuration deployment differs by platform without a single documented contract.

## Location

- Path: `setup_mac.sh`
- Path: `setup_aarch64.sh`
- Path: `setup_codespaces.sh`
- Path: `setup_proot_arm64.sh`
- Path: `setup_termux.sh`
- Path: `setup_wsl_ubuntu.sh`

## Issue

- Detail: Platform scripts use different guard commands and deploy different subsets of Copilot
  config files, producing inconsistent Copilot setup outcomes across environments.

## Fix Condition

- Condition: Copilot setup behavior is standardized across supported platforms or explicitly
  documented where intentional differences exist.

# Debt: Cross-Platform Parity Gaps

## Summary

- Description: Lower-severity platform differences have accumulated across setup and settings behavior.

## Location

- Path: `setup_mac.sh`
- Path: `setup_aarch64.sh`
- Path: `setup_codespaces.sh`
- Path: `setup_proot_arm64.sh`
- Path: `setup_termux.sh`
- Path: `setup_wsl_ubuntu.sh`
- Path: `.config/rc-settings.sh`

## Issue

- Detail: The following specific parity gaps exist across platforms:
- Gap: gh extension provisioning - setup_mac.sh installs gh-dash and gh-prowl; setup_aarch64.sh and
  setup_wsl_ubuntu.sh install only gh-dash; setup_codespaces.sh, setup_proot_arm64.sh, and setup_termux.sh
  install no extensions
- Gap: inputrc deployment - setup_mac.sh deploys .inputrc via symlink; all other scripts omit it
- Gap: mcphub symlink - setup_mac.sh creates .config/mcphub symlink when nvim is available; all other scripts omit it
- Gap: keychain installation - setup_aarch64.sh installs keychain via apt; all other scripts omit it
- Gap: yq version pin - setup_aarch64.sh and setup_wsl_ubuntu.sh pin v4.47.1; setup_proot_arm64.sh pins v4.44.6
- Gap: rc-settings.sh error handling - settings files are sourced with bare . and no error handling;
  a failure in any sourced file aborts the interactive session

## FIX_CONDITION

- Condition: Each listed parity gap is either normalized across platforms or explicitly documented
  as an intentional platform-specific difference.

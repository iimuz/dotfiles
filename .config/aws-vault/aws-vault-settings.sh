#!/usr/bin/env bash
#
# AWS Vault Settings

# === Guard if command does not exist.
if ! type aws-vault >/dev/null 2>&1; then return 0; fi

export AWS_VAULT_BACKEND="pass"

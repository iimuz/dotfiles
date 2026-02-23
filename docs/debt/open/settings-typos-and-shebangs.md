# Debt: Settings Typos and Invalid Shebangs

## Summary

- Description: Multiple small defects in settings scripts create silent misconfiguration risk.

## Location

- Path: `.config/bash/aliases.sh`
- Path: `.config/node/npm.sh`
- Path: `.config/ruby/ruby-settings.sh`
- Path: `.config/node/nvm-settings.sh`
- Path: `.config/python/pipx-settings.sh`

## Issue

- Detail: Settings files contain the following specific defects:
- Defect: .config/ruby/ruby-settings.sh line 1: invalid shebang #!/usr/local/env bash, should be #!/usr/bin/env bash
- Defect: .config/ruby/ruby-settings.sh line 17: GEM_PATH assigned to gem-x64x, trailing x is a typo for gem-x64
- Defect: .config/node/nvm-settings.sh line 1: invalid shebang #!/usr/local/env bash, should be #!/usr/bin/env bash
- Defect: .config/python/pipx-settings.sh line 1: invalid shebang #!/usr/local/env bash, should be #!/usr/bin/env bash
- Defect: .config/bash/aliases.sh line 13: tye is a typo for type in the elif exa availability check
- Defect: .config/node/npm.sh line 19: XDG_CONFIG_HOM is a typo for XDG_CONFIG_HOME in NPM_USER_INIT

## FIX_CONDITION

- Condition: Identified typos and shebang declarations are corrected and shell linting validates the updated files.

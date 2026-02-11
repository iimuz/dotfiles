#!/bin/bash
#
# Copilot cli settings.

# Guard if command does not exist.
if ! type copilot >/dev/null 2>&1; then return 0; fi

function copilot_auto() {
  local -ar OPTIONS=(
    "--deny-tool=shell(git checkout:*)"
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(git rebase:*)"
    "--deny-tool=shell(git reset:*)"
    "--deny-tool=shell(git switch:*)"
    "--deny-tool=shell(npm remove:*)"
    "--deny-tool=shell(npm uninstall:*)"
    "--deny-tool=shell(rm -f:*)"
    "--deny-tool=shell(rm -rf:*)"
    "--deny-tool=shell(sudo:*)"
    "--allow-all-tools"
    # 共通 skills のアクセスチェックが入るため
    "--add-dir=$HOME/.config/.copilot/skills"
  )
  copilot "${OPTIONS[@]}" "$@"
}

function copilot_yolo() {
  local -ar OPTIONS=(
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(rm -f:*)"
    "--deny-tool=shell(rm -rf:*)"
    "--deny-tool=shell(sudo:*)"
    "--allow-url=github.com"
    "--allow-url=aws.amazon.com"
    "--allow-all-tools"
    "--allow-all-paths"
  )
  copilot "${OPTIONS[@]}" "$@"
}

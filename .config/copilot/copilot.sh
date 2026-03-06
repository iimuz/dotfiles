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

function copilot_prompt() {
  if [ "$#" -ne 1 ]; then
    echo "usage: copilot_prompt <markdown-file>" >&2
    return 1
  fi

  if ! type rg >/dev/null 2>&1; then
    echo "rg command is required" >&2
    return 1
  fi

  local -r SOURCE_FILE="$1"
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "file not found: $SOURCE_FILE" >&2
    return 1
  fi

  local PROMPT_SECTION
  PROMPT_SECTION="$(rg -U --pcre2 '(?s)^## Prompt\n(.*?)(?=^## |\z)' -- "$SOURCE_FILE")" || true
  if [ -z "$PROMPT_SECTION" ]; then
    echo "## Prompt section is empty or missing: $SOURCE_FILE" >&2
    return 1
  fi

  local -r PROMPT_TEXT="$(
    cat <<EOF
<user_task>
${PROMPT_SECTION}
</user_task>

<system_instruction>
Update the ## Steps section in ${SOURCE_FILE} to reflect the requested work.
</system_instruction>
EOF
  )"
  local -ar OPTIONS=(
    "--deny-tool=shell(git checkout:*)"
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(git rebase:*)"
    "--deny-tool=shell(git reset:*)"
    "--deny-tool=shell(git switch:*)"
    "--deny-tool=shell(npm remove:*)"
    "--deny-tool=shell(npm uninstall:*)"
    "--deny-tool=shell(rm:*)"
    "--deny-tool=shell(mv:*)"
    "--deny-tool=shell(cp:*)"
    "--deny-tool=shell(dd:*)"
    "--deny-tool=shell(mkfs:*)"
    "--deny-tool=shell(shutdown:*)"
    "--deny-tool=shell(reboot:*)"
    "--deny-tool=shell(kill:*)"
    "--deny-tool=shell(curl -X DELETE:*)"
    "--deny-tool=shell(wget --post-file:*)"
    "--deny-tool=shell(git push --force:*)"
    "--deny-tool=shell(sudo:*)"
    # 共通 skills のアクセスチェックが入るため
    "--add-dir=$HOME/.config/.copilot/skills"
  )
  copilot -p "$PROMPT_TEXT" --autopilot "${OPTIONS[@]}"
}

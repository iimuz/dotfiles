#!/bin/bash
#
# Copilot cli settings.

# Guard if command does not exist.
if ! type copilot >/dev/null 2>&1; then return 0; fi

readonly COPILOT_ATLASSIAN_READ_TOOLS="\
  --allow-tool='atlassian(getConfluencePage)'\
  --allow-tool='atlassian(getJiraIssue)'\
"

readonly COPILOT_MARKITDOWN_READ_TOOLS="--allow-tool='markitdown(convert_to_markdown)'"

readonly COPILOT_SERENA_READ_TOOLS="\
  --allow-tool='serena(activate_project)'\
  --allow-tool='serena(check_onboarding_performed)'\
  --allow-tool='serena(find_file)'\
  --allow-tool='serena(find_referencing_symbols)'\
  --allow-tool='serena(find_symbol)'\
  --allow-tool='serena(get_symbols_overview)'\
  --allow-tool='serena(list_dir)'\
  --allow-tool='serena(onboarding)'\
  --allow-tool='serena(search_for_pattern)'\
"
readonly COPILOT_SERENA_WRITE_TOOLS="\
  --allow-tool='serena(insert_after_symbol)'\
  --allow-tool='serena(insert_before_symbol)'\
  --allow-tool='serena(replace_regex)'\
  --allow-tool='serena(replace_symbol_body)'\
"
readonly COPILOT_SERENA_READ_MEMORY="\
  --allow-tool='serena(list_memories)'\
  --allow-tool='serena(read_memory)'\
"
readonly COPILOT_SERENA_WRITE_MEMORY="\
  --allow-tool='serena(delete_memory)'\
  --allow-tool='serena(write_memory)'\
"

readonly COPILOT_SHELL_READ_TOOLS="\
  --allow-tool='shell(cargo check:*)'\
  --allow-tool='shell(cargo clippy:*)'\
  --allow-tool='shell(cargo fmt:*)'\
  --allow-tool='shell(cat:*)'\
  --allow-tool='shell(echo:*)'\
  --allow-tool='shell(find:*)'\
  --allow-tool='shell(ls:*)'\
  --allow-tool='shell(git diff:*)'\
  --allow-tool='shell(git log:*)'\
  --allow-tool='shell(git show:*)'\
  --allow-tool='shell(git status:*)'\
  --allow-tool='shell(grep:*)'\
  --allow-tool='shell(rg:*)'\
  --allow-tool='shell(rustfmt:*)'\
  --allow-tool='shell(tree:*)'\
  --allow-tool='shell(wc:*)'\
  --allow-tool='shell(xargs:*)'\
"
readonly COPILOT_SHELL_DENY_TOOLS="\
  --deny-tool=shell(curl:*)\
  --deny-tool=shell(git checkout:*)\
  --deny-tool=shell(git push:*)\
  --deny-tool=shell(git rebase:*)\
  --deny-tool=shell(git reset:*)\
  --deny-tool=shell(git switch:*)\
  --deny-tool=shell(nc:*)\
  --deny-tool=shell(npm remove:*)\
  --deny-tool=shell(npm uninstall:*)\
  --deny-tool=shell(rm -f:*)\
  --deny-tool=shell(rm -rf:*)\
  --deny-tool=shell(sudo:*)\
  --deny-tool=shell(wget:*)\
"

alias copilot_atlassian="copilot\
  $COPILOT_SHELL_DENY_TOOLS --allow-tool='write'\
  $COPILOT_ATLASSIAN_READ_TOOLS $COPILOT_SERENA_READ_TOOLS --disable-mcp-server='markitdown'\
"
# alias copilot_auto="copilot\
#   $COPILOT_SHELL_DENY_TOOLS --allow-tool='write'\
#   $COPILOT_SERENA_READ_TOOLS $COPILOT_SERENA_READ_MEMORY $COPILOT_SERENA_WRITE_MEMORY $COPILOT_MARKITDOWN_READ_TOOLS $COPILOT_SERENA_WRITE_TOOLS $COPILOT_SHELL_READ_TOOLS --disable-mcp-server='atlassian'\
# "
alias copilot_commit="copilot\
  $COPILOT_SHELL_DENY_TOOLS $COPILOT_SERENA_READ_TOOLS $COPILOT_SERENA_READ_MEMORY $COPILOT_SHELL_READ_TOOLS --allow-tool='shell(git commit:*)'\
  --deny-tool='shell(git add:*)'\
  --disable-mcp-server='atlassian'\
  --disable-mcp-server='markitdown'\
"
alias copilot_edit="copilot\
  $COPILOT_SHELL_DENY_TOOLS --allow-tool='write'\
  $COPILOT_SERENA_READ_TOOLS $COPILOT_SERENA_READ_MEMORY $COPILOT_SERENA_WRITE_MEMORY $COPILOT_MARKITDOWN_READ_TOOLS $COPILOT_SERENA_WRITE_TOOLS $COPILOT_SHELL_READ_TOOLS --disable-mcp-server='atlassian'\
"
alias copilot_planning="copilot\
  $COPILOT_SHELL_DENY_TOOLS $COPILOT_ATLASSIAN_READ_TOOLS $COPILOT_MARKITDOWN_READ_TOOLS $COPILOT_SERENA_READ_TOOLS $COPILOT_SERENA_READ_MEMORY $COPILOT_SERENA_WRITE_MEMORY $COPILOT_SHELL_READ_TOOLS"
alias copilot_pr="copilot\
  $COPILOT_SHELL_DENY_TOOLS $COPILOT_SERENA_READ_TOOLS $COPILOT_SERENA_READ_MEMORY $COPILOT_SERENA_WRITE_MEMORY $COPILOT_SHELL_READ_TOOLS --allow-tool='shell(gh pr create --draft:*)'\
  --disable-mcp-server='atlassian'\
  --disable-mcp-server='markitdown'\
"

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

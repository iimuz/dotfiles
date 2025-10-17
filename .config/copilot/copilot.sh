#!/bin/bash
#
# Copilot cli settings.

# Guard if command does not exist.
if ! type copilot >/dev/null 2>&1; then return 0; fi

readonly COPILOT_READ_ALTLASSIAN_TOOLS="\
  --allow-tool='atlassian(getConfluencePage)'\
  --allow-tool='atlassian(getJiraIssue)'\
"

readonly COPILOT_READ_SERENA_TOOLS="\
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
readonly COPILOT_WRITE_SERENA_TOOLS="\
  --allow-tool='serena(insert_after_symbol)'\
  --allow-tool='serena(insert_before_symbol)'\
  --allow-tool='serena(replace_regex)'\
  --allow-tool='serena(replace_symbol_body)'\
"

readonly COPILOT_READ_SHELL_TOOLS="\
  --allow-tool='shell(ls:*)'\
  --allow-tool='shell(grep:*)'\
  --allow-tool='shell(rg:*)'\
  --allow-tool='shell(wc:*)'\
"
readonly COPILOT_DENY_TOOLS="\
  --deny-tool='shell(curl:*)'\
  --deny-tool='shell(git checkout:*)'\
  --deny-tool='shell(git push:*)'\
  --deny-tool='shell(git rebase:*)'\
  --deny-tool='shell(git reset:*)'\
  --deny-tool='shell(git switch:*)'\
  --deny-tool='shell(nc:*)'\
  --deny-tool='shell(npm remove:*)'\
  --deny-tool='shell(npm uninstall:*)'\
  --deny-tool='shell(rm -f:*)'\
  --deny-tool='shell(rm -rf:*)'\
  --deny-tool='shell(sudo:*)'\
  --deny-tool='shell(wget:*)'\
"

alias copilot_atlassian="copilot $COPILOT_DENY_TOOLS --allow-tool='write' $COPILOT_READ_ALTLASSIAN_TOOLS $COPILOT_READ_SERENA_TOOLS"
alias copilot_auto="copilot $COPILOT_DENY_TOOLS --allow-tool='write' $COPILOT_READ_SERENA_TOOLS $COPILOT_WRITE_SERENA_TOOLS --disable-mcp-server='atlassian'"
alias copilot_edit="copilot $COPILOT_DENY_TOOLS --allow-tool='write' $COPILOT_READ_SERENA_TOOLS $COPILOT_WRITE_SERENA_TOOLS --disable-mcp-server='atlassian'"
alias copilot_planning="copilot $COPILOT_DENY_TOOLS  $COPILOT_READ_ALTLASSIAN_TOOLS  $COPILOT_READ_SERENA_TOOLS  $COPILOT_READ_SHELL_TOOLS"

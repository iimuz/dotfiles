#!/usr/bin/env bash
# preToolUse hook: allow/deny/ask control for Copilot CLI tool invocations.
#
# Requires: bash 4+, jq, rg (ripgrep)
# Input: JSON from stdin with toolName and toolArgs fields.
# Output: JSON with permissionDecision (allow/deny/ask) or empty for default.
set -eu

readonly INPUT="$(cat)"
readonly TOOL_NAME="$(echo "$INPUT" | jq -r '.toolName // ""')"
readonly TOOL_ARGS="$(echo "$INPUT" | jq -r '.toolArgs // ""')"

# --- Logging -------------------------------------------------------------- #

readonly LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/copilot/hooks/pre-tool-use-permission"
mkdir -p "$LOG_DIR"
readonly LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).jsonl"
readonly TS_MS="$(echo "$INPUT" | jq -r '.timestamp // ""')"
readonly CWD="$(echo "$INPUT" | jq -r '.cwd // ""')"

log_decision() {
  local -r decision="$1" reason="${2:-}"
  local cmd=""
  if [ "$TOOL_NAME" = "bash" ]; then
    cmd="$(echo "$TOOL_ARGS" | jq -r '.command // ""')"
    cmd="${cmd:0:500}"
  fi
  jq -nc --arg ts "${TS_MS:-0}" --arg tool "$TOOL_NAME" \
    --arg decision "$decision" --arg reason "$reason" \
    --arg cmd "$cmd" --arg cwd "$CWD" \
    '{ts: ($ts | tonumber), tool: $tool, decision: $decision, reason: $reason, cmd: $cmd, cwd: $cwd}' \
    >>"$LOG_FILE"
}

# --- Helper --------------------------------------------------------------- #

deny() {
  log_decision "deny" "$1"
  jq -n --arg reason "$1" \
    '{permissionDecision: "deny", permissionDecisionReason: $reason}'
  exit 0
}

ask() {
  log_decision "ask" "$1"
  jq -n --arg reason "$1" \
    '{permissionDecision: "ask", permissionDecisionReason: $reason}'
  exit 0
}

allow() {
  log_decision "allow" ""
  echo '{"permissionDecision":"allow"}'
  exit 0
}

# --- Non-bash tools: always allow ----------------------------------------- #

case "$TOOL_NAME" in
  view | grep | glob | edit | create)
    allow
    ;;
esac

# Exit early if not a bash/shell tool.
if [ "$TOOL_NAME" != "bash" ]; then
  exit 0
fi

# --- Bash command rules --------------------------------------------------- #

readonly COMMAND="$(echo "$TOOL_ARGS" | jq -r '.command // ""')"
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ---- DENY: catastrophic / irreversible ----------------------------------- #

# rm with any force/recursive flag
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)rm\s' &&
  echo "$COMMAND" | rg -q '\s-[a-zA-Z]*[rf]|--force|--recursive'; then
  deny "rm with force/recursive flags is blocked"
fi
if echo "$COMMAND" | rg -q 'xargs\s+rm\s'; then
  deny "xargs rm is blocked"
fi

# Privilege escalation
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)(sudo|su)\s'; then
  deny "Privilege escalation is blocked"
fi

# Remote code execution via pipe
if echo "$COMMAND" | rg -q '(curl|wget)\s.*\|\s*(ba)?sh'; then
  deny "Remote code execution via pipe is blocked"
fi

# Dynamic code execution
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)(eval|exec)\s'; then
  deny "Dynamic code execution is blocked"
fi

# Disk destruction
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)(dd\s+if=|mkfs|fdisk)'; then
  deny "Disk destructive operation is blocked"
fi

# Dangerous permissions
if echo "$COMMAND" | rg -q 'chmod\s+777'; then
  deny "chmod 777 is blocked"
fi

# Git: force push
if echo "$COMMAND" | rg -q 'git\s+push\s.*--force'; then
  deny "git push --force is blocked"
fi

# Git: hard reset
if echo "$COMMAND" | rg -q 'git\s+reset\s.*--hard'; then
  deny "git reset --hard is blocked"
fi

# Git: clean with force
if echo "$COMMAND" | rg -q 'git\s+clean\s.*-[a-zA-Z]*f'; then
  deny "git clean -f is blocked"
fi

# ---- ASK: context-dependent --------------------------------------------- #

# Git: push (non-force, caught after force-push deny above)
if echo "$COMMAND" | rg -q 'git\s+push(\s|$)'; then
  ask "git push modifies remote"
fi

# Git: checkout / switch (working tree changes risk)
if echo "$COMMAND" | rg -q 'git\s+(checkout|switch)\s'; then
  ask "Branch switch may discard uncommitted changes"
fi

# Git: rebase
if echo "$COMMAND" | rg -q 'git\s+rebase(\s|$)'; then
  ask "git rebase rewrites history"
fi

# npm: remove / uninstall
if echo "$COMMAND" | rg -q 'npm\s+(remove|uninstall)(\s|$)'; then
  ask "npm package removal"
fi

# Process termination
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)kill\s'; then
  ask "Process termination"
fi

# Remote access
if echo "$COMMAND" | rg -q '(^|[;&|]\s*)(ssh|scp)\s'; then
  ask "Remote access"
fi

# In-place file modification
if echo "$COMMAND" | rg -q 'sed\s.*-i'; then
  ask "In-place file modification with sed -i"
fi

# gh api with write methods
if echo "$COMMAND" | rg -q 'gh\s+api\s' &&
  echo "$COMMAND" | rg -q -- '--method\s+(PUT|PATCH|DELETE|POST)'; then
  ask "gh api with write method"
fi

# ---- DEFAULT: no decision, fall through to CLI flags --------------------- #
log_decision "passthrough" ""
exit 0

#!/usr/bin/env bash
# Requires: bash 5+, jq
#
# Identify Copilot sessions for a specified date range.
# Outputs a JSON array of session paths and workspace metadata to stdout.
# Does NOT parse events.jsonl; session details are read by sub-agents.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: extract-sessions.sh --date YYYY-MM-DD [--end-date YYYY-MM-DD] [--copilot-dir PATH] [--include-empty]

Options:
  --date          Target date in YYYY-MM-DD format (required)
  --end-date      End date for range (optional, defaults to --date)
  --copilot-dir   Copilot directory path (optional, defaults to ~/.copilot)
  --include-empty Include sessions with no activity (default: excluded)
EOF
  exit 1
}

is_empty_session() {
  local -r session_path="$1"
  local -r ws="$session_path/workspace.yaml"
  local -r events="$session_path/events.jsonl"

  local summary
  summary=$(sed -n 's/^summary: //p' "$ws")

  if [[ -n "${summary:-}" ]]; then
    return 1
  fi

  if [[ -f "$events" ]] && [[ $(wc -c <"$events") -gt 1024 ]]; then
    return 1
  fi

  return 0
}

main() {
  local date="" end_date="" copilot_dir="$HOME/.copilot" include_empty=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --date)
        [[ $# -ge 2 ]] || usage
        date="$2"
        shift 2
        ;;
      --end-date)
        [[ $# -ge 2 ]] || usage
        end_date="$2"
        shift 2
        ;;
      --copilot-dir)
        [[ $# -ge 2 ]] || usage
        copilot_dir="$2"
        shift 2
        ;;
      --include-empty)
        include_empty=true
        shift
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        usage
        ;;
    esac
  done

  if [[ -z "$date" ]]; then
    echo "Error: --date is required" >&2
    usage
  fi

  if ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: --date must be in YYYY-MM-DD format" >&2
    exit 1
  fi

  end_date="${end_date:-$date}"

  if ! [[ "$end_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: --end-date must be in YYYY-MM-DD format" >&2
    exit 1
  fi

  local -r session_dir="$copilot_dir/session-state"

  if [[ ! -d "$session_dir" ]]; then
    echo "Error: Session directory not found: $session_dir" >&2
    exit 1
  fi

  if ! type jq >/dev/null 2>&1; then
    echo "Error: jq is required but not found" >&2
    exit 1
  fi

  local results=()

  for ws in "$session_dir"/*/workspace.yaml; do
    [[ -f "$ws" ]] || continue

    local ws_created_at
    ws_created_at=$(sed -n 's/^created_at: //p' "$ws")
    local session_date="${ws_created_at:0:10}"

    if [[ "$session_date" < "$date" ]] || [[ "$session_date" > "$end_date" ]]; then
      continue
    fi

    local session_path
    session_path=$(dirname "$ws")

    if [[ "$include_empty" == "false" ]] && is_empty_session "$session_path"; then
      continue
    fi

    local session_id created_at summary cwd
    session_id=$(sed -n 's/^id: //p' "$ws")
    created_at=$(sed -n 's/^created_at: //p' "$ws")
    summary=$(sed -n 's/^summary: //p' "$ws")
    cwd=$(sed -n 's/^cwd: //p' "$ws")

    local result
    result=$(jq -nc \
      --arg id "$session_id" \
      --arg path "$session_path" \
      --arg created_at "$created_at" \
      --arg summary "${summary:-}" \
      --arg cwd "$cwd" \
      '{session_id: $id, session_path: $path, created_at: $created_at, summary: $summary, cwd: $cwd}')
    results+=("$result")
  done

  if [[ ${#results[@]} -eq 0 ]]; then
    echo "[]"
  else
    printf '%s\n' "${results[@]}" | jq -s 'sort_by(.created_at)'
  fi
}

main "$@"
